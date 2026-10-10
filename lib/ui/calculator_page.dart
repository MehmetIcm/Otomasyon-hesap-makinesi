import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../core/validation.dart';
import '../data/storage.dart';
import '../models/calc_models.dart';
import 'widgets.dart';

OutlineInputBorder get _border =>
    OutlineInputBorder(borderRadius: BorderRadius.circular(12));

/// Etiketli açılır liste (InputDecorator ile).
Widget labeledDropdown({
  String? label,
  required int value,
  required List<DropdownMenuItem<int>> items,
  required ValueChanged<int?> onChanged,
}) {
  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: _border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

/// Tanımlara göre otomatik form oluşturan genel hesaplama ekranı.
class CalculatorPage extends StatefulWidget {
  final CalcDef def;
  const CalculatorPage({super.key, required this.def});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final Map<String, TextEditingController> _ctrl = {};
  final Map<String, int> _unit = {};
  final Map<String, int> _choice = {};
  final ScrollController _scroll = ScrollController();
  final GlobalKey _resultKey = GlobalKey();
  CalcResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final f in widget.def.fields) {
      if (f.kind == FieldKind.choice) {
        _choice[f.key] = f.optionIndex;
      } else {
        _ctrl[f.key] = TextEditingController(text: f.defaultText);
        _unit[f.key] = f.unitIndex;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  bool _vis(FieldDef f) => f.visible == null || f.visible!(_choice);

  CalcInput _collect() {
    final nums = <String, double>{};
    final lists = <String, List<double>>{};
    for (final f in widget.def.fields) {
      if (!_vis(f) || f.kind == FieldKind.choice) continue;
      final text = _ctrl[f.key]!.text.trim();
      if (text.isEmpty) {
        if (f.required) {
          throw ValidationException('"${f.label}" alanı boş bırakılamaz.');
        }
        continue;
      }
      final factor = f.units.isEmpty ? 1.0 : f.units[_unit[f.key]!].factor;
      if (f.kind == FieldKind.list) {
        final l = parseNumberList(text);
        if (l == null) {
          throw ValidationException(
              '"${f.label}" alanında geçersiz sayı var. Değerleri boşluk veya ; ile ayırın.');
        }
        lists[f.key] = [for (final v in l) v * factor];
      } else {
        final v = parseNumber(text);
        if (v == null) {
          throw ValidationException('"${f.label}" için geçerli bir sayı girin.');
        }
        nums[f.key] = v * factor;
      }
    }
    return CalcInput(nums, lists, Map<String, int>.of(_choice));
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    try {
      final res = widget.def.compute!(_collect());
      setState(() {
        _result = res;
        _error = null;
      });
      appStorage.addRecent(widget.def.id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _resultKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx,
              duration: const Duration(milliseconds: 300), alignment: 0.05);
        }
      });
    } on ValidationException catch (e) {
      setState(() {
        _error = e.message;
        _result = null;
      });
    } catch (_) {
      setState(() {
        _error = 'Hesaplama yapılamadı. Girilen değerleri kontrol edin.';
        _result = null;
      });
    }
  }

  void _clear() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (final f in widget.def.fields) {
        if (f.kind == FieldKind.choice) {
          _choice[f.key] = f.optionIndex;
        } else {
          _ctrl[f.key]!.text = f.defaultText;
          _unit[f.key] = f.unitIndex;
        }
      }
      _result = null;
      _error = null;
    });
  }

  Widget _numberField(FieldDef f) {
    final isList = f.kind == FieldKind.list;
    final multi = f.units.length > 1;
    final field = TextField(
      controller: _ctrl[f.key],
      keyboardType: isList
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: isList
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-+eE]'))],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: f.label,
        helperText: f.hint.isEmpty ? null : f.hint,
        helperMaxLines: 2,
        border: _border,
        suffixText: (!multi && f.units.length == 1) ? f.units.first.label : null,
      ),
    );
    if (!multi) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: labeledDropdown(
            value: _unit[f.key]!,
            items: [
              for (var n = 0; n < f.units.length; n++)
                DropdownMenuItem(value: n, child: Text(f.units[n].label)),
            ],
            onChanged: (v) => setState(() {
              _unit[f.key] = v ?? 0;
              _result = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _choiceField(FieldDef f) {
    return labeledDropdown(
      label: f.label,
      value: _choice[f.key]!,
      items: [
        for (var n = 0; n < f.options.length; n++)
          DropdownMenuItem(
            value: n,
            child: Row(
              children: [
                if (f.swatches != null) ...[
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(f.swatches![n]),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(f.options[n], overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
      onChanged: (v) => setState(() {
        _choice[f.key] = v ?? 0;
        _result = null;
        _error = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    final tt = Theme.of(context).textTheme;
    final visible = def.fields.where(_vis).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(def.title),
        actions: [
          ListenableBuilder(
            listenable: appStorage,
            builder: (context, _) {
              final fav = appStorage.isFavorite(def.id);
              return IconButton(
                tooltip: fav ? 'Favorilerden çıkar' : 'Favorilere ekle',
                icon: Icon(fav ? Icons.star : Icons.star_border,
                    color: fav ? Colors.amber.shade700 : null),
                onPressed: () => appStorage.toggleFavorite(def.id),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(def.subtitle, style: tt.bodyMedium),
            if (def.caution.isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoBanner(icon: Icons.info_outline, text: def.caution),
            ],
            const SizedBox(height: 16),
            for (final f in visible) ...[
              f.kind == FieldKind.choice ? _choiceField(f) : _numberField(f),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Hesapla'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _clear,
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
              KeyedSubtree(
                key: _resultKey,
                child: ResultCard(title: def.title, result: _result!),
              ),
            ],
            const SizedBox(height: 20),
            Text(kDisclaimer,
                style: tt.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
