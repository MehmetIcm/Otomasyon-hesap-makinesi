import 'content_models.dart';

const String _simNote =
    'Bu içerik ve ilgili simülasyon eğitim amaçlıdır. Gerçek pano bağlantısı ve devreye alma yetkin elektrik personelince, geçerli standartlara göre yapılmalıdır.';

const List<Lesson> lessonsMore = [
  // ------------------------------------------------------- Kumanda ve pano
  Lesson(
    id: 'nono',
    group: LessonGroup.control,
    title: 'NO ve NC kontaklar',
    keywords: ['NO', 'NC', 'normalde açık', 'normalde kapalı', 'kontak'],
    definition:
        'NO (normalde açık) kontak, kumanda edilmediğinde açıktır; kumanda edilince kapanır. NC (normalde kapalı) kontak tersidir: normalde kapalıdır, kumanda edilince açılır.',
    whatFor:
        'Buton, röle, kontaktör ve limit switch mantığını anlamanın temelidir.',
    how:
        '“Normal” hal, elemanın enerjisiz veya basılmamış, yani dinlenme durumudur. Start butonu NO, Stop butonu NC seçilir; böylece stop hattındaki kablo koparsa devre durur (güvenli yön).',
    example:
        'Kapı limit switch’i: kapı kapalıyken basılı olan NC kontak, kapı açılınca motor kumandasını keser.',
    symbol: 'contact_no',
    simId: 'startstop',
    related: ['startstop', 'role'],
    quiz: [
      QuizQ('Stop butonu neden genellikle NC seçilir?', ['Kablo kopunca devre durur', 'Daha ucuzdur', 'Daha hızlıdır'], 0, 'NC kontakta hat kopması da durdurma etkisi yapar.'),
      QuizQ('NO kontak enerjisizken nasıldır?', ['Açık', 'Kapalı', 'Arızalı'], 0, 'NO kontak dinlenmede açıktır.'),
      QuizQ('Kumanda edilince NC kontak ne yapar?', ['Açılır', 'Kapanır', 'Aynı kalır'], 0, 'NC kontak kumandada açılır.'),
    ],
  ),
  Lesson(
    id: 'startstop',
    group: LessonGroup.control,
    title: 'Start-Stop ve mühürleme',
    keywords: ['start', 'stop', 'mühürleme', 'self-hold', 'kumanda'],
    definition:
        'Mühürleme (self-hold), kontaktörün kendi yardımcı NO kontağını Start butonuna paralel bağlayarak buton bırakılsa bile bobinin enerjili kalmasını sağlayan devredir.',
    whatFor: 'Motorun tek tuşla başlatılıp tek tuşla durdurulması için kullanılır.',
    how:
        'Start (NO) butonuna basılınca bobin enerjilenir; kontaktörün 13-14 yardımcı kontağı kapanıp Start’a paralel bir yol açar. Start bırakılsa da bobin bu kontaktan beslenmeye devam eder. Stop (NC) basılınca bobin kesilir ve mühür çözülür; tekrar Start gerekir. Termik röle ve acil stop NC kontakları da bobin hattına seri girer. Enerji kesilip geldiğinde motor kendiliğinden yeniden başlamaz.',
    example: 'Matkap tezgâhı, pompa veya fan motorunun kumandası.',
    simId: 'startstop',
    related: ['kontaktor', 'termik', 'acilstop'],
    safety: _simNote,
    quiz: [
      QuizQ('Mühür kontağı Start butonuna nasıl bağlanır?', ['Paralel', 'Seri', 'Bobinin içine'], 0, 'Paralel bağlı kontak, Start bırakılınca bobine alternatif yol sağlar.'),
      QuizQ('Stop’a basınca ne olur?', ['Bobin kesilir, mühür çözülür', 'Motor hızlanır', 'Hiçbir şey olmaz'], 0, 'NC Stop hattı açar; bobin enerjisini kaybeder.'),
      QuizQ('Elektrik kesilip gelirse mühürlemeli devrede motor ne yapar?', ['Kendiliğinden başlamaz, Start gerekir', 'Hemen başlar', 'Yanar'], 0, 'Mühür enerji kesilince çözüldüğünden tekrar Start gerekir.'),
    ],
  ),
  Lesson(
    id: 'kontaktor',
    group: LessonGroup.control,
    title: 'Kontaktör',
    keywords: ['kontaktör', 'ana kontak', 'yardımcı kontak', 'A1 A2'],
    definition:
        'Kontaktör, bobinle kumanda edilen, yüksek akımlı güç devrelerini anahtarlayan elektromekanik şalterdir.',
    whatFor:
        'Motor ve ısıtıcı gibi yüklerin güç devresini kumanda devresinden ayırarak anahtarlamak için kullanılır.',
    how:
        'A1-A2 bobin uçlarıdır. Bobin enerjilenince ana kontaklar (1-2, 3-4, 5-6) kapanır; 13-14 gibi yardımcı NO ve 21-22 gibi NC kontaklar konum değiştirir. Bobin gerilimi (24 V DC, 230 V AC vb.) güç devresinden farklı olabilir. Kontaktör aşırı yük koruması yapmaz; termik röle ile birlikte kullanılır.',
    example: 'Üç fazlı motoru Start-Stop ile çalıştıran K1 kontaktörü.',
    symbol: 'coil',
    simId: 'startstop',
    related: ['startstop', 'termik', 'role'],
    safety: _simNote,
    quiz: [
      QuizQ('A1-A2 uçları neyi gösterir?', ['Bobini', 'Ana kontakları', 'Toprak hattını'], 0, 'A1-A2 kontaktör bobin uçlarıdır.'),
      QuizQ('Kontaktör aşırı yük koruması yapar mı?', ['Hayır, termik röle gerekir', 'Evet, tek başına yeter', 'Sadece kısa devrede'], 0, 'Kontaktör anahtarlar; aşırı yükü termik röle algılar.'),
      QuizQ('Ana kontaklar neyi anahtarlar?', ['Güç devresini', 'Sadece lambayı', 'Haberleşmeyi'], 0, 'Ana kontaklar motor gibi yükün güç hattını anahtarlar.'),
    ],
  ),
  Lesson(
    id: 'termik',
    group: LessonGroup.control,
    title: 'Termik röle',
    keywords: ['termik röle', 'bimetal', 'aşırı yük', '95-96'],
    definition:
        'Termik röle, motor akımı ayarlanan değeri aşınca bimetal şeridin ısınıp bükülmesiyle kontak değiştiren aşırı yük koruma elemanıdır.',
    whatFor: 'Motoru uzun süreli aşırı yükten korumak için kullanılır.',
    how:
        'Motor etiket akımına göre ayarlanır ve ana devreye seri girer. Aşırı yükte 95-96 NC kontağı açılır ve bobin devresi kesilir; 97-98 NO kontağı arıza lambasını yakmak için kullanılabilir. Soğuduktan sonra manuel veya otomatik reset yapılır. Kısa devreyi korumaz; ayrıca sigorta veya manyetik koruma gerekir.',
    example: 'Sıkışan bir konveyör motoru ısınıp termik röleyi attırır.',
    symbol: 'thermal',
    simId: 'startstop',
    related: ['kisadevre', 'kontaktor', 'motoretiket'],
    safety: _simNote,
    quiz: [
      QuizQ('Termik rölenin 95-96 kontağı nasıldır?', ['NC, kumanda hattında', 'NO, güç hattında', 'Toprak kontağı'], 0, '95-96 NC kontağı aşırı yükte açılarak bobin devresini keser.'),
      QuizQ('Termik röle kısa devreyi korur mu?', ['Hayır', 'Evet', 'Yalnızca 3 fazda'], 0, 'Kısa devre için sigorta veya manyetik koruma gerekir.'),
      QuizQ('Ayar akımı neye göre yapılır?', ['Motor etiket akımına', 'Şebeke frekansına', 'Kablo rengine'], 0, 'Termik, motorun etiket akımına göre ayarlanır.'),
    ],
  ),
  Lesson(
    id: 'acilstop',
    group: LessonGroup.control,
    title: 'Acil stop',
    keywords: ['acil stop', 'emniyet', 'mantar buton', 'NC'],
    definition:
        'Acil stop, tehlike anında makineyi durdurmak için kullanılan, kırmızı mantar başlı, genellikle mekanik olarak kilitlenen NC butondur.',
    whatFor: 'Kişi ve makine güvenliğini sağlamak için kullanılır.',
    how:
        'NC kontağı kumanda hattına seri girer; basılınca hat kesilir. NC olduğundan kablo kopması da durdurma etkisi yapar. Basılı kalır; çevirerek veya çekerek serbest bırakılır. Serbest bırakmak makineyi kendiliğinden çalıştırmamalı, ayrıca Start gerekmelidir.',
    example: 'Tezgâh ve konveyör sistemlerinde bulunur.',
    symbol: 'estop',
    simId: 'startstop',
    related: ['nono', 'startstop'],
    safety:
        'Yazılımdaki bir acil stop simülasyonu gerçek emniyet işlevinin yerini tutmaz. Gerçek makinelerde emniyet devreleri ilgili standartlara göre tasarlanır ve doğrulanır.',
    quiz: [
      QuizQ('Acil stop kontağı ne tiptedir?', ['NC', 'NO', 'Analog'], 0, 'NC kontak kablo kopması dahil durdurma sağlar.'),
      QuizQ('Acil stop serbest bırakılınca motor ne yapmalıdır?', ['Kendiliğinden başlamamalı', 'Hemen başlamalı', 'Hızlanmalı'], 0, 'Yeniden başlatma için ayrıca Start gerekir.'),
      QuizQ('Yazılım simülasyonu gerçek emniyet devresinin yerini tutar mı?', ['Hayır', 'Evet', 'Bazen'], 0, 'Emniyet işlevleri standartlara uygun donanımla sağlanır.'),
    ],
  ),

  // ----------------------------------------------------- Asenkron motor
  Lesson(
    id: 'asenkron',
    group: LessonGroup.motor,
    title: 'Asenkron motor ve döner alan',
    keywords: ['asenkron motor', 'stator', 'rotor', 'döner alan', 'kayma'],
    definition:
        'Üç fazlı asenkron motor, statorunda oluşan döner manyetik alanın rotorda akım indüklemesiyle dönen motordur.',
    whatFor:
        'Endüstride pompa, fan, konveyör ve kompresör gibi pek çok uygulamada en yaygın motor türüdür.',
    how:
        'Stator sargılarına uygulanan üç fazlı gerilim, 120° faz farklı akımlar üretir ve senkron hızla (ns = 120 · f / p) dönen bir manyetik alan oluşturur. Rotor bu alanı yakalamaya çalışır ama tam yetişemez; aradaki fark kayma (s) olarak adlandırılır ve moment bu sayede oluşur. Yük arttıkça kayma artar. Yön değiştirmek için iki fazın yeri değiştirilir.',
    example:
        '50 Hz, 4 kutuplu motorda ns = 1500 d/dk; tam yük devri yaklaşık 1450 d/dk civarındadır.',
    symbol: 'motor',
    calcId: 'motorspeed',
    simId: 'motor',
    related: ['yildizucgen', 'motoretiket'],
    safety: _simNote,
    quiz: [
      QuizQ('50 Hz’te 4 kutuplu motorun senkron hızı nedir?', ['1500 d/dk', '3000 d/dk', '1000 d/dk'], 0, 'ns = 120 · 50 / 4 = 1500 d/dk.'),
      QuizQ('Kayma nedir?', ['Senkron hız ile rotor hızı arasındaki farkın oranı', 'Gerilim düşümü', 'Faz sırası'], 0, 's = (ns − nr) / ns.'),
      QuizQ('Yük artınca kayma ne olur?', ['Artar', 'Azalır', 'Sıfırlanır'], 0, 'Daha fazla moment için rotor biraz daha yavaşlar, kayma artar.'),
    ],
  ),
  Lesson(
    id: 'yildizucgen',
    group: LessonGroup.motor,
    title: 'Yıldız ve üçgen bağlantı',
    keywords: ['yıldız', 'üçgen', 'yıldız-üçgen yol verme', 'Y-Δ'],
    definition:
        'Üç fazlı motor sargıları yıldız (Y) veya üçgen (Δ) bağlanabilir. Sargı üzerindeki gerilim bağlantıya göre değişir.',
    whatFor:
        'Motoru şebeke gerilimine uygun bağlamak ve yıldız-üçgen yol vermeyle kalkış akımını azaltmak için bilinmelidir.',
    how:
        'Üçgende her sargı hat gerilimini (örn. 400 V) görür. Yıldızda sargı gerilimi hat geriliminin 1/√3’ü kadardır (400 V’ta yaklaşık 231 V). Yıldız-üçgen yol vermede motor önce yıldız çalıştırılır; kalkış akımı ve momenti doğrudan yol vermenin yaklaşık üçte biri olur. Zaman rölesi bir süre sonra üçgene geçirir. Motor, üçgen bağlantıda şebeke gerilimine uygun olmalıdır (örn. etiket 400 V Δ).',
    example:
        'Etikette 400/690 V Δ/Y yazan motor 400 V şebekede üçgen çalışır; yıldız-üçgen starterle de başlatılabilir.',
    symbol: 'motor',
    calcId: 'motor',
    related: ['asenkron', 'motoretiket'],
    safety:
        'Motor klemens bağlantısı ve pano çalışması yalnızca yetkin personel tarafından yapılmalıdır.',
    quiz: [
      QuizQ('Üçgen bağlantıda sargı gerilimi nedir?', ['Hat gerilimi', 'Hat gerilimi / √3', 'Sıfır'], 0, 'Üçgende sargılar doğrudan hat gerilimini görür.'),
      QuizQ('Yıldız bağlantıda sargı gerilimi nedir?', ['Hat gerilimi / √3', 'Hat gerilimi × √3', 'Hat gerilimi'], 0, 'Yıldızda sargı gerilimi hat geriliminin 1/√3’üdür.'),
      QuizQ('Yıldız-üçgen yol vermede kalkış akımı yaklaşık kaç katına iner?', ['Üçte biri', 'Yarısı', 'Aynı kalır'], 0, 'Yıldızda kalkış akımı doğrudan yol vermenin yaklaşık 1/3’ü olur.'),
    ],
  ),
  Lesson(
    id: 'motoretiket',
    group: LessonGroup.motor,
    title: 'Motor etiketini okuma',
    keywords: ['motor etiketi', 'plaka', 'IP', 'IE', 'yalıtım sınıfı'],
    definition:
        'Motor etiketi (plaka), motorun anma değerlerini, koruma ve yalıtım sınıfını gösterir.',
    whatFor:
        'Doğru bağlantı, koruma ayarı ve kablo/kontaktör seçimi için ilk bilgi kaynağıdır.',
    how:
        'Önemli alanlar: kW (mil gücü), V (Δ/Y gerilimleri), A (Δ/Y akımları), Hz, rpm (tam yük devri), cosφ, verim sınıfı (IE), IP koruma sınıfı, yalıtım sınıfı (örn. F) ve görev tipi (örn. S1: sürekli). Termik röle, etiketteki bağlantı şekline uygun akıma ayarlanır.',
    example:
        'Örnek etiket (yalnızca eğitim amaçlı): 7,5 kW, 400/690 V Δ/Y, 14,8/8,5 A, 50 Hz, 1450 rpm, cosφ 0,85, IE3, IP55, yalıtım F, S1.',
    calcId: 'motor',
    related: ['asenkron', 'yildizucgen', 'termik'],
    quiz: [
      QuizQ('Etiketteki rpm hangi devirdir?', ['Tam yük devri', 'Boşta devir', 'Senkron hız'], 0, 'Etiket devri, anma yükündeki rotor hızıdır.'),
      QuizQ('IP55 neyi anlatır?', ['Toz ve su püskürtmesine karşı koruma', 'Verim sınıfını', 'Kutup sayısını'], 0, 'IP kodu giriş koruma sınıfıdır.'),
      QuizQ('Termik röle hangi akıma göre ayarlanır?', ['Etiket akımına', 'Kalkış akımına', 'Kablo akımına'], 0, 'Ayar, etiketteki bağlantıya uygun anma akımına göre yapılır.'),
    ],
  ),

  // ------------------------------------------------------- PLC ve otomasyon
  Lesson(
    id: 'plctarama',
    group: LessonGroup.plc,
    title: 'PLC ve tarama döngüsü',
    keywords: ['PLC', 'tarama', 'CPU', 'giriş', 'çıkış'],
    definition:
        'PLC (Programlanabilir Mantık Denetleyici), sensörlerden gelen girişleri programa göre işleyip çıkışları süren endüstriyel denetleyicidir.',
    whatFor:
        'Röle panolarının yerine daha esnek, değiştirilebilir ve izlenebilir otomasyon sağlar.',
    how:
        'Ana parçalar: güç kaynağı, CPU, dijital giriş/çıkış ve analog giriş/çıkış modülleri. CPU sürekli döngüde çalışır: girişleri okur → programı çalıştırır → çıkışları günceller. Bu döngüye tarama süresi denir (genellikle milisaniyeler mertebesinde). Marka bağımsız mantık: giriş (sensör) → program → çıkış (aktüatör).',
    example: 'Seviye sensörü (giriş) → pompa mantığı (program) → pompa kontaktörü (çıkış).',
    simId: 'pump',
    related: ['npnpnp', 'analog420'],
    safety:
        'Uygulamadaki mantık eğitim amaçlı simülasyondur; gerçek PLC veya emniyet PLC’si yerine geçmez.',
    quiz: [
      QuizQ('PLC tarama döngüsünün sırası nedir?', ['Giriş oku → program → çıkış yaz', 'Çıkış yaz → giriş oku → program', 'Program → giriş → çıkış'], 0, 'CPU önce girişleri okur, sonra programı işler, en son çıkışları yazar.'),
      QuizQ('Seviye sensörü PLC için nedir?', ['Giriş', 'Çıkış', 'Güç kaynağı'], 0, 'Sensörler PLC’ye bilgi getirir: giriş.'),
      QuizQ('Pompa kontaktörü PLC için nedir?', ['Çıkış', 'Giriş', 'Haberleşme kablosu'], 0, 'Kontaktör bobini PLC çıkışıyla sürülür.'),
    ],
  ),
  Lesson(
    id: 'npnpnp',
    group: LessonGroup.plc,
    title: 'PNP ve NPN sensörler',
    keywords: ['PNP', 'NPN', 'sensör', '24 V DC', 'sink', 'source'],
    definition:
        'PNP ve NPN, üç telli sensörlerin çıkış transistör tipleridir. Aktifken PNP çıkışı +24 V’u yüke verir; NPN çıkışı 0 V’a çeker.',
    whatFor: 'PLC giriş modülüyle uyumlu sensör seçmek için bilinmelidir.',
    how:
        'PNP: sensör aktifken çıkış +24 V olur. NPN: sensör aktifken çıkış 0 V’a çekilir. PLC giriş modülünün bu tipe uygun bağlanması gerekir; uyumsuzsa giriş okunmaz. Avrupa’da PNP daha yaygındır. NO/NC çıkış türü ayrıca seçilir.',
    example:
        '24 V DC, PNP-NO endüktif sensör, metal yaklaşınca PLC girişine +24 V gönderir.',
    related: ['plctarama'],
    quiz: [
      QuizQ('PNP sensör aktifken çıkışı nedir?', ['+24 V verir', '0 V’a çeker', 'Açık devre kalır'], 0, 'PNP çıkış, aktifken pozitif beslemeyi yüke verir.'),
      QuizQ('NPN sensör aktifken çıkışı nedir?', ['0 V’a çeker', '+24 V verir', 'AC verir'], 0, 'NPN çıkış, aktifken yükü 0 V’a bağlar.'),
      QuizQ('Uyumsuz sensör–giriş bağlanırsa ne olur?', ['Giriş okunmaz', 'Daha hızlı çalışır', 'Gerilim yükselir'], 0, 'Giriş tipi ve çıkış tipi uyuşmazsa sinyal algılanamaz.'),
    ],
  ),
  Lesson(
    id: 'analog420',
    group: LessonGroup.plc,
    title: '4–20 mA analog sinyal',
    keywords: ['4-20 mA', '0-10 V', 'analog', 'ölçekleme', 'transmitter'],
    definition:
        '4–20 mA, sensör ölçümünü 4 mA (alt sınır) ile 20 mA (üst sınır) arasında bir akım olarak ileten endüstriyel analog sinyaldir.',
    whatFor:
        'Sıcaklık, basınç, seviye gibi değerleri uzun kablolarda gürültüden az etkilenerek PLC’ye taşımak için kullanılır.',
    how:
        '4 mA ölçüm aralığının alt ucu, 20 mA üst ucudur. Alt sınırın 0 mA yerine 4 mA olması “canlı sıfır” sağlar; 4 mA’in belirgin altı kablo kopukluğu veya arıza belirtisi olabilir. Ölçekleme doğrusaldır: Değer = alt + (I − 4) / 16 × (üst − alt). 0–10 V sinyal de benzer ölçeklenir ama gerilim sinyali uzun hatlarda kayıplara daha duyarlıdır.',
    example: '0–10 bar basınç transmitteri 12 mA veriyorsa basınç 5 bar’dır.',
    calcId: 'plc',
    related: ['plctarama'],
    quiz: [
      QuizQ('0–100 aralığında 12 mA kaç birime karşılık gelir? (4–20 mA)', ['50', '60', '12'], 0, '(12 − 4) / 16 × 100 = 50.'),
      QuizQ('4 mA’in belirgin altındaki sinyal neyi gösterebilir?', ['Kablo kopukluğu veya arıza', 'Maksimum değer', 'Normal ölçüm'], 0, 'Canlı sıfır sayesinde 4 mA altı arıza işareti olabilir.'),
      QuizQ('Akım sinyalinin avantajı nedir?', ['Gürültü ve kablo kaybına dayanıklıdır', 'Daha ucuz sensör gerektirir', 'Sadece kısa mesafede çalışır'], 0, 'Akım döngüsü uzun kablolarda daha kararlıdır.'),
    ],
  ),

  // ------------------------------------------------------------ Kablolar
  Lesson(
    id: 'kablolar',
    group: LessonGroup.cables,
    title: 'Kablo tipleri ve kesit',
    keywords: ['kablo', 'NYM', 'NYY', 'H07V-K', 'N2XH', 'halojensiz'],
    definition:
        'Kablo tipi, iletkenin yapısını, yalıtımını, kılıfını ve kullanım yerini belirler. Kesit (mm²) iletkenin enine kesit alanıdır.',
    whatFor:
        'Doğru yerde doğru kabloyu seçmek; gerilim düşümünü ve ısınmayı kontrol altında tutmak için gereklidir.',
    how:
        'H07V-U (NYA) tek damarlı, H07V-K çok telli esnek iletkendir; boru ve pano içi kullanılır. NYM: PVC kılıflı, sabit iç tesisat kablosudur. NYY: PVC yalıtımlı ve kılıflı, zemin ve dış mekân gibi sert koşullar için kullanılan 0,6/1 kV kablodur. N2XH: XLPE yalıtımlı halojensiz kablodur; yangında az duman ve korozif gaz çıkarır. Büyük kesit daha düşük direnç ve gerilim düşümü demektir; fakat akım taşıma kapasitesi döşeme şekli, ortam sıcaklığı ve gruplamaya da bağlıdır. Koruyucu iletken (PE) genel olarak sarı-yeşildir; renkler için yerel mevzuat ve güncel standartlara bakın.',
    example:
        'Pano içi 24 V DC kumanda için H07V-K; sabit iç tesisatta NYM; toprağa gömülü besleme için NYY.',
    calcId: 'section',
    related: ['kisadevre'],
    safety:
        'Kablo kesiti ve koruma elemanı seçimi için geçerli standartlar ve yetkin uzman gerekir; bu içerik kesin seçim yapmaz.',
    quiz: [
      QuizQ('Pano içi esnek bağlantı için hangi iletken uygundur?', ['H07V-K', 'NYY', 'Çıplak bakır'], 0, 'H07V-K çok telli esnek iletkendir.'),
      QuizQ('Halojensiz kablonun amacı nedir?', ['Yangında az duman ve zehirli gaz', 'Daha yüksek akım', 'Daha ucuz olması'], 0, 'Halojensiz kablolar yangın güvenliği için tasarlanmıştır.'),
      QuizQ('Kesit arttıkça iletken direnci ne olur?', ['Azalır', 'Artar', 'Değişmez'], 0, 'R = ρ · L / S olduğundan kesit arttıkça direnç azalır.'),
    ],
  ),
];
