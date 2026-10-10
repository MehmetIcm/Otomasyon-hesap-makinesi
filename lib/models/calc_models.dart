import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/validation.dart';

/// Birim seçeneği. [factor] girilen değeri taban (SI) birime çevirir.
class UnitOpt {
  final String label;
  final double factor;
  const UnitOpt(this.label, [this.factor = 1]);
}

enum FieldKind { number, list, choice }

/// Bir hesaplama formundaki tek bir alanın tanımı.
class FieldDef {
  final String key;
  final String label;
  final FieldKind kind;
  final List<UnitOpt> units;
  final int unitIndex;
  final String hint;
  final bool required;
  final String defaultText;
  final List<String> options;
  final int optionIndex;
  final List<int>? swatches;

  /// Seçim değerlerine göre alanın görünürlüğünü belirler.
  final bool Function(Map<String, int> choices)? visible;

  FieldDef.number(
    this.key,
    this.label, {
    this.units = const [],
    this.unitIndex = 0,
    this.hint = '',
    this.required = true,
    this.defaultText = '',
    this.visible,
  })  : kind = FieldKind.number,
        options = const [],
        optionIndex = 0,
        swatches = null;

  FieldDef.list(
    this.key,
    this.label, {
    this.units = const [],
    this.unitIndex = 0,
    this.hint = '',
    this.required = true,
    this.defaultText = '',
    this.visible,
  })  : kind = FieldKind.list,
        options = const [],
        optionIndex = 0,
        swatches = null;

  FieldDef.choice(
    this.key,
    this.label,
    this.options, {
    this.optionIndex = 0,
    this.swatches,
    this.visible,
  })  : kind = FieldKind.choice,
        units = const [],
        unitIndex = 0,
        hint = '',
        required = true,
        defaultText = '';
}

/// Formdan toplanan, taban birimlere çevrilmiş girdiler.
class CalcInput {
  final Map<String, double> numbers;
  final Map<String, List<double>> lists;
  final Map<String, int> choices;
  const CalcInput(this.numbers, this.lists, this.choices);

  double? opt(String key) => numbers[key];

  double req(String key) {
    final v = numbers[key];
    if (v == null) throw const ValidationException('Gerekli bir değer eksik.');
    return v;
  }

  List<double> list(String key) => lists[key] ?? const [];
  int choice(String key) => choices[key] ?? 0;
}

class ResultLine {
  final String label;
  final String value;
  final String unit;
  const ResultLine(this.label, this.value, [this.unit = '']);

  String get text => unit.isEmpty ? value : '$value $unit';
}

class CalcResult {
  /// İlk satır ana sonuçtur.
  final List<ResultLine> lines;
  final String formula;
  final String note;
  final String warning;
  const CalcResult({
    required this.lines,
    this.formula = '',
    this.note = '',
    this.warning = '',
  });

  String toShareText(String title) {
    final b = StringBuffer('$title\n');
    for (final l in lines) {
      b.writeln('${l.label}: ${l.text}');
    }
    if (formula.isNotEmpty) b.writeln('\nFormül:\n$formula');
    if (warning.isNotEmpty) b.writeln('\nUyarı: $warning');
    b.write('\n— Teknik Hesap Makinesi');
    return b.toString();
  }
}

ResultLine numLine(String label, double v, [String unit = '']) =>
    ResultLine(label, fmtNum(v), unit);

ResultLine engLine(String label, double v, String unit) =>
    ResultLine(label, fmtEng(v, unit));

enum CalcCategory {
  electric('Elektrik', Icons.bolt, 'Ohm, güç, enerji, motor, güç faktörü'),
  cable('Kablo', Icons.cable, 'Gerilim düşümü ve kesit yardımcısı'),
  electronics('Elektronik', Icons.memory, 'Direnç, kondansatör, frekans'),
  automation('Otomasyon', Icons.precision_manufacturing, 'PLC ölçekleme, darbe ve zaman'),
  tools('Araçlar', Icons.swap_horiz, 'Birim dönüştürücü');

  final String title;
  final IconData icon;
  final String subtitle;
  const CalcCategory(this.title, this.icon, this.subtitle);
}

class CalcDef {
  final String id;
  final String title;
  final String subtitle;
  final String keywords;
  final CalcCategory category;
  final IconData icon;
  final List<FieldDef> fields;
  final CalcResult Function(CalcInput input)? compute;

  /// Standart form yerine özel ekran kullanan hesaplamalar için.
  final Widget Function()? customBuilder;

  /// Hesaplama ekranının üstünde gösterilen önemli güvenlik notu.
  final String caution;

  const CalcDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    this.keywords = '',
    this.fields = const [],
    this.compute,
    this.customBuilder,
    this.caution = '',
  });
}
