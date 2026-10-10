import 'dart:math' as math;

import 'validation.dart';

// ------------------------------------------------------- Motor hız / kayma
/// Senkron hız (d/dk): ns = 120·f / p, p = kutup sayısı (çift).
double syncSpeedRpm(double f, int poles) {
  requirePositive(f, 'Frekans');
  if (poles < 2 || poles.isOdd || poles > 48) {
    throw const ValidationException(
        'Kutup sayısı 2, 4, 6, 8 ... gibi çift bir sayı olmalıdır.');
  }
  return 120 * f / poles;
}

/// Kayma (%): s = (ns − nr) / ns × 100.
double slipPercent(double ns, double nr) {
  requirePositive(ns, 'Senkron hız');
  requireNonNegative(nr, 'Rotor hızı');
  if (nr > ns * (1 + 1e-9)) {
    throw const ValidationException(
        'Rotor hızı senkron hızdan büyük olamaz (motor çalışma bölgesi).');
  }
  return (ns - nr) / ns * 100;
}

/// Rotor hızı (d/dk): nr = ns · (1 − s/100).
double rotorSpeedFromSlip(double ns, double slipPct) {
  requirePositive(ns, 'Senkron hız');
  requireRange(slipPct, 0, 100, 'Kayma (%)');
  return ns * (1 - slipPct / 100);
}

/// Etiket devri ve frekanstan kutup sayısını tahmin eder: ns >= nr olan en küçük çift p.
int estimatePoles(double f, double nr) {
  requirePositive(f, 'Frekans');
  requirePositive(nr, 'Etiket devri');
  for (var p = 2; p <= 48; p += 2) {
    if (120 * f / p >= nr) return p;
  }
  throw const ValidationException('Bu değerlerle kutup sayısı bulunamadı.');
}

// ---------------------------------------------------------------- Elektronik
const List<double> _e12 = [1.0, 1.2, 1.5, 1.8, 2.2, 2.7, 3.3, 3.9, 4.7, 5.6, 6.8, 8.2];

/// Verilen değere eşit veya büyük en yakın E12 standart direnç değeri.
double nextE12(double r) {
  requirePositive(r, 'Direnç');
  final decade = math.pow(10, (math.log(r) / math.ln10).floor()).toDouble();
  for (final m in [..._e12, 10.0]) {
    if (m * decade >= r * (1 - 1e-9)) return m * decade;
  }
  return 10 * decade;
}

typedef LedResult = ({double r, double rE12, double pResistor, double pLed});

/// LED seri direnci: R = (Vkaynak − Vf) / If.
LedResult ledResistor({required double vs, required double vf, required double iA}) {
  requirePositive(vs, 'Besleme gerilimi');
  requirePositive(vf, 'LED ileri gerilimi');
  requirePositive(iA, 'LED akımı');
  if (vs <= vf) {
    throw const ValidationException(
        'Besleme gerilimi LED ileri geriliminden büyük olmalıdır.');
  }
  final r = (vs - vf) / iA;
  final rs = nextE12(r);
  final iReal = (vs - vf) / rs;
  return (r: r, rE12: rs, pResistor: iReal * iReal * rs, pLed: vf * iReal);
}

typedef DividerResult = ({double vout, double current, double pR1, double pR2});

/// Gerilim bölücü: Vout = Vin · R2 / (R1 + R2). [rLoad] verilirse R2 ile paralel yük dikkate alınır.
DividerResult voltageDivider({
  required double vin,
  required double r1,
  required double r2,
  double? rLoad,
}) {
  requirePositive(vin, 'Giriş gerilimi');
  requirePositive(r1, 'R1');
  requirePositive(r2, 'R2');
  var r2eff = r2;
  if (rLoad != null) {
    requirePositive(rLoad, 'Yük direnci');
    r2eff = r2 * rLoad / (r2 + rLoad);
  }
  final i = vin / (r1 + r2eff);
  final vout = i * r2eff;
  return (vout: vout, current: i, pR1: i * i * r1, pR2: vout * vout / r2eff);
}

typedef RcResult = ({double tau, double t99, double? vc, double? percent});

