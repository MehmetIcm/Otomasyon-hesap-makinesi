import 'package:flutter/material.dart';

import '../calculators/registry.dart';
import '../models/calc_models.dart';
import 'widgets.dart';

class CalcsPage extends StatelessWidget {
  const CalcsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hesaplamalar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final cat in CalcCategory.values) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Row(
                  children: [
                    Icon(cat.icon, size: 20),
                    const SizedBox(width: 8),
                    Text('${cat.title} araçları', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              for (final d in allCalcs.where((c) => c.category == cat)) CalcTile(def: d),
            ],
          ],
        ),
      ),
    );
  }
}
