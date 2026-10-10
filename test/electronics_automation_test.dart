import 'package:flutter_test/flutter_test.dart';
import 'package:pro/core/automation.dart';
import 'package:pro/core/electronics.dart';
import 'package:pro/core/validation.dart';

void main() {
  group('Direnç renk kodu', () {
    test('4 bant: kahverengi siyah kırmızı altın = 1 kΩ ±5%', () {
      final r = readResistor([BandColor.brown, BandColor.black, BandColor.red, BandColor.gold]);
      expect(r.ohms, closeTo(1000, 1e-9));
      expect(r.tolPct, 5);
      expect(r.min, closeTo(950, 1e-9));
      expect(r.max, closeTo(1050, 1e-9));
    });
    test('4 bant: sarı mor turuncu gümüş = 47 kΩ ±10%', () {
      final r = readResistor([BandColor.yellow, BandColor.violet, BandColor.orange, BandColor.silver]);
      expect(r.ohms, closeTo(47000, 1e-6));
      expect(r.tolPct, 10);
    });
    test('5 bant: kahverengi siyah siyah kırmızı kahverengi = 10 kΩ ±1%', () {
      final r = readResistor([BandColor.brown, BandColor.black, BandColor.black, BandColor.red, BandColor.brown]);
      expect(r.ohms, closeTo(10000, 1e-9));
      expect(r.tolPct, 1);
    });
    test('6 bant: sıcaklık katsayısı', () {
      final r = readResistor([
        BandColor.red, BandColor.red, BandColor.black, BandColor.brown, BandColor.brown, BandColor.red,
      ]);
      expect(r.ohms, closeTo(2200, 1e-9));
      expect(r.tolPct, 1);
      expect(r.tempCoPpm, 50);
    });
    test('altın çarpan', () {
      final r = readResistor([BandColor.green, BandColor.blue, BandColor.gold, BandColor.gold]);
      expect(r.ohms, closeTo(5.6, 1e-9));
    });
    test('geçersiz bantlar', () {
      expect(() => readResistor([BandColor.black, BandColor.brown, BandColor.red, BandColor.gold]),
          throwsA(isA<ValidationException>()));
      expect(() => readResistor([BandColor.brown, BandColor.black, BandColor.red, BandColor.orange]),
          throwsA(isA<ValidationException>()));
      expect(() => readResistor([BandColor.gold, BandColor.black, BandColor.red, BandColor.gold]),
          throwsA(isA<ValidationException>()));
      expect(() => readResistor([BandColor.brown]), throwsA(isA<ValidationException>()));
    });
  });

  group('Seri ve paralel direnç', () {
    test('seri toplam', () {
      expect(resistorNetwork(parallel: false, r: [100, 200, 300]).req, closeTo(600, 1e-9));
    });
    test('paralel', () {
      expect(resistorNetwork(parallel: true, r: [100, 100]).req, closeTo(50, 1e-9));
      expect(resistorNetwork(parallel: true, r: [10, 20, 30]).req, closeTo(5.4545, 1e-3));
    });
    test('seri gerilim/akım dağılımı', () {
      final n = resistorNetwork(parallel: false, r: [100, 200], v: 12);
      expect(n.iTotal, closeTo(0.04, 1e-9));
      expect(n.vEach![0], closeTo(4, 1e-9));
      expect(n.vEach![1], closeTo(8, 1e-9));
      expect(n.pTotal, closeTo(0.48, 1e-9));
    });
    test('paralel akım dağılımı', () {
      final n = resistorNetwork(parallel: true, r: [100, 200], v: 12);
      expect(n.req, closeTo(66.6667, 1e-3));
      expect(n.iTotal, closeTo(0.18, 1e-9));
      expect(n.iEach![0], closeTo(0.12, 1e-9));
      expect(n.iEach![1], closeTo(0.06, 1e-9));
    });
    test('geçersiz', () {
      expect(() => resistorNetwork(parallel: true, r: []), throwsA(isA<ValidationException>()));
      expect(() => resistorNetwork(parallel: true, r: [10, 0]), throwsA(isA<ValidationException>()));
      expect(() => resistorNetwork(parallel: false, r: [10], v: -1), throwsA(isA<ValidationException>()));
    });
  });

  group('Kondansatör', () {
    test('seri ve paralel', () {
      expect(capacitorEquivalent(series: true, c: [10e-6, 10e-6]), closeTo(5e-6, 1e-15));
      expect(capacitorEquivalent(series: false, c: [1e-6, 2.2e-6]), closeTo(3.2e-6, 1e-15));
    });
    test('reaktans', () {
      expect(capacitiveReactance(c: 100e-6, f: 50), closeTo(31.831, 1e-3));
    });
    test('geçersiz', () {
      expect(() => capacitorEquivalent(series: true, c: [1e-6, -1e-6]), throwsA(isA<ValidationException>()));
      expect(() => capacitiveReactance(c: 1e-6, f: 0), throwsA(isA<ValidationException>()));
    });
  });

  group('Frekans ve periyot', () {
    test('50 Hz = 20 ms', () {
      expect(periodFromFrequency(50), closeTo(0.02, 1e-12));
      expect(frequencyFromPeriod(0.02), closeTo(50, 1e-9));
    });
    test('sıfır frekans geçersiz', () {
      expect(() => periodFromFrequency(0), throwsA(isA<ValidationException>()));
      expect(() => frequencyFromPeriod(-1), throwsA(isA<ValidationException>()));
    });
  });

  group('Darbe hesapları', () {
    test('1 kHz, %25', () {
      final p = pulseFromFreqDuty(1000, 25);
      expect(p.period, closeTo(1e-3, 1e-12));
      expect(p.tOn, closeTo(0.25e-3, 1e-12));
      expect(p.tOff, closeTo(0.75e-3, 1e-12));
    });
    test('2 ms açık, 6 ms kapalı', () {
      final p = pulseFromTimes(2e-3, 6e-3);
      expect(p.period, closeTo(8e-3, 1e-12));
      expect(p.freq, closeTo(125, 1e-9));
      expect(p.dutyPct, closeTo(25, 1e-9));
    });
    test('geçersiz duty', () {
      expect(() => pulseFromFreqDuty(100, 101), throwsA(isA<ValidationException>()));
      expect(() => pulseFromFreqDuty(100, -1), throwsA(isA<ValidationException>()));
      expect(() => pulseFromTimes(0, 1), throwsA(isA<ValidationException>()));
    });
  });

  group('Analog ölçekleme', () {
    test('4-20 mA -> 0-100', () {
      double s(double x) => scaleLinear(x: x, inMin: 4, inMax: 20, outMin: 0, outMax: 100);
      expect(s(4), closeTo(0, 1e-9));
      expect(s(12), closeTo(50, 1e-9));
      expect(s(20), closeTo(100, 1e-9));
      expect(s(3.2), closeTo(-5, 1e-9));
    });
    test('0-10 V -> 0-100', () {
      expect(scaleLinear(x: 2.5, inMin: 0, inMax: 10, outMin: 0, outMax: 100), closeTo(25, 1e-9));
    });
    test('ters yönlü aralık', () {
      expect(scaleLinear(x: 12, inMin: 4, inMax: 20, outMin: 100, outMax: 0), closeTo(50, 1e-9));
    });
    test('sinyalden değere ve geri dönüş', () {
      final y = scaleLinear(x: 7.3, inMin: 4, inMax: 20, outMin: -50, outMax: 150);
      final x = scaleLinear(x: y, inMin: -50, inMax: 150, outMin: 4, outMax: 20);
      expect(x, closeTo(7.3, 1e-9));
    });
    test('oran', () {
      expect(fractionOf(12, 4, 20), closeTo(0.5, 1e-12));
    });
    test('geçersiz aralık', () {
      expect(() => scaleLinear(x: 1, inMin: 5, inMax: 5, outMin: 0, outMax: 1),
          throwsA(isA<ValidationException>()));
      expect(() => fractionOf(1, 5, 5), throwsA(isA<ValidationException>()));
    });
  });
}
