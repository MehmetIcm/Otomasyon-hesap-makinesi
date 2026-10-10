import 'package:flutter/material.dart';

import '../calculators/registry.dart';
import '../core/format.dart';
import '../data/content.dart';
import '../data/storage.dart';
import 'quiz_widget.dart';
import 'sim/sim_registry.dart';
import 'symbols.dart';
import 'widgets.dart';

void openLesson(BuildContext context, Lesson l) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonPage(lesson: l)));
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğren'),
        actions: [
          IconButton(
            tooltip: 'Sözlük',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const GlossaryPage())),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appStorage,
          builder: (context, _) {
            final done = allLessons.where((l) => appStorage.isCompleted(l.id)).length;
            final last = appStorage.lastLesson == null ? null : findLesson(appStorage.lastLesson!);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Card(
                  elevation: 0,
                  color: cs.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İlerlemeniz: $done / ${allLessons.length} ders',
                            style: tt.titleMedium?.copyWith(
                                color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: allLessons.isEmpty ? 0 : done / allLessons.length),
                        if (last != null) ...[
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () => openLesson(context, last),
                            icon: const Icon(Icons.play_circle_outline),
                            label: Text('Devam et: ${last.title}', overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                for (final g in LessonGroup.values) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(g.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  for (final l in allLessons.where((l) => l.group == g))
                    Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: cs.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          appStorage.bestScore(l.id) == null
                              ? l.keywords.take(3).join(' • ')
                              : 'Test puanı: ${appStorage.bestScore(l.id)} / ${l.quiz.length}',
                        ),
                        trailing: Icon(
                          appStorage.isCompleted(l.id) ? Icons.check_circle : Icons.chevron_right,
                          color: appStorage.isCompleted(l.id) ? const Color(0xFF2E9E4F) : null,
                        ),
                        onTap: () => openLesson(context, l),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class LessonPage extends StatefulWidget {
  final Lesson lesson;
  const LessonPage({super.key, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  @override
  void initState() {
    super.initState();
    appStorage.setLastLesson(widget.lesson.id);
  }

  Widget _section(BuildContext context, String title, String text) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(text, style: tt.bodyLarge?.copyWith(height: 1.45)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final calc = l.calcId == null ? null : findCalc(l.calcId!);
    final sim = l.simId == null ? null : findSim(l.simId!);
    return Scaffold(
      appBar: AppBar(title: Text(l.title, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l.group.title, style: tt.labelLarge?.copyWith(color: cs.primary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final k in l.keywords) Chip(label: Text(k), visualDensity: VisualDensity.compact)],
            ),
            if (l.safety.isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoBanner(icon: Icons.warning_amber_rounded, text: l.safety, isError: true),
            ],
            if (l.symbol != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  children: [
                    SymbolView(kind: l.symbol!, width: 150),
                    const SizedBox(height: 4),
                    Text('Temsili devre sembolü (standart onaylı çizim değildir)', style: tt.bodySmall),
                  ],
                ),
              ),
            ],
            _section(context, 'Tanım', l.definition),
            _section(context, 'Ne işe yarar?', l.whatFor),
            _section(context, 'Nasıl çalışır?', l.how),
            _section(context, 'Gerçek hayattan örnek', l.example),
            if (sim != null || calc != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (sim != null)
                    FilledButton.tonalIcon(
                      onPressed: () => openSim(context, sim.id),
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Simülasyonu aç'),
                    ),
                  if (calc != null)
                    FilledButton.tonalIcon(
                      onPressed: () => openCalc(context, calc),
                      icon: const Icon(Icons.calculate),
                      label: Text('Hesap: ${calc.title}'),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            QuizCard(id: l.id, quiz: l.quiz),
            if (l.related.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('İlgili konular', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final id in l.related)
                    if (findLesson(id) != null)
                      ActionChip(
                        label: Text(findLesson(id)!.title),
                        onPressed: () => openLesson(context, findLesson(id)!),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: appStorage,
              builder: (context, _) {
                final done = appStorage.isCompleted(l.id);
                return FilledButton.icon(
                  onPressed: () => appStorage.setCompleted(l.id, !done),
                  icon: Icon(done ? Icons.undo : Icons.check),
                  label: Text(done ? 'Tamamlandı işaretini kaldır' : 'Dersi tamamlandı olarak işaretle'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GlossaryPage extends StatefulWidget {
  const GlossaryPage({super.key});

  @override
  State<GlossaryPage> createState() => _GlossaryPageState();
}

class _GlossaryPageState extends State<GlossaryPage> {
  String _q = '';
  bool _favOnly = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sözlük')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appStorage,
          builder: (context, _) {
            final q = normalizeTr(_q.trim());
            final items = glossaryTerms.where((t) {
              if (_favOnly && !appStorage.isFavorite(t.id)) return false;
              if (q.isEmpty) return true;
              return normalizeTr('${t.term} ${t.english} ${t.definition}').contains(q);
            }).toList()
              ..sort((a, b) => normalizeTr(a.term).compareTo(normalizeTr(b.term)));
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                TextField(
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    hintText: 'Terim ara (Türkçe veya İngilizce)',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Yalnızca favoriler'),
                    selected: _favOnly,
                    onSelected: (v) => setState(() => _favOnly = v),
                  ),
                ),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Terim bulunamadı.')),
                  ),
                for (final t in items)
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: cs.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(t.term, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(t.english),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.definition),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final id in t.related)
                              if (findLesson(id) != null)
                                ActionChip(
                                  label: Text(findLesson(id)!.title),
                                  onPressed: () => openLesson(context, findLesson(id)!),
                                ),
                            IconButton(
                              tooltip: appStorage.isFavorite(t.id) ? 'Favorilerden çıkar' : 'Favorilere ekle',
                              icon: Icon(appStorage.isFavorite(t.id) ? Icons.star : Icons.star_border,
                                  color: appStorage.isFavorite(t.id) ? Colors.amber.shade700 : null),
                              onPressed: () => appStorage.toggleFavorite(t.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
