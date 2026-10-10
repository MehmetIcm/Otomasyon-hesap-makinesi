import 'package:flutter/material.dart';

import '../calculators/registry.dart';
import '../data/content.dart';
import '../data/storage.dart';
import '../models/calc_models.dart';
import 'category_page.dart';
import 'learn_page.dart';
import 'search.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<CalcDef> _byIds(List<String> ids) {
    final out = <CalcDef>[];
    for (final id in ids) {
      final d = findCalc(id);
      if (d != null) out.add(d);
    }
    return out;
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Teknik Hesap Makinesi',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.calculate, size: 40),
      children: const [
        SizedBox(height: 12),
        Text(
          'Elektrikçiler, elektrik-elektronik öğrencileri, otomasyon teknisyenleri '
          've bakım çalışanları için çevrimdışı teknik hesap makineleri, eğitim dersleri, simülasyonlar ve projeler.\n\n'
          'Uygulama internet bağlantısı gerektirmez ve kişisel veri toplamaz. '
          'Favoriler ve son kullanılanlar yalnızca cihazınızda saklanır.\n\n'
          '$kDisclaimer',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teknik Hesap Makinesi'),
        actions: [
          IconButton(
            tooltip: 'Sözlük',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const GlossaryPage())),
          ),
          IconButton(
            tooltip: 'Hakkında',
            icon: const Icon(Icons.info_outline),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appStorage,
          builder: (context, _) {
            final searching = _query.trim().isNotEmpty;
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Ara: hesap, ders, sözlük, proje (ör. ohm, kontaktör)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searching
                        ? IconButton(
                            tooltip: 'Aramayı temizle',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _search.clear();
                              _query = '';
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (searching) ..._searchView(tt) else ..._homeView(context, tt),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _searchView(TextTheme tt) {
    final res = searchAll(_query);
    if (res.isEmpty) {
      return [
        const SizedBox(height: 32),
        Center(child: Text('Sonuç bulunamadı.', style: tt.bodyLarge)),
      ];
    }
    final cs = Theme.of(context).colorScheme;
    return [
      for (final h in res)
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
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              child: Icon(h.icon),
            ),
            title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(h.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(h.kind, style: tt.labelSmall),
            onTap: () => h.open(context),
          ),
        ),
    ];
  }

  List<Widget> _homeView(BuildContext context, TextTheme tt) {
    final favs = _byIds(appStorage.favorites);
    final recents = _byIds(appStorage.recent);
    final lastId = appStorage.lastLesson;
    final last = lastId == null ? null : findLesson(lastId);
    return [
      if (last != null) ...[
        Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('Öğrenmeye devam et', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(last.title),
            onTap: () => openLesson(context, last),
          ),
        ),
      ],
      _sectionTitle('Favoriler', tt),
      if (favs.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Bir hesaplamada yıldız simgesine dokunarak favorilere ekleyin.',
            style: tt.bodySmall,
          ),
        )
      else
        _MiniRow(items: favs),
      if (recents.isNotEmpty) ...[
        const SizedBox(height: 8),
        _sectionTitle('Son kullanılanlar', tt, action: TextButton(
          onPressed: appStorage.clearRecent,
          child: const Text('Temizle'),
        )),
        _MiniRow(items: recents),
      ],
      const SizedBox(height: 8),
      _sectionTitle('Kategoriler', tt),
      LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: cols == 2 ? 0.95 : 1.15,
          children: [
            for (final cat in CalcCategory.values) _CategoryCard(category: cat),
          ],
        );
      }),
    ];
  }

  Widget _sectionTitle(String t, TextTheme tt, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(t, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final List<CalcDef> items;
  const _MiniRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = items[i];
          return SizedBox(
            width: 150,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: cs.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => openCalc(context, d),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(d.icon, color: cs.primary),
                      Text(d.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CalcCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = allCalcs.where((c) => c.category == category).length;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => CategoryPage(category: category),
        )),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                child: Icon(category.icon),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text('$count hesaplama',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
