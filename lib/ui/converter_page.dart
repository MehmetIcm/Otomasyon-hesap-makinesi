import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../core/unit_converter.dart';
import '../core/validation.dart';
import '../data/storage.dart';
import '../models/calc_models.dart';
import 'calculator_page.dart' show labeledDropdown;
import 'widgets.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  int _cat = 0;
  int _from = 0;
  int _to = 1;
  final TextEditingController _value = TextEditingController(text: '1');
  CalcResult? _result;
  String? _error;

  UnitCategory get _category => unitCategories[_cat];

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _convert() {
    FocusScope.of(context).unfocus();
    final cat = _category;
    try {
      final v = parseNumber(_value.text);
      if (v == null) {
        throw const ValidationException('Geçerli bir sayı girin.');
      }
      final from = cat.units[_from];
      final to = cat.units[_to];
      final out = convertUnit(cat, from, to, v);
      final lines = <ResultLine>[
        ResultLine('${fmtNum(v)} ${from.symbol}', fmtNum(out, sig: 8), to.symbol),
      ];
      for (var n = 0; n < cat.units.length; n++) {
        if (n == _from) continue;
        final u = cat.units[n];
        lines.add(ResultLine(
            u.symbol, fmtNum(convertUnit(cat, from, u, v), sig: 8)));
      }
      final formula = cat.isTemperature
          ? '°C = (°F − 32) × 5/9\n°F = °C × 9/5 + 32\nK = °C + 273,15'
          : 'Hedef değer = Değer × (kaynak katsayısı ÷ hedef katsayısı)\n'
              '1 ${from.symbol} = ${fmtNum(convertUnit(cat, from, to, 1), sig: 8)} ${to.symbol}';
      setState(() {
        _result = CalcResult(lines: lines, formula: formula);
        _error = null;
      });
      appStorage.addRecent('converter');
    } on ValidationException catch (e) {
      setState(() {
        _error = e.message;
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = _category;
    List<DropdownMenuItem<int>> unitItems() => [
          for (var n = 0; n < cat.units.length; n++)
            DropdownMenuItem(value: n, child: Text(cat.units[n].symbol)),
        ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birim Dönüştürücü'),
        actions: [
          ListenableBuilder(
            listenable: appStorage,
            builder: (context, _) {
              final fav = appStorage.isFavorite('converter');
              return IconButton(
                tooltip: fav ? 'Favorilerden çıkar' : 'Favorilere ekle',
                icon: Icon(fav ? Icons.star : Icons.star_border,
                    color: fav ? Colors.amber.shade700 : null),
                onPressed: () => appStorage.toggleFavorite('converter'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            labeledDropdown(
              label: 'Büyüklük',
              value: _cat,
              items: [
                for (var n = 0; n < unitCategories.length; n++)
                  DropdownMenuItem(value: n, child: Text(unitCategories[n].title)),
              ],
              onChanged: (v) => setState(() {
                _cat = v ?? 0;
                _from = 0;
                _to = 1;
                _result = null;
                _error = null;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _value,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-+eE]')),
              ],
              decoration: InputDecoration(
                labelText: 'Değer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: labeledDropdown(
                    label: 'Kaynak birim',
                    value: _from,
                    items: unitItems(),
                    onChanged: (v) => setState(() {
                      _from = v ?? 0;
                      _result = null;
                    }),
                  ),
                ),
                IconButton(
                  tooltip: 'Birimleri değiştir',
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => setState(() {
                    final t = _from;
                    _from = _to;
                    _to = t;
                    _result = null;
                  }),
                ),
                Expanded(
                  child: labeledDropdown(
                    label: 'Hedef birim',
                    value: _to,
                    items: unitItems(),
                    onChanged: (v) => setState(() {
                      _to = v ?? 0;
                      _result = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: _convert,
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Dönüştür'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _value.text = '1';
                      _result = null;
                      _error = null;
                    }),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Temizle'),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              InfoBanner(icon: Icons.error_outline, text: _error!, isError: true),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              ResultCard(title: 'Birim Dönüştürücü', result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}
