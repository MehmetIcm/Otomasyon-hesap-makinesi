import 'dart:math' as math;

import 'validation.dart';

// ------------------------------------------------------------ Direnç renkleri
enum BandColor {
  black('Siyah', 0xFF212121),
  brown('Kahverengi', 0xFF795548),
  red('Kırmızı', 0xFFD32F2F),
  orange('Turuncu', 0xFFF57C00),
  yellow('Sarı', 0xFFFBC02D),
  green('Yeşil', 0xFF388E3C),
  blue('Mavi', 0xFF1976D2),
  violet('Mor', 0xFF7B1FA2),
  grey('Gri', 0xFF9E9E9E),
  white('Beyaz', 0xFFFAFAFA),
  gold('Altın', 0xFFC9A227),
  silver('Gümüş', 0xFFB0BEC5);

  final String label;
  final int argb;
  const BandColor(this.label, this.argb);
}

/// Rakam bantları: siyah (0) ... beyaz (9).
const List<BandColor> digitColors = [
  BandColor.black, BandColor.brown, BandColor.red, BandColor.orange,
  BandColor.yellow, BandColor.green, BandColor.blue, BandColor.violet,
  BandColor.grey, BandColor.white,
];

/// Çarpan bantları: 10^0 ... 10^9, altın (×0,1), gümüş (×0,01).
const List<BandColor> multiplierColors = BandColor.values;

const Map<BandColor, double> _tolerance = {
  BandColor.brown: 1,
  BandColor.red: 2,
  BandColor.green: 0.5,
  BandColor.blue: 0.25,
  BandColor.violet: 0.1,
  BandColor.grey: 0.05,
  BandColor.gold: 5,
  BandColor.silver: 10,
};

const Map<BandColor, double> _tempCo = {
  BandColor.black: 250,
  BandColor.brown: 100,
  BandColor.red: 50,
  BandColor.orange: 15,
  BandColor.yellow: 25,
  BandColor.green: 20,
  BandColor.blue: 10,
  BandColor.violet: 5,
  BandColor.grey: 1,
};

/// Tolerans bandı olarak kullanılabilen renkler.
List<BandColor> get toleranceColors => _tolerance.keys.toList();

/// Sıcaklık katsayısı bandı olarak kullanılabilen renkler.
List<BandColor> get tempCoColors => _tempCo.keys.toList();

double _multiplier(BandColor c) {
  if (c == BandColor.gold) return 0.1;
  if (c == BandColor.silver) return 0.01;
  return math.pow(10, c.index).toDouble();
}

typedef ResistorReading = ({
  double ohms,
  double tolPct,
  double min,
  double max,
  double? tempCoPpm
});

/// 4, 5 veya 6 bantlı direnç değerini okur.
/// 4 bant: 2 rakam, çarpan, tolerans. 5 bant: 3 rakam, çarpan, tolerans.
/// 6 bant: 5 banttakiler + sıcaklık katsayısı.
ResistorReading readResistor(List<BandColor> bands) {
  if (bands.length < 4 || bands.length > 6) {
    throw const ValidationException('Direnç 4, 5 veya 6 bantlı olmalıdır.');
  }
  final nDigits = bands.length == 4 ? 2 : 3;
  var value = 0;
  for (var k = 0; k < nDigits; k++) {
    final b = bands[k];
    if (b.index > 9) {
      throw ValidationException('${k + 1}. bant altın veya gümüş olamaz.');
    }
    value = value * 10 + b.index;
  }
  if (bands[0] == BandColor.black) {
    throw const ValidationException('1. bant siyah olamaz.');
  }
  final mult = _multiplier(bands[nDigits]);
  final tol = _tolerance[bands[nDigits + 1]];
  if (tol == null) {
    throw ValidationException(
        '${bands[nDigits + 1].label} rengi tolerans bandı olarak kullanılamaz.');
  }
  double? tc;
  if (bands.length == 6) {
    tc = _tempCo[bands[5]];
    if (tc == null) {
      throw ValidationException(
          '${bands[5].label} rengi sıcaklık katsayısı bandı olarak kullanılamaz.');
    }
  }
  final ohms = value * mult;
  return (
    ohms: ohms,
    tolPct: tol,
    min: ohms * (1 - tol / 100),
    max: ohms * (1 + tol / 100),
    tempCoPpm: tc,
  );
}

// ------------------------------------------------------ Seri / paralel direnç
typedef NetworkResult = ({
  double req,
  double? iTotal,
  double? pTotal,
  List<double>? vEach,
  List<double>? iEach
});

/// Eşdeğer direnç; [v] verilirse toplam akım/güç ve her direncin gerilim/akımı.
NetworkResult resistorNetwork({
  required bool parallel,
  required List<double> r,
  double? v,
}) {
  if (r.isEmpty) {
    throw const ValidationException('En az bir direnç değeri girin.');
  }
  if (r.length > 100) {
    throw const ValidationException('En fazla 100 direnç girilebilir.');
  }
  for (final x in r) {
    requirePositive(x, 'Direnç değeri');
  }
  final req = parallel
      ? 1 / r.fold<double>(0, (a, b) => a + 1 / b)
      : r.fold<double>(0, (a, b) => a + b);
  if (v == null) {
    return (req: req, iTotal: null, pTotal: null, vEach: null, iEach: null);
  }
  requirePositive(v, 'Besleme gerilimi');
  final iTotal = v / req;
  final List<double> vEach;
  final List<double> iEach;
  if (parallel) {
    vEach = [for (final _ in r) v];
    iEach = [for (final x in r) v / x];
  } else {
    vEach = [for (final x in r) iTotal * x];
    iEach = [for (final _ in r) iTotal];
  }
  return (req: req, iTotal: iTotal, pTotal: v * iTotal, vEach: vEach, iEach: iEach);
}

// ------------------------------------------------------------- Kondansatör
/// Eşdeğer kapasite (F). Seri: 1/C = Σ 1/Ci, paralel: C = Σ Ci.
double capacitorEquivalent({required bool series, required List<double> c}) {
  if (c.isEmpty) {
    throw const ValidationException('En az bir kapasite değeri girin.');
  }
  if (c.length > 100) {
    throw const ValidationException('En fazla 100 kondansatör girilebilir.');
  }
  for (final x in c) {
    requirePositive(x, 'Kapasite değeri');
  }
  return series
      ? 1 / c.fold<double>(0, (a, b) => a + 1 / b)
      : c.fold<double>(0, (a, b) => a + b);
}

/// Kapasitif reaktans XC = 1 / (2π·f·C), Ω.
double capacitiveReactance({required double c, required double f}) {
  requirePositive(c, 'Kapasite');
  requirePositive(f, 'Frekans');
  return 1 / (2 * math.pi * f * c);
}
