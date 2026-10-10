import 'dart:math' as math;

import 'validation.dart';

// ------------------------------------------------ Temel devre (pil-anahtar-lamba)
typedef CircuitState = ({
  double current,
  double lampVoltage,
  double lampPower,
  double brightness,
  bool fuseBlown
});

/// Pil, anahtar, sigorta ve lamba devresi. Lamba 12 V için tasarlanmış kabul edilir.
/// [shorted] true ise lamba kısa devre edilmiştir (çok düşük direnç).
CircuitState basicCircuit({
  required double volts,
  required double lampOhms,
  required bool switchClosed,
  required bool shorted,
  required double fuseA,
  required bool fuseBlown,
}) {
  requirePositive(volts, 'Gerilim');
  requirePositive(lampOhms, 'Lamba direnci');
  requirePositive(fuseA, 'Sigorta akımı');
  const shortOhms = 0.05;
  var blown = fuseBlown;
  if (!switchClosed || blown) {
    return (current: 0.0, lampVoltage: 0.0, lampPower: 0.0, brightness: 0.0, fuseBlown: blown);
  }
  final r = shorted ? shortOhms : lampOhms;
  final i = volts / r;
  if (i > fuseA) {
    blown = true;
    return (current: 0.0, lampVoltage: 0.0, lampPower: 0.0, brightness: 0.0, fuseBlown: true);
  }
  final vLamp = shorted ? 0.0 : volts;
  final p = shorted ? 0.0 : volts * i;
  final b = shorted ? 0.0 : math.min(1.0, (vLamp / 12) * (vLamp / 12));
  return (current: i, lampVoltage: vLamp, lampPower: p, brightness: b, fuseBlown: blown);
}

// ------------------------------------------------------ Start-Stop mühürleme
/// Kontaktör bobininin bir sonraki durumu.
/// Bobin devresi: termik NC, acil stop NC, stop NC seri; START (NO) ile K1 yardımcı kontağı (NO) paralel.
/// [coil] bobinin mevcut durumudur; yardımcı kontak bobin enerjili iken kapalıdır.
bool startStopNext({
  required bool coil,
  required bool startPressed,
  required bool stopPressed,
  required bool eStopPressed,
  required bool thermalTripped,
}) {
  final seriesClosed = !stopPressed && !eStopPressed && !thermalTripped;
  return seriesClosed && (startPressed || coil);
}

// ---------------------------------------------------------- Motor modeli
typedef MotorSim = ({double ns, double slipPct, double nr});

/// Basit eğitim modeli: kayma yükle yaklaşık doğrusal artar (boşta %0,5, tam yükte [ratedSlipPct]).
MotorSim motorSim({
  required double freq,
  required int poles,
  required double loadPct,
  double ratedSlipPct = 4,
}) {
  requirePositive(freq, 'Frekans');
  if (poles < 2 || poles.isOdd) {
    throw const ValidationException('Kutup sayısı çift olmalıdır.');
  }
  requireRange(loadPct, 0, 100, 'Yük (%)');
  final ns = 120 * freq / poles;
  final s = 0.5 + (ratedSlipPct - 0.5) * loadPct / 100;
  return (ns: ns, slipPct: s, nr: ns * (1 - s / 100));
}

// ------------------------------------------------------- Depo seviye / pompa
/// Pompa mantığı (histerezis): üst seviye sensörü görünce durur, alt seviye altına inince çalışır.
bool pumpNext({
  required double level,
  required bool pumpOn,
  double lowPct = 25,
  double highPct = 80,
}) {
  if (level >= highPct) return false;
  if (level < lowPct) return true;
  return pumpOn;
}

/// Seviye (%) değişimi: pompa doldurur, kullanım vanası boşaltır.
double levelStep({
  required double level,
  required bool pumpOn,
  required bool demandOpen,
  required double dt,
  double inRate = 10,
  double outRate = 6,
}) {
  final d = (pumpOn ? inRate : 0) - (demandOpen ? outRate : 0);
  return math.min(100.0, math.max(0.0, level + d * dt));
}

// -------------------------------------------------------------- Trafik lambası
enum Light { red, yellow, green }

typedef TrafficPhase = ({String name, double seconds, Light a, Light b});

const List<TrafficPhase> trafficPhases = [
  (name: 'A yeşil, B kırmızı', seconds: 8, a: Light.green, b: Light.red),
  (name: 'A sarı, B kırmızı', seconds: 2, a: Light.yellow, b: Light.red),
  (name: 'Hepsi kırmızı', seconds: 1, a: Light.red, b: Light.red),
  (name: 'A kırmızı, B yeşil', seconds: 6, a: Light.red, b: Light.green),
  (name: 'A kırmızı, B sarı', seconds: 2, a: Light.red, b: Light.yellow),
  (name: 'Hepsi kırmızı', seconds: 1, a: Light.red, b: Light.red),
];

double get trafficCycleSeconds =>
    trafficPhases.fold<double>(0, (a, p) => a + p.seconds);

/// [t] saniyesindeki faz ve fazın kalan süresi.
({int index, double remaining}) trafficAt(double t) {
  var x = t % trafficCycleSeconds;
  for (var i = 0; i < trafficPhases.length; i++) {
    if (x < trafficPhases[i].seconds) {
      return (index: i, remaining: trafficPhases[i].seconds - x);
    }
    x -= trafficPhases[i].seconds;
  }
  return (index: 0, remaining: trafficPhases[0].seconds);
}

/// Start-Stop devresinin durumunu Türkçe açıklar.
String startStopStatus({
  required bool coil,
  required bool startPressed,
  required bool stopPressed,
  required bool eStopPressed,
  required bool thermalTripped,
}) {
  if (eStopPressed) return 'Acil stop basılı: bobin hattı kesik, motor duruyor.';
  if (thermalTripped) return 'Termik röle attı (95-96 açık): bobin hattı kesik. Önce resetleyin.';
  if (stopPressed) return 'Stop basılı: bobin kesik, mühür çözüldü.';
  if (coil && startPressed) return 'Start basılı: bobin enerjili, motor çalışıyor.';
  if (coil) return 'Mühür aktif: Start bırakıldı ama bobin yardımcı kontaktan besleniyor.';
  return 'Start bekleniyor: bobin enerjisiz, motor duruyor.';
}
