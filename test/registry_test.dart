import 'package:flutter_test/flutter_test.dart';
import 'package:pro/calculators/registry.dart';
import 'package:pro/core/validation.dart';
import 'package:pro/models/calc_models.dart';

CalcResult run(String id, {Map<String, double> n = const {}, Map<String, List<double>> l = const {}, Map<String, int> c = const {}}) {
  final def = findCalc(id)!;
  return def.compute!(CalcInput(n, l, c));
}

void main() {
  test('22 araç kayıtlı ve kimlikler benzersiz', () {
    expect(allCalcs.length, 22);
    expect(allCalcs.map((e) => e.id).toSet().length, allCalcs.length);
    for (final d in allCalcs) {
      expect(d.compute != null || d.customBuilder != null, isTrue, reason: d.id);
    }
  });

  test('alan anahtarları her tanımda benzersiz', () {
    for (final d in allCalcs) {
      final keys = d.fields.map((f) => f.key).toList();
      expect(keys.toSet().length, keys.length, reason: d.id);
    }
  });

  test('Ohm adaptörü', () {
    final r = run('ohm', n: {'v': 12, 'i': 2});
    expect(r.lines.first.label, 'Direnç');
    expect(r.lines.first.text, '6 Ω');
  });

  test('Ohm: iki değer girilmezse hata', () {
    expect(() => run('ohm', n: {'v': 12}), throwsA(isA<ValidationException>()));
  });

  test('Üç fazlı güç adaptörü', () {
    final r = run('power', n: {'u': 400, 'i': 10, 'pf': 0.8, 'eta': 1}, c: {'type': 2});
    expect(r.lines.first.text, startsWith('5,5'));
  });

  test('Direnç renk adaptörü varsayılanları 1 kΩ verir', () {
    // Varsayılan seçimler: kahverengi, siyah, kırmızı çarpan, altın tolerans.
    final r = run('resistor', c: {'n': 0, 'd1': 1, 'd2': 0, 'm': 2, 'tol': 6});
    expect(r.lines.first.text, '1 kΩ');
  });

  test('PLC adaptörü 12 mA -> %50', () {
    final r = run('plc', n: {'x': 12, 'elo': 0, 'ehi': 100}, c: {'dir': 0, 'sig': 0});
    expect(r.lines.first.text, '50');
    expect(r.lines[1].text, '50 %');
  });

  test('Kablo kesiti adaptörü uyarı içerir', () {
    final r = run('section',
        n: {'u': 400, 'i': 32, 'l': 100, 'lim': 3, 'pf': 1, 't': 20}, c: {'ph': 1});
    expect(r.lines.first.text, '10 mm²');
    expect(r.warning, isNotEmpty);
  });

  test('Zaman dönüşümü: 90 s = 1,5 dakika', () {
    final r = run('pulse', n: {'tv': 90}, c: {'mode': 2});
    expect(r.lines.firstWhere((l) => l.label == 'Dakika').value, '1,5');
  });

  test('Konveyör adaptörü', () {
    final r = run('conveyor', n: {'rpm': 1450, 'ratio': 20, 'd': 0.1}, c: {'mode': 0});
    expect(r.lines.first.text, '0,37961 m/s');
  });

  test('Motor hızı adaptörü: 50 Hz 4 kutup 1440 d/dk', () {
    final r = run('motorspeed', n: {'f': 50, 'nr': 1440}, c: {'mode': 0, 'poles': 1});
    expect(r.lines.first.text, '1500 d/dk');
    expect(r.lines[2].value, '4');
  });

  test('Motor hızı adaptörü: kutup tahmini', () {
    final r = run('motorspeed', n: {'f': 50, 'nr2': 1450}, c: {'mode': 1});
    expect(r.lines[1].value, '4');
  });

  test('LED adaptörü', () {
    final r = run('led', n: {'vs': 5, 'vf': 2, 'i': 0.02});
    expect(r.lines.first.text, '150 Ω');
  });

  test('AWG adaptörü tam sayı ister', () {
    expect(() => run('awg', n: {'awg': 10.5}, c: {'mode': 0}), throwsA(isA<ValidationException>()));
  });
}
