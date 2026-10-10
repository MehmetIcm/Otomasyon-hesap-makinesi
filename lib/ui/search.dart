import 'package:flutter/material.dart';

import '../calculators/registry.dart';
import '../core/format.dart';
import '../data/content.dart';
import 'learn_page.dart';
import 'projects_page.dart';
import 'sim/sim_registry.dart';
import 'widgets.dart';

class SearchHit {
  final String kind;
  final String title;
  final String subtitle;
  final IconData icon;
  final void Function(BuildContext context) open;
  const SearchHit(this.kind, this.title, this.subtitle, this.icon, this.open);
}

/// Hesaplamalar, dersler, sözlük, projeler ve simülasyonlar içinde arar.
List<SearchHit> searchAll(String query) {
  final tokens = normalizeTr(query.trim()).split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (tokens.isEmpty) return const [];
  bool match(String hay) {
    final h = normalizeTr(hay);
    return tokens.every(h.contains);
  }

  final out = <SearchHit>[];
  for (final c in allCalcs) {
    if (match('${c.title} ${c.subtitle} ${c.keywords} ${c.category.title}')) {
      out.add(SearchHit('Hesaplama', c.title, c.subtitle, c.icon, (ctx) => openCalc(ctx, c)));
    }
  }
  for (final l in allLessons) {
    if (match('${l.title} ${l.keywords.join(' ')} ${l.definition} ${l.group.title}')) {
      out.add(SearchHit('Ders', l.title, l.group.title, Icons.school_outlined, (ctx) => openLesson(ctx, l)));
    }
  }
  for (final t in glossaryTerms) {
    if (match('${t.term} ${t.english} ${t.definition}')) {
      out.add(SearchHit('Sözlük', t.term, t.english, Icons.menu_book_outlined, (ctx) {
        showDialog<void>(
          context: ctx,
          builder: (_) => AlertDialog(
            title: Text(t.term),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(t.english, style: const TextStyle(fontStyle: FontStyle.italic)), const SizedBox(height: 8), Text(t.definition)],
            ),
            actions: [
              if (t.related.isNotEmpty && findLesson(t.related.first) != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    openLesson(ctx, findLesson(t.related.first)!);
                  },
                  child: const Text('İlgili ders'),
                ),
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
            ],
          ),
        );
      }));
    }
  }
  for (final p in allProjects) {
    if (match('${p.title} ${p.purpose} ${p.concepts.join(' ')}')) {
      out.add(SearchHit('Proje', p.title, p.purpose, Icons.precision_manufacturing, (ctx) {
        Navigator.of(ctx).push(MaterialPageRoute<void>(builder: (_) => ProjectPage(project: p)));
      }));
    }
  }
  for (final s in allSims) {
    if (match('${s.title} ${s.subtitle} simulasyon')) {
      out.add(SearchHit('Simülasyon', s.title, s.subtitle, s.icon, (ctx) => openSim(ctx, s.id)));
    }
  }
  return out;
}
