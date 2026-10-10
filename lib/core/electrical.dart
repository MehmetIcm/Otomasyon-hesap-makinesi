import 'dart:math' as math;

import 'validation.dart';

const double sqrt3 = 1.7320508075688772;

/// 1 mekanik HP = 745,69987 W. 1 PS (metrik beygir) = 735,49875 W.
const double hpMechanical = 745.69987158227022;
const double hpMetric = 735.49875;

// ---------------------------------------------------------------- Ohm Kanunu
typedef OhmResult = ({double v, double i, double r, double p});

/// V, I, R, P değerlerinden tam olarak ikisi verilir; diğerleri hesaplanır.
OhmResult ohmLaw({double? v, double? i, double? r, double? p}) {
  final given = [v, i, r, p].where((e) => e != null).length;
  if (given != 2) {
    throw const ValidationException(
        'Tam olarak iki değer girin. Diğer değerler otomatik hesaplanır.');
  }
  if (v != null) requirePositive(v, 'Gerilim');
  if (i != null) requirePositive(i, 'Akım');
  if (r != null) requirePositive(r, 'Direnç');
  if (p != null) requirePositive(p, 'Güç');

  if (v != null && i != null) return (v: v, i: i, r: v / i, p: v * i);
  if (v != null && r != null) return (v: v, i: v / r, r: r, p: v * v / r);
  if (v != null && p != null) return (v: v, i: p / v, r: v * v / p, p: p);
  if (i != null && r != null) return (v: i * r, i: i, r: r, p: i * i * r);
  if (i != null && p != null) return (v: p / i, i: i, r: p / (i * i), p: p);
  final rr = r!;
  final pp = p!;
  return (v: math.sqrt(pp * rr), i: math.sqrt(pp / rr), r: rr, p: pp);
}

// ------------------------------------------------------------- Elektrik gücü
enum PhaseType { dc, single, three }

typedef PowerResult = ({
  double pIn,
  double s,
  double q,
  double i,
  double pOut,
  double pf
});

/// DC, tek fazlı AC ve üç fazlı AC güç hesabı. [u] üç fazlıda hatlar arası gerilimdir.
/// Akım [i] veya aktif güç [p] değerlerinden yalnızca biri verilmelidir.
PowerResult electricPower({
  required PhaseType type,
  required double u,
  double? i,
  double? p,
  double pf = 1,
  double eta = 1,
}) {
  requirePositive(u, 'Gerilim');
  if ((i == null) == (p == null)) {
    throw const ValidationException(
        'Akım veya güç değerlerinden yalnızca birini girin.');
  }
  requirePowerFactor(pf);
  requireEfficiency(eta);
  final k = type == PhaseType.three ? sqrt3 : 1.0;
  final cos = type == PhaseType.dc ? 1.0 : pf;
  final double cur;
  if (i != null) {
    requirePositive(i, 'Akım');
    cur = i;
  } else {
    requirePositive(p, 'Güç');
    cur = p! / (k * u * cos);
  }
  final pIn = k * u * cur * cos;
  final s = k * u * cur;
  final q = math.sqrt(math.max(s * s - pIn * pIn, 0));
  return (pIn: pIn, s: s, q: q, i: cur, pOut: pIn * eta, pf: cos);
}

// -------------------------------------------------------- Enerji ve maliyet
typedef EnergyResult = ({
  double dailyKwh,
  double kwh,
  double cost,
  double dailyCost
});

EnergyResult energyCost({
  required double powerW,
  required double hoursPerDay,
  required double days,
  required double quantity,
  required double pricePerKwh,
}) {
  requirePositive(powerW, 'Güç');
  requirePositive(hoursPerDay, 'Günlük çalışma süresi');
  if (hoursPerDay > 24 + 1e-9) {
    throw const ValidationException('Günlük çalışma süresi 24 saati aşamaz.');
  }
  requirePositive(days, 'Gün sayısı');
  requirePositive(quantity, 'Adet');
  requireNonNegative(pricePerKwh, 'Birim enerji fiyatı');
  final daily = powerW / 1000 * hoursPerDay * quantity;
  return (
    dailyKwh: daily,
    kwh: daily * days,
    cost: daily * days * pricePerKwh,
    dailyCost: daily * pricePerKwh,
  );
}

// ---------------------------------------------- Gerilim düşümü / kablo kesiti
enum Conductor {
  copper('Bakır', 1 / 56, 0.00393),
  aluminium('Alüminyum', 1 / 35, 0.00403);

  final String label;

  /// 20 °C'de özdirenç, Ω·mm²/m (1/56 ve 1/35 pratik hesap değerleri).
  final double rho20;

