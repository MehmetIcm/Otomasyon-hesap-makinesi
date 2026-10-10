import 'package:flutter_test/flutter_test.dart';
import 'package:pro/core/more_calcs.dart';
import 'package:pro/core/sim_logic.dart';
import 'package:pro/core/validation.dart';

void main() {
  group('Motor hızı', () {
    test('senkron hız 50 Hz', () {
      expect(syncSpeedRpm(50, 2), 3000);
      expect(syncSpeedRpm(50, 4), 1500);
      expect(syncSpeedRpm(50, 6), 1000);
      expect(syncSpeedRpm(50, 8), 750);
    });
    test('kayma ve rotor hızı', () {
      expect(slipPercent(1500, 1440), closeTo(4, 1e-9));
      expect(rotorSpeedFromSlip(1500, 4), closeTo(1440, 1e-9));
    });
    test('kutup tahmini', () {
      expect(estimatePoles(50, 1450), 4);
      expect(estimatePoles(50, 2900), 2);
      expect(estimatePoles(50, 960), 6);
    });
    test('geçersiz', () {
      expect(() => syncSpeedRpm(50, 3), throwsA(isA<ValidationException>()));
      expect(() => syncSpeedRpm(0, 4), throwsA(isA<ValidationException>()));
      expect(() => slipPercent(1500, 1600), throwsA(isA<ValidationException>()));
    });
  });

  group('Elektronik', () {
    test('E12', () {
      expect(nextE12(150), closeTo(150, 1e-6));
      expect(nextE12(151), closeTo(180, 1e-6));
      expect(nextE12(0.5), closeTo(0.56, 1e-9));
      expect(nextE12(9500), closeTo(10000, 1e-6));
    });
    test('LED direnci 5 V, 2 V, 20 mA', () {
      final r = ledResistor(vs: 5, vf: 2, iA: 0.02);
      expect(r.r, closeTo(150, 1e-9));
      expect(r.rE12, closeTo(150, 1e-6));
      expect(r.pResistor, closeTo(0.06, 1e-6));
    });
    test('LED geçersiz', () {
      expect(() => ledResistor(vs: 2, vf: 3, iA: 0.02), throwsA(isA<ValidationException>()));
    });
    test('gerilim bölücü', () {
      expect(voltageDivider(vin: 12, r1: 10000, r2: 10000).vout, closeTo(6, 1e-9));
      // Yük Vout'u düşürür: 10k || 10k = 5k -> 12·5/15 = 4 V
      expect(voltageDivider(vin: 12, r1: 10000, r2: 10000, rLoad: 10000).vout, closeTo(4, 1e-9));
    });
    test('RC devresi', () {
      final c = rcCircuit(r: 10000, c: 100e-6, charging: true, v: 12, t: 1);
      expect(c.tau, closeTo(1, 1e-12));
      expect(c.t99, closeTo(5, 1e-12));
      expect(c.percent, closeTo(63.2121, 1e-3));
      expect(c.vc, closeTo(7.58545, 1e-4));
      final d = rcCircuit(r: 10000, c: 100e-6, charging: false, v: 12, t: 1);
      expect(d.vc, closeTo(4.41455, 1e-4));
    });
    test('reaktans ve rezonans', () {
      expect(inductiveReactance(l: 0.1, f: 50), closeTo(31.4159, 1e-3));
      expect(resonanceFrequency(l: 1e-3, c: 1e-6), closeTo(5032.92, 1e-2));
    });
  });

  group('Otomasyon', () {
    test('enkoder devri', () {
      expect(encoderRpm(pulsesPerSecond: 1000, ppr: 360), closeTo(166.667, 1e-3));
    });
    test('konveyör hızı', () {
      final r = conveyorSpeed(motorRpm: 1450, gearRatio: 20, rollerDiameterM: 0.1);
      expect(r.outRpm, closeTo(72.5, 1e-9));
      expect(r.speedMs, closeTo(0.379609, 1e-5));
    });
    test('silindir kuvveti 6 bar, 50 mm, kol 20 mm', () {
      final c = cylinderForce(pressurePa: 600000, boreM: 0.05, rodM: 0.02);
      expect(c.forcePush, closeTo(1178.097, 1e-2));
      expect(c.forcePull!, closeTo(989.602, 1e-2));
      final e = cylinderForce(pressurePa: 600000, boreM: 0.05, eta: 0.9);
      expect(e.forcePush, closeTo(1060.287, 1e-2));
    });
    test('silindir geçersiz', () {
      expect(() => cylinderForce(pressurePa: 1e5, boreM: 0.02, rodM: 0.03),
          throwsA(isA<ValidationException>()));
    });
    test('AWG', () {
      expect(awgDiameterMm(10), closeTo(2.5882, 1e-3));
      expect(awgAreaMm2(10), closeTo(5.2612, 1e-3));
      expect(awgAreaMm2(0), closeTo(53.475, 1e-2));
      expect(nearestAwg(5.26), 10);
      expect(nearestAwg(2.5), 13);
      expect(() => awgDiameterMm(41), throwsA(isA<ValidationException>()));
    });
  });

  group('Simülasyon mantığı', () {
    test('temel devre: kapalı anahtar lambayı yakar', () {
      final s = basicCircuit(volts: 12, lampOhms: 12, switchClosed: true, shorted: false, fuseA: 2, fuseBlown: false);
      expect(s.current, closeTo(1, 1e-9));
      expect(s.lampPower, closeTo(12, 1e-9));
      expect(s.brightness, closeTo(1, 1e-9));
    });
    test('temel devre: açık anahtarda akım yok', () {
      final s = basicCircuit(volts: 12, lampOhms: 12, switchClosed: false, shorted: false, fuseA: 2, fuseBlown: false);
      expect(s.current, 0);
      expect(s.brightness, 0);
    });
    test('kısa devre sigortayı attırır ve sıfırlanana dek kalır', () {
      final s = basicCircuit(volts: 12, lampOhms: 12, switchClosed: true, shorted: true, fuseA: 2, fuseBlown: false);
      expect(s.fuseBlown, isTrue);
      expect(s.current, 0);
      final s2 = basicCircuit(volts: 12, lampOhms: 12, switchClosed: true, shorted: false, fuseA: 2, fuseBlown: true);
      expect(s2.fuseBlown, isTrue);
      expect(s2.brightness, 0);
    });
    test('aşırı akım sigortayı attırır', () {
      final s = basicCircuit(volts: 24, lampOhms: 6, switchClosed: true, shorted: false, fuseA: 2, fuseBlown: false);
      expect(s.fuseBlown, isTrue);
    });
  });

  group('Start-Stop mühürleme', () {
    bool next(bool coil, {bool start = false, bool stop = false, bool estop = false, bool trip = false}) =>
        startStopNext(coil: coil, startPressed: start, stopPressed: stop, eStopPressed: estop, thermalTripped: trip);

    test('start olmadan bobin enerjilenmez', () {
      expect(next(false), isFalse);
    });
    test('start bobini enerjiler, bırakınca mühür tutar', () {
      var coil = next(false, start: true);
      expect(coil, isTrue);
      coil = next(coil); // start bırakıldı
      expect(coil, isTrue);
    });
    test('stop mührü bozar ve bırakınca geri gelmez', () {
      var coil = next(true, stop: true);
      expect(coil, isFalse);
      coil = next(coil);
      expect(coil, isFalse);
    });
    test('acil stop ve termik start basılı olsa da bobini keser', () {
      expect(next(true, estop: true), isFalse);
      expect(next(false, start: true, estop: true), isFalse);
      expect(next(true, trip: true), isFalse);
      expect(next(false, start: true, trip: true), isFalse);
    });
    test('stop basılıyken start çalışmaz', () {
      expect(next(false, start: true, stop: true), isFalse);
    });
  });

  group('Motor simülasyonu', () {
    test('boşta ve tam yük', () {
      final a = motorSim(freq: 50, poles: 4, loadPct: 0);
      expect(a.ns, 1500);
      expect(a.nr, closeTo(1492.5, 1e-9));
      final b = motorSim(freq: 50, poles: 4, loadPct: 100);
      expect(b.slipPct, closeTo(4, 1e-9));
      expect(b.nr, closeTo(1440, 1e-9));
    });
    test('frekans düşünce senkron hız düşer', () {
      expect(motorSim(freq: 25, poles: 4, loadPct: 50).ns, 750);
    });
    test('geçersiz', () {
      expect(() => motorSim(freq: 50, poles: 3, loadPct: 0), throwsA(isA<ValidationException>()));
      expect(() => motorSim(freq: 50, poles: 4, loadPct: 120), throwsA(isA<ValidationException>()));
    });
  });

  group('Pompa ve depo', () {
    test('histerezis', () {
      expect(pumpNext(level: 20, pumpOn: false), isTrue);
      expect(pumpNext(level: 50, pumpOn: true), isTrue);
      expect(pumpNext(level: 50, pumpOn: false), isFalse);
      expect(pumpNext(level: 80, pumpOn: true), isFalse);
      expect(pumpNext(level: 100, pumpOn: true), isFalse);
    });
    test('seviye değişimi sınırlanır', () {
      expect(levelStep(level: 99, pumpOn: true, demandOpen: false, dt: 1), 100);
      expect(levelStep(level: 1, pumpOn: false, demandOpen: true, dt: 1), 0);
      expect(levelStep(level: 50, pumpOn: true, demandOpen: true, dt: 1), closeTo(54, 1e-9));
    });
  });

  group('Trafik lambası', () {
    test('döngü süresi 20 sn', () {
      expect(trafficCycleSeconds, 20);
    });
    test('fazlar', () {
      expect(trafficPhases[trafficAt(0).index].a, Light.green);
      expect(trafficPhases[trafficAt(8.5).index].a, Light.yellow);
      expect(trafficPhases[trafficAt(10.5).index].a, Light.red);
      expect(trafficPhases[trafficAt(10.5).index].b, Light.red);
      expect(trafficPhases[trafficAt(12).index].b, Light.green);
      expect(trafficPhases[trafficAt(20.0).index].a, Light.green);
      expect(trafficAt(1).remaining, closeTo(7, 1e-9));
    });
    test('hiçbir fazda iki yön aynı anda yeşil/sarı olmaz', () {
      for (final p in trafficPhases) {
        final aGo = p.a != Light.red;
        final bGo = p.b != Light.red;
        expect(aGo && bGo, isFalse, reason: p.name);
      }
    });
  });
}
