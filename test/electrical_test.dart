import 'package:flutter_test/flutter_test.dart';
import 'package:pro/core/electrical.dart';
import 'package:pro/core/validation.dart';

void main() {
  group('Ohm kanunu', () {
    test('V ve I verilince R ve P', () {
      final r = ohmLaw(v: 12, i: 2);
      expect(r.r, closeTo(6, 1e-9));
      expect(r.p, closeTo(24, 1e-9));
    });
    test('V ve R verilince I ve P', () {
      final r = ohmLaw(v: 230, r: 46);
      expect(r.i, closeTo(5, 1e-9));
      expect(r.p, closeTo(1150, 1e-9));
    });
    test('I ve P verilince V ve R', () {
      final r = ohmLaw(i: 2, p: 100);
      expect(r.v, closeTo(50, 1e-9));
      expect(r.r, closeTo(25, 1e-9));
    });
    test('R ve P verilince V ve I', () {
      final r = ohmLaw(r: 100, p: 25);
      expect(r.v, closeTo(50, 1e-9));
      expect(r.i, closeTo(0.5, 1e-9));
    });
    test('geçersiz girişler', () {
      expect(() => ohmLaw(v: 12), throwsA(isA<ValidationException>()));
      expect(() => ohmLaw(v: 1, i: 1, r: 1), throwsA(isA<ValidationException>()));
      expect(() => ohmLaw(v: 12, r: 0), throwsA(isA<ValidationException>()));
      expect(() => ohmLaw(v: -5, i: 1), throwsA(isA<ValidationException>()));
    });
  });

  group('Elektrik gücü', () {
    test('DC', () {
      final r = electricPower(type: PhaseType.dc, u: 24, i: 5);
      expect(r.pIn, closeTo(120, 1e-9));
      expect(r.q, 0);
    });
    test('tek fazlı AC', () {
      final r = electricPower(type: PhaseType.single, u: 230, i: 10, pf: 0.8);
      expect(r.pIn, closeTo(1840, 1e-6));
      expect(r.s, closeTo(2300, 1e-6));
      expect(r.q, closeTo(1380, 1e-6));
    });
    test('üç fazlı AC ve verim', () {
      final r = electricPower(
          type: PhaseType.three, u: 400, i: 10, pf: 0.8, eta: 0.9);
      expect(r.pIn, closeTo(5542.5626, 1e-3));
      expect(r.s, closeTo(6928.2032, 1e-3));
      expect(r.q, closeTo(4156.9219, 1e-3));
      expect(r.pOut, closeTo(4988.3063, 1e-3));
    });
    test('güçten akım', () {
      final r = electricPower(
          type: PhaseType.three, u: 400, p: 5542.562584220407, pf: 0.8);
      expect(r.i, closeTo(10, 1e-9));
    });
    test('geçersiz girişler', () {
      expect(() => electricPower(type: PhaseType.single, u: 230, i: 1, pf: 1.2),
          throwsA(isA<ValidationException>()));
      expect(() => electricPower(type: PhaseType.single, u: 230),
          throwsA(isA<ValidationException>()));
      expect(() => electricPower(type: PhaseType.dc, u: 0, i: 1),
          throwsA(isA<ValidationException>()));
      expect(() => electricPower(type: PhaseType.dc, u: 12, i: 1, eta: 0),
          throwsA(isA<ValidationException>()));
    });
  });

  group('Enerji ve maliyet', () {
    test('2 kW, 3 saat/gün, 30 gün, 2,5 ₺/kWh', () {
      final r = energyCost(
          powerW: 2000, hoursPerDay: 3, days: 30, quantity: 1, pricePerKwh: 2.5);
      expect(r.dailyKwh, closeTo(6, 1e-9));
      expect(r.kwh, closeTo(180, 1e-9));
      expect(r.cost, closeTo(450, 1e-9));
    });
    test('geçersiz girişler', () {
      expect(
          () => energyCost(powerW: 100, hoursPerDay: 25, days: 1, quantity: 1, pricePerKwh: 1),
          throwsA(isA<ValidationException>()));
      expect(
          () => energyCost(powerW: 100, hoursPerDay: 1, days: 1, quantity: 1, pricePerKwh: -1),
          throwsA(isA<ValidationException>()));
    });
  });

  group('Gerilim düşümü', () {
    test('tek faz, bakır, 16 A, 50 m, 2,5 mm²', () {
      final r = voltageDrop(
          threePhase: false, conductor: Conductor.copper, u: 230, i: 16, lengthM: 50, sectionMm2: 2.5);
      expect(r.dropV, closeTo(11.4286, 1e-3));
      expect(r.dropPct, closeTo(4.9689, 1e-3));
      expect(r.uLoad, closeTo(230 - 11.4286, 1e-3));
    });
    test('üç faz, bakır, 32 A, 100 m, 10 mm², cosφ 0,9', () {
      final r = voltageDrop(
          threePhase: true, conductor: Conductor.copper, u: 400, i: 32, lengthM: 100, sectionMm2: 10, pf: 0.9);
      expect(r.dropV, closeTo(8.9077, 1e-3));
      expect(r.dropPct, closeTo(2.2269, 1e-3));
    });
    test('sıcaklık düzeltmesi (70 °C bakır)', () {
      expect(Conductor.copper.rho(70), closeTo(0.0213661, 1e-6));
      expect(Conductor.copper.rho(20), closeTo(1 / 56, 1e-12));
    });
    test('alüminyum bakırdan fazla düşüm verir', () {
      final cu = voltageDrop(threePhase: false, conductor: Conductor.copper, u: 230, i: 10, lengthM: 30, sectionMm2: 6);
      final al = voltageDrop(threePhase: false, conductor: Conductor.aluminium, u: 230, i: 10, lengthM: 30, sectionMm2: 6);
      expect(al.dropV, greaterThan(cu.dropV));
    });
    test('geçersiz girişler', () {
      expect(
          () => voltageDrop(threePhase: false, conductor: Conductor.copper, u: 230, i: 10, lengthM: 30, sectionMm2: 0),
          throwsA(isA<ValidationException>()));
      expect(
          () => voltageDrop(threePhase: false, conductor: Conductor.copper, u: 12, i: 500, lengthM: 500, sectionMm2: 1.5),
          throwsA(isA<ValidationException>()));
    });
  });

  group('Kablo kesiti', () {
    test('üç faz 400 V, 32 A, 100 m, %3', () {
      final r = cableSection(
          threePhase: true, conductor: Conductor.copper, u: 400, i: 32, lengthM: 100, allowedDropPct: 3);
      expect(r.minSection, closeTo(8.2479, 1e-3));
      expect(r.allowedDropV, closeTo(12, 1e-9));
      expect(r.candidates.map((c) => c.section).toList(), [10, 16, 25]);
      expect(r.candidates.first.dropPct, closeTo(2.4744, 1e-3));
      expect(r.exceedsRange, isFalse);
    });
    test('aralık dışı', () {
      final r = cableSection(
          threePhase: false, conductor: Conductor.copper, u: 12, i: 1000, lengthM: 1000, allowedDropPct: 1);
      expect(r.exceedsRange, isTrue);
      expect(r.candidates, isEmpty);
    });
    test('geçersiz yüzde', () {
      expect(
          () => cableSection(threePhase: false, conductor: Conductor.copper, u: 230, i: 10, lengthM: 30, allowedDropPct: 0),
          throwsA(isA<ValidationException>()));
    });
  });

  group('Güç faktörü', () {
    test('güç üçgeni 3-4-5', () {
      final a = powerTriangle(p: 80, q: 60);
      expect(a.s, closeTo(100, 1e-9));
      expect(a.pf, closeTo(0.8, 1e-9));
      final b = powerTriangle(p: 80, s: 100);
      expect(b.q, closeTo(60, 1e-9));
      final c = powerTriangle(q: 60, s: 100);
      expect(c.p, closeTo(80, 1e-9));
      expect(c.phiDeg, closeTo(36.8699, 1e-3));
    });
    test('güç üçgeni geçersiz', () {
      expect(() => powerTriangle(p: 120, s: 100), throwsA(isA<ValidationException>()));
      expect(() => powerTriangle(p: 1), throwsA(isA<ValidationException>()));
    });
    test('kompanzasyon 100 kW, 0,80 -> 0,95', () {
      final r = pfCompensation(pW: 100000, pf1: 0.8, pf2: 0.95, uLine: 400, freq: 50);
      expect(r.q1, closeTo(75000, 1e-3));
      expect(r.q2, closeTo(32868.41, 1e-1));
      expect(r.qc, closeTo(42131.59, 1e-1));
      expect(r.cDelta!, closeTo(2.7939e-4, 1e-7));
      expect(r.cStar!, closeTo(8.3818e-4, 1e-6));
    });
    test('kompanzasyon geçersiz', () {
      expect(() => pfCompensation(pW: 1000, pf1: 0.95, pf2: 0.9), throwsA(isA<ValidationException>()));
      expect(() => pfCompensation(pW: 1000, pf1: 0.8, pf2: 0.95, uLine: 400),
          throwsA(isA<ValidationException>()));
    });
  });

  group('Üç fazlı motor', () {
    test('7,5 kW, 400 V, cosφ 0,85, η 0,9', () {
      final m = motorFromShaftPower(pOutW: 7500, u: 400, pf: 0.85, eta: 0.9);
      expect(m.pInW, closeTo(8333.333, 1e-2));
      expect(m.current, closeTo(14.1507, 1e-3));
      expect(m.lossW, closeTo(833.333, 1e-2));
      expect(7500 / hpMechanical, closeTo(10.0577, 1e-3));
      expect(7500 / hpMetric, closeTo(10.1972, 1e-3));
    });
    test('akımdan mil gücüne gidiş-dönüş', () {
      final a = motorFromShaftPower(pOutW: 7500, u: 400, pf: 0.85, eta: 0.9);
      final b = motorFromCurrent(i: a.current, u: 400, pf: 0.85, eta: 0.9);
      expect(b.pOutW, closeTo(7500, 1e-6));
    });
    test('geçersiz', () {
      expect(() => motorFromShaftPower(pOutW: 0, u: 400, pf: 0.85, eta: 0.9),
          throwsA(isA<ValidationException>()));
      expect(() => motorFromCurrent(i: 10, u: 400, pf: 1.5, eta: 0.9),
          throwsA(isA<ValidationException>()));
    });
  });
}