  /// Sıcaklık katsayısı, 1/K.
  final double alpha;
  const Conductor(this.label, this.rho20, this.alpha);

  double rho(double tempC) => rho20 * (1 + alpha * (tempC - 20));
}

typedef VDropResult = ({
  double dropV,
  double dropPct,
  double uLoad,
  double rConductor,
  double lossW,
  double rho
});

/// Yalnızca omik direnç ve cosφ'yi dikkate alan gerilim düşümü.
/// Tek faz: ΔU = 2·L·I·cosφ·ρ/S, üç faz: ΔU = √3·L·I·cosφ·ρ/S.
/// [lengthM] tek yön hat uzunluğudur (metre).
VDropResult voltageDrop({
  required bool threePhase,
  required Conductor conductor,
  required double u,
  required double i,
  required double lengthM,
  required double sectionMm2,
  double pf = 1,
  double tempC = 20,
}) {
  requirePositive(u, 'Gerilim');
  requirePositive(i, 'Akım');
  requirePositive(lengthM, 'Kablo uzunluğu');
  requirePositive(sectionMm2, 'Kablo kesiti');
  requirePowerFactor(pf);
  requireRange(tempC, -50, 250, 'İletken sıcaklığı');
  final rho = conductor.rho(tempC);
  final k = threePhase ? sqrt3 : 2.0;
  final r = rho * lengthM / sectionMm2;
  final drop = k * i * r * pf;
  if (drop >= u) {
    throw const ValidationException(
        'Hesaplanan gerilim düşümü besleme gerilimine eşit veya büyük. Akım, uzunluk ve kesit değerlerini kontrol edin.');
  }
  return (
    dropV: drop,
    dropPct: drop / u * 100,
    uLoad: u - drop,
    rConductor: r,
    lossW: (threePhase ? 3.0 : 2.0) * i * i * r,
    rho: rho,
  );
}

/// Yaygın standart iletken kesitleri (mm²).
const List<double> standardSections = [
  1.5, 2.5, 4, 6, 10, 16, 25, 35, 50, 70, 95, 120, 150, 185, 240, 300, 400,
  500, 630,
];

typedef SectionCandidate = ({double section, double dropV, double dropPct});
typedef SectionResult = ({
  double minSection,
  double allowedDropV,
  List<SectionCandidate> candidates,
  bool exceedsRange
});

/// İzin verilen gerilim düşümüne göre gereken en küçük kesiti ve ondan
/// başlayan en fazla üç standart kesiti değerlendirir.
SectionResult cableSection({
  required bool threePhase,
  required Conductor conductor,
  required double u,
  required double i,
  required double lengthM,
  required double allowedDropPct,
  double pf = 1,
  double tempC = 20,
}) {
  requirePositive(u, 'Gerilim');
  requirePositive(i, 'Akım');
  requirePositive(lengthM, 'Kablo uzunluğu');
  requirePowerFactor(pf);
  requireRange(tempC, -50, 250, 'İletken sıcaklığı');
  if (!allowedDropPct.isFinite ||
      allowedDropPct <= 0 ||
      allowedDropPct >= 100) {
    throw const ValidationException(
        'İzin verilen gerilim düşümü %0 ile %100 arasında olmalıdır.');
  }
  final rho = conductor.rho(tempC);
  final k = threePhase ? sqrt3 : 2.0;
  final allowedV = allowedDropPct / 100 * u;
  final minS = k * lengthM * i * pf * rho / allowedV;
  final start = standardSections.indexWhere((s) => s >= minS * (1 - 1e-12));
  final cands = <SectionCandidate>[];
  if (start >= 0) {
    final end = math.min(start + 3, standardSections.length);
    for (var n = start; n < end; n++) {
      final s = standardSections[n];
      final d = k * i * rho * lengthM / s * pf;
      cands.add((section: s, dropV: d, dropPct: d / u * 100));
    }
  }
  return (
    minSection: minS,
    allowedDropV: allowedV,
    candidates: cands,
    exceedsRange: start < 0,
  );
}

// ------------------------------------------------------------- Güç faktörü
typedef PowerTriangle = ({
  double p,
  double q,
  double s,
  double pf,
  double phiDeg
});

