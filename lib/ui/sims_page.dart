import 'package:flutter/material.dart';

import 'sim/sim_registry.dart';
import 'widgets.dart';

class SimsPage extends StatelessWidget {
  const SimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Simülasyonlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const InfoBanner(
              icon: Icons.school_outlined,
              text: 'Simülasyonlar eğitim amaçlıdır; gerçek donanım testi değildir ve gerçek PLC veya emniyet sisteminin yerini tutmaz.',
            ),
            const SizedBox(height: 12),
            for (final s in allSims)
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
                    child: Icon(s.icon),
                  ),
                  title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(s.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openSim(context, s.id),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Yeni simülasyonlar aynı altyapıyla eklenecektir (ilerleme için PROGRESS.md dosyasına bakın).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
