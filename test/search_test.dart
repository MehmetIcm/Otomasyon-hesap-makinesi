import 'package:flutter_test/flutter_test.dart';
import 'package:pro/core/sim_logic.dart';
import 'package:pro/ui/search.dart';

void main() {
  test('boş arama sonuç vermez', () {
    expect(searchAll('   '), isEmpty);
  });

  test('ohm araması hem hesabı hem dersi bulur', () {
    final kinds = searchAll('ohm').map((h) => h.kind).toSet();
    expect(kinds.contains('Hesaplama'), isTrue);
    expect(kinds.contains('Ders'), isTrue);
  });

  test('Türkçe karakter duyarsız arama', () {
    expect(searchAll('kontaktor').any((h) => h.title == 'Kontaktör'), isTrue);
    expect(searchAll('MÜHÜRLEME').any((h) => h.kind == 'Ders'), isTrue);
  });

  test('sözlükte İngilizce karşılık aranabilir', () {
    expect(searchAll('contactor').any((h) => h.kind == 'Sözlük'), isTrue);
  });

  test('simülasyon ve proje bulunur', () {
    expect(searchAll('trafik').any((h) => h.kind == 'Simülasyon'), isTrue);
    expect(searchAll('depo').any((h) => h.kind == 'Proje'), isTrue);
  });

  test('Start-Stop durum metinleri', () {
    String st({bool coil = false, bool start = false, bool stop = false, bool e = false, bool t = false}) =>
        startStopStatus(coil: coil, startPressed: start, stopPressed: stop, eStopPressed: e, thermalTripped: t);
    expect(st(), contains('Start bekleniyor'));
    expect(st(coil: true), contains('Mühür aktif'));
    expect(st(coil: true, start: true), contains('Start basılı'));
    expect(st(e: true), contains('Acil stop'));
    expect(st(t: true), contains('Termik'));
    expect(st(stop: true), contains('Stop basılı'));
  });
}