/// RC zaman sabiti τ = R·C. Şarjda Vc = V·(1 − e^(−t/τ)), deşarjda Vc = V·e^(−t/τ).
RcResult rcCircuit({
  required double r,
  required double c,
  required bool charging,
  double? v,
  double? t,
}) {
  requirePositive(r, 'Direnç');
  requirePositive(c, 'Kapasite');
  final tau = r * c;
  double? vc;
  double? pct;
  if (t != null) {
    requireNonNegative(t, 'Süre');
    final f = charging ? 1 - math.exp(-t / tau) : math.exp(-t / tau);
    pct = f * 100;
    if (v != null) {
      requirePositive(v, 'Kaynak gerilimi');
      vc = v * f;
    }
  }
  return (tau: tau, t99: 5 * tau, vc: vc, percent: pct);
}

// ---------------------------------------------------------- Reaktans
double inductiveReactance({required double l, required double f}) {
  requirePositive(l, 'Endüktans');
  requirePositive(f, 'Frekans');
  return 2 * math.pi * f * l;
}

/// Rezonans frekansı f0 = 1 / (2π·√(L·C)).
double resonanceFrequency({required double l, required double c}) {
  requirePositive(l, 'Endüktans');
  requirePositive(c, 'Kapasite');
  return 1 / (2 * math.pi * math.sqrt(l * c));
}

// ---------------------------------------------------------- Otomasyon
/// Enkoder darbe frekansından devir: n = (darbe/s) / PPR × 60.
double encoderRpm({required double pulsesPerSecond, required double ppr}) {
  requireNonNegative(pulsesPerSecond, 'Darbe frekansı');
  requirePositive(ppr, 'Enkoder çözünürlüğü (PPR)');
  return pulsesPerSecond / ppr * 60;
}

typedef ConveyorResult = ({double outRpm, double speedMs});

/// Konveyör bant hızı: v = (nmotor / i) · π · D / 60.
ConveyorResult conveyorSpeed({
  required double motorRpm,
  required double gearRatio,
  required double rollerDiameterM,
}) {
  requirePositive(motorRpm, 'Motor devri');
  requirePositive(gearRatio, 'Redüktör oranı');
  requirePositive(rollerDiameterM, 'Tambur çapı');
  final out = motorRpm / gearRatio;
  return (outRpm: out, speedMs: out * math.pi * rollerDiameterM / 60);
}

typedef CylinderResult = ({double areaPush, double forcePush, double? areaPull, double? forcePull});

/// Pnömatik silindir kuvveti F = P · A · η (P: etkin/ölçülen basınç).
CylinderResult cylinderForce({
  required double pressurePa,
  required double boreM,
  double? rodM,
  double eta = 1,
}) {
  requirePositive(pressurePa, 'Basınç');
  requirePositive(boreM, 'Piston çapı');
  requireEfficiency(eta);
  final aPush = math.pi / 4 * boreM * boreM;
  double? aPull;
  if (rodM != null) {
    requirePositive(rodM, 'Piston kolu çapı');
    if (rodM >= boreM) {
      throw const ValidationException('Piston kolu çapı piston çapından küçük olmalıdır.');
    }
    aPull = math.pi / 4 * (boreM * boreM - rodM * rodM);
  }
  return (
    areaPush: aPush,
    forcePush: pressurePa * aPush * eta,
    areaPull: aPull,
    forcePull: aPull == null ? null : pressurePa * aPull * eta,
  );
}

// ---------------------------------------------------------------- AWG
/// AWG numarasından tel çapı (mm): d = 0,127 · 92^((36 − n)/39). 0000 için n = −3.
double awgDiameterMm(int n) {
  if (n < -3 || n > 40) {
    throw const ValidationException('AWG değeri 0000 (−3) ile 40 arasında olmalıdır.');
  }
  return 0.127 * math.pow(92, (36 - n) / 39).toDouble();
}

double awgAreaMm2(int n) {
  final d = awgDiameterMm(n);
  return math.pi / 4 * d * d;
}

/// Verilen kesite (mm²) en yakın AWG numarası.
int nearestAwg(double areaMm2) {
  requirePositive(areaMm2, 'Kesit');
  var best = -3;
  var bestDiff = double.infinity;
  for (var n = -3; n <= 40; n++) {
    final d = (awgAreaMm2(n) - areaMm2).abs();
    if (d < bestDiff) {
      bestDiff = d;
      best = n;
    }
  }
  return best;
}
