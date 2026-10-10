import 'package:flutter_test/flutter_test.dart';
import 'package:pro/core/unit_converter.dart';
import 'package:pro/core/validation.dart';

UnitCategory cat(String id) => unitCategories.firstWhere((c) => c.id == id);
UnitDef unit(UnitCategory c, String s) => c.units.firstWhere((u) => u.symbol == s);
double conv(String id, String from, String to, double v) {
  final c = cat(id);
  return convertUnit(c, unit(c, from), unit(c, to), v);
}

void main() {
  test('akım ve gerilim', () {
    expect(conv('current', 'mA', 'A', 250), closeTo(0.25, 1e-12));
    expect(conv('voltage', 'kV', 'V', 0.4), closeTo(400, 1e-9));
  });
  test('güç', () {
    expect(conv('power', 'HP', 'W', 1), closeTo(745.69987, 1e-4));
    expect(conv('power', 'kW', 'HP', 7.5), closeTo(10.0577, 1e-3));
    expect(conv('power', 'PS', 'kW', 100), closeTo(73.549875, 1e-6));
  });
  test('enerji', () {
    expect(conv('energy', 'kWh', 'J', 1), closeTo(3.6e6, 1e-3));
    expect(conv('energy', 'kWh', 'Wh', 2), closeTo(2000, 1e-9));
    expect(conv('energy', 'kcal', 'kJ', 1), closeTo(4.1868, 1e-9));
  });
  test('direnç ve kapasite', () {
    expect(conv('resistance', 'kΩ', 'Ω', 4.7), closeTo(4700, 1e-9));
    expect(conv('capacitance', 'µF', 'nF', 1), closeTo(1000, 1e-9));
    expect(conv('capacitance', 'pF', 'F', 100), closeTo(1e-10, 1e-22));
  });
  test('frekans', () {
    expect(conv('frequency', 'MHz', 'kHz', 2.4), closeTo(2400, 1e-9));
  });
  test('uzunluk ve alan', () {
    expect(conv('length', 'in', 'mm', 1), closeTo(25.4, 1e-9));
    expect(conv('length', 'mi', 'km', 1), closeTo(1.609344, 1e-9));
    expect(conv('area', 'ha', 'm²', 1), closeTo(10000, 1e-9));
    expect(conv('area', 'mm²', 'cm²', 100), closeTo(1, 1e-9));
  });
  test('sıcaklık', () {
    expect(conv('temperature', '°C', '°F', 0), closeTo(32, 1e-9));
    expect(conv('temperature', '°C', 'K', 100), closeTo(373.15, 1e-9));
    expect(conv('temperature', '°F', '°C', 212), closeTo(100, 1e-9));
    expect(conv('temperature', 'K', '°C', 0), closeTo(-273.15, 1e-9));
  });
  test('mutlak sıfırın altı ve geçersiz değer', () {
    expect(() => conv('temperature', '°C', 'K', -300), throwsA(isA<ValidationException>()));
    expect(() => conv('temperature', 'K', '°C', -1), throwsA(isA<ValidationException>()));
    expect(() => conv('current', 'A', 'mA', double.nan), throwsA(isA<ValidationException>()));
  });
  test('gidiş-dönüş tutarlılığı', () {
    for (final c in unitCategories.where((c) => !c.isTemperature)) {
      for (final a in c.units) {
        for (final b in c.units) {
          final there = convertUnit(c, a, b, 3.7);
          final back = convertUnit(c, b, a, there);
          expect(back, closeTo(3.7, 1e-9), reason: '${c.id}: ${a.symbol}->${b.symbol}');
        }
      }
    }
  });
}
