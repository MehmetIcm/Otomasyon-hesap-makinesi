import 'validation.dart';

// ------------------------------------------------------- Frekans ve periyot
double periodFromFrequency(double f) {
  requirePositive(f, 'Frekans');
  return 1 / f;
}

double frequencyFromPeriod(double t) {
  requirePositive(t, 'Periyot');
  return 1 / t;
}

// --------------------------------------------------------- Darbe hesapları
typedef PulseResult = ({double period, double freq, double tOn, double tOff, double dutyPct});

/// Frekans ve çalışma oranından (duty cycle, %) süreler.
PulseResult pulseFromFreqDuty(double f, double dutyPct) {
  requirePositive(f, 'Frekans');
  requireRange(dutyPct, 0, 100, 'Çalışma oranı (%)');
  final t = 1 / f;
  final on = t * dutyPct / 100;
  return (period: t, freq: f, tOn: on, tOff: t - on, dutyPct: dutyPct);
}

/// Açık (ON) ve kapalı (OFF) sürelerden frekans ve çalışma oranı.
PulseResult pulseFromTimes(double tOn, double tOff) {
  requirePositive(tOn, 'Açık kalma süresi');
  requireNonNegative(tOff, 'Kapalı kalma süresi');
  final t = tOn + tOff;
  return (period: t, freq: 1 / t, tOn: tOn, tOff: tOff, dutyPct: tOn / t * 100);
}

// ---------------------------------------------------------------- Ölçekleme
/// Doğrusal ölçekleme: y = outMin + (x − inMin)·(outMax − outMin)/(inMax − inMin).
/// Giriş aralığı ters (inMin > inMax) olabilir; sıfır genişlikli aralık geçersizdir.
double scaleLinear({
  required double x,
  required double inMin,
  required double inMax,
  required double outMin,
  required double outMax,
}) {
  if (!x.isFinite || !inMin.isFinite || !inMax.isFinite || !outMin.isFinite || !outMax.isFinite) {
    throw const ValidationException('Ölçekleme değerleri geçerli sayılar olmalıdır.');
  }
  if (inMax == inMin) {
    throw const ValidationException('Giriş aralığının alt ve üst değeri aynı olamaz.');
  }
  return outMin + (x - inMin) * (outMax - outMin) / (inMax - inMin);
}

/// Giriş aralığındaki konumu 0..1 oran olarak verir.
double fractionOf(double x, double inMin, double inMax) {
  if (inMax == inMin) {
    throw const ValidationException('Giriş aralığının alt ve üst değeri aynı olamaz.');
  }
  return (x - inMin) / (inMax - inMin);
}
