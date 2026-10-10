import 'package:flutter/material.dart';

import '../calculators/registry.dart';
import '../data/content.dart';
import '../data/storage.dart';
import 'quiz_widget.dart';
import 'sim/sim_registry.dart';
import 'widgets.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Projeler')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appStorage,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const InfoBanner(
                icon: Icons.school_outlined,
                text: 'Projeler adım adım anlatılan eğitim çalışmalarıdır. Gerçek devre kurulumu yetkin personelce yapılmalıdır.',
              ),
              const SizedBox(height: 12),
              for (final p in allProjects)
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: cs.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                      child: const Icon(Icons.precision_manufacturing),
                    ),
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(p.purpose, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Icon(
                      appStorage.isCompleted(p.id) ? Icons.check_circle : Icons.chevron_right,
                      color: appStorage.isCompleted(p.id) ? const Color(0xFF2E9E4F) : null,
                    ),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => ProjectPage(project: p))),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Daha fazla proje ortak şablonla eklenecektir (PROGRESS.md).',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectPage extends StatelessWidget {
  final Project project;
  const ProjectPage({super.key, required this.project});

  Widget _title(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      );

  Widget _bullets(List<String> items, {bool numbered = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 26, child: Text(numbered ? '${i + 1}.' : '•')),
                  Expanded(child: Text(items[i], style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
        ],
      );

  Widget _mono(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = project;
    final sim = p.simId == null ? null : findSim(p.simId!);
    return Scaffold(
      appBar: AppBar(title: Text(p.title, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (p.safety.isNotEmpty) InfoBanner(icon: Icons.warning_amber_rounded, text: p.safety, isError: true),
            _title(context, 'Proje amacı'),
            Text(p.purpose, style: const TextStyle(height: 1.4)),
            _title(context, 'Öğrenilecek kavramlar'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final c in p.concepts) Chip(label: Text(c), visualDensity: VisualDensity.compact)],
            ),
            _title(context, 'Gerekli elemanlar'),
            _bullets(p.parts),
            _title(context, 'Basit blok diyagramı'),
            _mono(context, p.blockDiagram),
            _title(context, 'Kumanda / ladder gösterimi'),
            _mono(context, p.ladder),
            _title(context, 'Çalışma sırası'),
            _bullets(p.steps, numbered: true),
            _title(context, 'Giriş / çıkış listesi'),
            _bullets(p.io),
            _title(context, 'Değiştirip deneyebilecekleriniz'),
            _bullets(p.tweaks),
            _title(context, 'Beklenen sonuç'),
            Text(p.expected, style: const TextStyle(height: 1.4)),
            _title(context, 'Sık yapılan hatalar'),
            _bullets(p.mistakes),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (sim != null)
                  FilledButton.icon(
                    onPressed: () => openSim(context, sim.id),
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Mini simülasyonu aç'),
                  ),
                for (final id in p.calcIds)
                  if (findCalc(id) != null)
                    FilledButton.tonalIcon(
                      onPressed: () => openCalc(context, findCalc(id)!),
                      icon: const Icon(Icons.calculate),
                      label: Text(findCalc(id)!.title),
                    ),
              ],
            ),
            const SizedBox(height: 20),
            QuizCard(id: p.id, quiz: p.quiz),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: appStorage,
              builder: (context, _) {
                final done = appStorage.isCompleted(p.id);
                return FilledButton.icon(
                  onPressed: () => appStorage.setCompleted(p.id, !done),
                  icon: Icon(done ? Icons.undo : Icons.check),
                  label: Text(done ? 'Tamamlandı işaretini kaldır' : 'Projeyi tamamlandı olarak işaretle'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
