import 'package:flutter_test/flutter_test.dart';
import 'package:pro/core/format.dart';

void main() {
  group('fmtNum', () {
    test('ondalık virgül ve gereksiz sıfırlar', () {
      expect(fmtNum(1234.5), '1234,5');
      expect(fmtNum(0.5), '0,5');
      expect(fmtNum(100), '100');
      expect(fmtNum(0), '0');
    });
    test('geçersiz değer', () {
      expect(fmtNum(double.nan), '—');
      expect(fmtNum(double.infinity), '—');
    });
  });

  group('fmtEng', () {
    test('SI önekleri', () {
      expect(fmtEng(4700, 'Ω'), '4,7 kΩ');
      expect(fmtEng(0.0005, 'A'), '500 µA');
      expect(fmtEng(0.001, 'A'), '1 mA');
      expect(fmtEng(2500000, 'Ω'), '2,5 MΩ');
      expect(fmtEng(10, 'V'), '10 V');
      expect(fmtEng(0, 'W'), '0 W');
    });
  });

  group('ayrıştırma', () {
    test('parseNumber virgül ve nokta', () {
      expect(parseNumber('4,7'), 4.7);
      expect(parseNumber(' 12.5 '), 12.5);
      expect(parseNumber(''), isNull);
      expect(parseNumber('abc'), isNull);
    });
    test('parseNumberList', () {
      expect(parseNumberList('1 2;3,5'), [1, 2, 3.5]);
      expect(parseNumberList('1 x'), isNull);
      expect(parseNumberList('   '), isNull);
    });
    test('normalizeTr', () {
      expect(normalizeTr('ÇEKİŞME Işık'), 'cekisme isik');
    });
  });
}
