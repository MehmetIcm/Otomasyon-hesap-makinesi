import 'package:flutter/material.dart';

import '../calculators/registry.dart';
import '../models/calc_models.dart';
import 'widgets.dart';

class CategoryPage extends StatelessWidget {
  final CalcCategory category;
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final items = allCalcs.where((c) => c.category == category).toList();
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [for (final d in items) CalcTile(def: d)],
        ),
      ),
    );
  }
}