/// P, Q, S değerlerinden tam olarak ikisi verilir (Q endüktif kabul edilir).
PowerTriangle powerTriangle({double? p, double? q, double? s}) {
  final given = [p, q, s].where((e) => e != null).length;
  if (given != 2) {
    throw const ValidationException(
        'Aktif (P), reaktif (Q) ve görünür (S) güçten tam olarak ikisini girin.');
  }
  if (p != null) requirePositive(p, 'Aktif güç');
  if (q != null) requirePositive(q, 'Reaktif güç');
  if (s != null) requirePositive(s, 'Görünür güç');
  final double pp;
  final double qq;
  final double ss;
  if (p != null && q != null) {
    pp = p;
    qq = q;
    ss = math.sqrt(p * p + q * q);
  } else if (p != null && s != null) {
    if (p > s * (1 + 1e-9)) {
      throw const ValidationException('Aktif güç görünür güçten büyük olamaz.');
    }
    pp = p;
    ss = s;
    qq = math.sqrt(math.max(s * s - p * p, 0));
  } else {
    final qv = q!;
    final sv = s!;
    if (qv > sv * (1 + 1e-9)) {
      throw const ValidationException(
          'Reaktif güç görünür güçten büyük olamaz.');
    }
    qq = qv;
    ss = sv;
    pp = math.sqrt(math.max(sv * sv - qv * qv, 0));
  }
  final pf = pp / ss;
  return (
    p: pp,
    q: qq,
    s: ss,
    pf: pf,
    phiDeg: math.acos(math.min(pf, 1.0)) * 180 / math.pi,
  );
}

typedef Compensation = ({
  double q1,
  double q2,
  double qc,
  double s1,
  double s2,
  double? i1,
  double? i2,
  double? cDelta,
  double? cStar
});

/// Üç fazlı kompanzasyon: Qc = P·(tanφ1 − tanφ2).
/// [uLine] ve [freq] verilirse kondansatör kapasitesi (faz başına) ve akımlar da hesaplanır.
Compensation pfCompensation({
  required double pW,
  required double pf1,
  required double pf2,
  double? uLine,
  double? freq,
}) {
  requirePositive(pW, 'Aktif güç');
  requirePowerFactor(pf1, 'Mevcut güç faktörü');
  requirePowerFactor(pf2, 'Hedef güç faktörü');
  if (pf2 <= pf1) {
    throw const ValidationException(
        'Hedef güç faktörü mevcut güç faktöründen büyük olmalıdır.');
  }
  final q1 = pW * math.tan(math.acos(pf1));
  final q2 = pW * math.tan(math.acos(pf2));
  final qc = q1 - q2;
  final s1 = pW / pf1;
  final s2 = pW / pf2;
  double? i1;
  double? i2;
  double? cd;
  double? cs;
  if (uLine != null) {
    requirePositive(uLine, 'Gerilim');
    requirePositive(freq, 'Frekans');
    final w = 2 * math.pi * freq!;
    i1 = s1 / (sqrt3 * uLine);
    i2 = s2 / (sqrt3 * uLine);
    cd = qc / (3 * w * uLine * uLine);
    cs = qc / (w * uLine * uLine);
  }
  return (
    q1: q1,
    q2: q2,
    qc: qc,
    s1: s1,
    s2: s2,
    i1: i1,
    i2: i2,
    cDelta: cd,
    cStar: cs
  );
}

// ------------------------------------------------------------ Üç fazlı motor
typedef MotorResult = ({
  double pOutW,
  double pInW,
  double current,
  double sVa,
  double qVar,
  double lossW
});

MotorResult _motor(double pIn, double pOut, double i, double u) {
  final s = sqrt3 * u * i;
  return (
    pOutW: pOut,
    pInW: pIn,
    current: i,
    sVa: s,
    qVar: math.sqrt(math.max(s * s - pIn * pIn, 0)),
    lossW: pIn - pOut,
  );
}

/// Mil gücünden şebeke akımı: I = Pmil / (η·√3·U·cosφ).
MotorResult motorFromShaftPower({
  required double pOutW,
  required double u,
  required double pf,
  required double eta,
}) {
  requirePositive(pOutW, 'Mil gücü');
  requirePositive(u, 'Gerilim');
  requirePowerFactor(pf);
  requireEfficiency(eta);
  final pIn = pOutW / eta;
  final i = pIn / (sqrt3 * u * pf);
  return _motor(pIn, pOutW, i, u);
}

/// Çekilen akımdan mil gücü: Pmil = √3·U·I·cosφ·η.
MotorResult motorFromCurrent({
  required double i,
  required double u,
  required double pf,
  required double eta,
}) {
  requirePositive(i, 'Akım');
  requirePositive(u, 'Gerilim');
  requirePowerFactor(pf);
  requireEfficiency(eta);
  final pIn = sqrt3 * u * i * pf;
  return _motor(pIn, pIn * eta, i, u);
}
