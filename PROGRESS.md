# PROGRESS — Elektrik/Otomasyon Eğitim Platformu Genişletmesi

Durum tarihi: bu oturum. **Hiçbir Dart/Flutter komutu çalıştırılamadı** (ortamda Flutter yok). Kod derlenmedi; `flutter analyze` / `flutter test` / build sonuçları henüz YOK.

## Tamamlanan (yazıldı, çalıştırılarak doğrulanmadı)
- Navigasyon: alt çubuk (Ana Sayfa, Hesapla, Öğren, Simülasyon, Projeler); Sözlük Öğren sekmesinden ve ana sayfadan açılır.
- Genel arama: hesap + ders + sözlük (TR/EN) + proje + simülasyon (`ui/search.dart`).
- Ortak içerik modeli (`data/content_models.dart`): ders, sözlük terimi, proje, mini test.
- 24 ders (6 grup), her biri: anahtar kelimeler, tanım, ne işe yarar, nasıl çalışır, örnek, temsili sembol, ilgili hesap/simülasyon, 3 soruluk test, ilgili konular, güvenlik notu.
- 51 terimlik sözlük (favori, arama, ilgili ders).
- Mini test: anında geri bildirim, gerçek puanlama, en iyi puan yerelde saklanır; ders/proje tamamlama + "devam et".
- 5 simülasyon: temel devre (anahtar/sigorta/kısa devre), Start-Stop mühürleme (termik+acil stop), 3 fazlı motor (döner alan, kayma), depo-pompa (histerezis), trafik lambası. Mantık `core/sim_logic.dart` içinde saf Dart ve testli.
- 3 proje (ortak şablon): Start-Stop, depo-pompa, trafik lambası.
- 8 yeni hesap aracı: motor hızı/kayma, AWG↔mm², LED direnci, gerilim bölücü, RC, reaktans/rezonans, konveyör/enkoder, pnömatik silindir. Birim dönüştürücüye basınç, debi, hız, endüktans, zaman eklendi.
- Testler: `more_calcs_test`, `content_test`, `search_test` eklendi; `registry_test` 22 araca güncellendi.

## Değişen / yeni önemli dosyalar
- Yeni: `lib/core/{more_calcs,sim_logic}.dart`, `lib/data/{content_models,lessons_basic,lessons_more,glossary,projects,content}.dart`, `lib/ui/{shell,calcs_page,learn_page,projects_page,sims_page,search,symbols,draw_utils,quiz_widget}.dart`, `lib/ui/sim/*`
- Değişen: `lib/calculators/registry.dart`, `lib/core/unit_converter.dart`, `lib/data/storage.dart`, `lib/ui/{home_page,app}.dart`, `test/registry_test.dart`

## Kalan işler (öncelik sırasıyla)
1. Derleme/analiz/test: `flutter pub get && flutter analyze && flutter test` — çıkan hataları düzelt.
2. Simülasyonlar (15 eksik): ileri-geri motor, yıldız-üçgen yol verme, zaman rölesi, fotosel, limit switch, konveyör-sensör, analog ölçekleme, Ohm/seri/paralel devreler, sigortalı lamba (kısmen temel devrede), kontaktör+yardımcı kontak (kısmen Start-Stop'ta).
3. Projeler (12 eksik): ileri-geri, Y-Δ, gecikmeli lamba, parça sayma, fotosel, iki sensörlü konveyör, sıcaklık-fan, analog seviye, limit switch, sayaçlı dolum, akıllı sera.
4. Dersler: potansiyometre, zener, transistör, topraklama, otomatik sigorta/KAK, zaman rölesi, limit switch, seçici anahtar, ikaz lambası, motor koruma şalteri, faz koruma, klemens; doğrudan yol verme, ileri/geri; ladder/timer/counter/kenar algılama/interlock; kablo alt konuları; her derse basit devre şeması.
5. Hesaplar: akım bölücü, transistör anahtarlama, diyot, pil/güç kaynağı kapasitesi, Y-Δ hesap yardımcısı, motor çalışma süresi maliyeti; her araca kısa örnek.
6. Görsel kontrol: gerçek cihazda taşma/dokunma alanı denetimi; koyu tema kontrastı.
7. Android build ve imzalı AAB (bkz. KURULUM.md).
