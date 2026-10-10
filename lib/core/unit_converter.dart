import 'electrical.dart' show hpMechanical, hpMetric;
import 'validation.dart';

class UnitDef {
  final String symbol;

  /// Taban birime çarpan (sıcaklıkta kullanılmaz).
  final double factor;
  const UnitDef(this.symbol, this.factor);
}

class UnitCategory {
  final String id;
  final String title;
  final List<UnitDef> units;
  final bool isTemperature;
  const UnitCategory(this.id, this.title, this.units, {this.isTemperature = false});
}

const List<UnitCategory> unitCategories = [
  UnitCategory('current', 'Akım', [
    UnitDef('A', 1), UnitDef('mA', 1e-3), UnitDef('µA', 1e-6), UnitDef('kA', 1e3),
  ]),
  UnitCategory('voltage', 'Gerilim', [
    UnitDef('V', 1), UnitDef('mV', 1e-3), UnitDef('µV', 1e-6),
    UnitDef('kV', 1e3), UnitDef('MV', 1e6),
  ]),
  UnitCategory('power', 'Güç', [
    UnitDef('W', 1), UnitDef('mW', 1e-3), UnitDef('kW', 1e3), UnitDef('MW', 1e6),
    UnitDef('HP', hpMechanical), UnitDef('PS', hpMetric),
    UnitDef('BTU/h', 0.29307107),
  ]),
  UnitCategory('energy', 'Enerji', [
    UnitDef('J', 1), UnitDef('kJ', 1e3), UnitDef('Wh', 3600), UnitDef('kWh', 3.6e6),
    UnitDef('MWh', 3.6e9), UnitDef('cal', 4.1868), UnitDef('kcal', 4186.8),
    UnitDef('BTU', 1055.05585262),
  ]),
  UnitCategory('resistance', 'Direnç', [
    UnitDef('Ω', 1), UnitDef('mΩ', 1e-3), UnitDef('kΩ', 1e3),
    UnitDef('MΩ', 1e6), UnitDef('GΩ', 1e9),
  ]),
  UnitCategory('capacitance', 'Kapasite', [
    UnitDef('F', 1), UnitDef('mF', 1e-3), UnitDef('µF', 1e-6),
    UnitDef('nF', 1e-9), UnitDef('pF', 1e-12),
  ]),
  UnitCategory('frequency', 'Frekans', [
    UnitDef('Hz', 1), UnitDef('kHz', 1e3), UnitDef('MHz', 1e6), UnitDef('GHz', 1e9),
  ]),
  UnitCategory('length', 'Uzunluk', [
    UnitDef('m', 1), UnitDef('mm', 1e-3), UnitDef('cm', 1e-2), UnitDef('km', 1e3),
    UnitDef('in', 0.0254), UnitDef('ft', 0.3048), UnitDef('yd', 0.9144),
    UnitDef('mi', 1609.344),
  ]),
  UnitCategory('area', 'Alan', [
    UnitDef('m²', 1), UnitDef('mm²', 1e-6), UnitDef('cm²', 1e-4), UnitDef('km²', 1e6),
    UnitDef('ha', 1e4), UnitDef('in²', 6.4516e-4), UnitDef('ft²', 0.09290304),
  ]),
  UnitCategory('pressure', 'Basınç', [
    UnitDef('Pa', 1), UnitDef('kPa', 1e3), UnitDef('MPa', 1e6), UnitDef('bar', 1e5),
    UnitDef('mbar', 100), UnitDef('psi', 6894.757293168), UnitDef('atm', 101325),
  ]),
  UnitCategory('flow', 'Debi', [
    UnitDef('m³/s', 1), UnitDef('m³/h', 1 / 3600), UnitDef('L/s', 1e-3),
    UnitDef('L/dk', 1e-3 / 60), UnitDef('L/h', 1e-3 / 3600),
  ]),
  UnitCategory('speed', 'Hız', [
    UnitDef('m/s', 1), UnitDef('m/dk', 1 / 60), UnitDef('km/h', 1 / 3.6),
    UnitDef('mph', 0.44704), UnitDef('ft/s', 0.3048),
  ]),
  UnitCategory('inductance', 'Endüktans', [
    UnitDef('H', 1), UnitDef('mH', 1e-3), UnitDef('µH', 1e-6), UnitDef('nH', 1e-9),
  ]),
  UnitCategory('time', 'Zaman', [
    UnitDef('s', 1), UnitDef('ms', 1e-3), UnitDef('µs', 1e-6), UnitDef('ns', 1e-9),
    UnitDef('dk', 60), UnitDef('saat', 3600), UnitDef('gün', 86400),
  ]),
  UnitCategory('temperature', 'Sıcaklık', [
    UnitDef('°C', 1), UnitDef('°F', 1), UnitDef('K', 1),
  ], isTemperature: true),
];

double _toCelsius(String sym, double v) {
  switch (sym) {
    case '°F':
      return (v - 32) * 5 / 9;
    case 'K':
      return v - 273.15;
    default:
      return v;
  }
}

double _fromCelsius(String sym, double c) {
  switch (sym) {
    case '°F':
      return c * 9 / 5 + 32;
    case 'K':
      return c + 273.15;
    default:
      return c;
  }
}

/// [value] değerini [from] biriminden [to] birimine çevirir.
double convertUnit(UnitCategory cat, UnitDef from, UnitDef to, double value) {
  if (!value.isFinite) {
    throw const ValidationException('Geçerli bir sayı girin.');
  }
  if (cat.isTemperature) {
    final c = _toCelsius(from.symbol, value);
    if (c < -273.15 - 1e-9) {
      throw const ValidationException('Sıcaklık mutlak sıfırın (−273,15 °C) altında olamaz.');
    }
    return _fromCelsius(to.symbol, c);
  }
  return value * from.factor / to.factor;
}
