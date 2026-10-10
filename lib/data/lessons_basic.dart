import 'content_models.dart';

const List<Lesson> lessonsBasic = [
  // ----------------------------------------------------- Elektriğin temelleri
  Lesson(
    id: 'akim',
    group: LessonGroup.basics,
    title: 'Akım nedir?',
    keywords: ['akım', 'amper', 'elektron', 'yük akışı'],
    definition:
        'Akım, bir iletkenden birim zamanda geçen elektrik yükü miktarıdır. Birimi amper (A), simgesi I’dır.',
    whatFor:
        'Bir cihazın ne kadar yük çektiğini; kablonun ve koruma elemanının hangi büyüklükte olması gerektiğini anlamak için kullanılır.',
    how:
        'Kapalı bir devrede gerilim kaynağı yükleri harekete geçirir. Akımın yönü teknik olarak artıdan eksiye kabul edilir (konvansiyonel yön); metallerde gerçekte hareket eden elektronlardır. Seri bağlı tüm elemanlardan aynı akım geçer.',
    example:
        'Bir ütü 230 V’ta yaklaşık 10 A çekebilir; bir LED ise yalnızca birkaç miliamper (mA) çeker.',
    symbol: 'battery',
    calcId: 'ohm',
    simId: 'basic',
    related: ['gerilim', 'direnc'],
    quiz: [
      QuizQ('Akımın birimi nedir?', ['Volt', 'Amper', 'Ohm'], 1, 'Akım amper (A) ile ölçülür.'),
      QuizQ('Seri bağlı elemanlarda akım nasıldır?',
          ['Her elemandan aynıdır', 'Elemanlar arasında bölünür', 'Hiç akmaz'], 0,
          'Seri devrede tek yol vardır; aynı akım tüm elemanlardan geçer.'),
      QuizQ('20 mA kaç amperdir?', ['20 A', '0,2 A', '0,02 A'], 2, '1 mA = 0,001 A olduğundan 20 mA = 0,02 A.'),
    ],
  ),
  Lesson(
    id: 'gerilim',
    group: LessonGroup.basics,
    title: 'Gerilim nedir?',
    keywords: ['gerilim', 'volt', 'potansiyel farkı', 'kaynak'],
    definition:
        'Gerilim, iki nokta arasındaki elektriksel potansiyel farkıdır; yükleri harekete geçiren “itici” etkidir. Birimi volt (V).',
    whatFor:
        'Cihazın hangi kaynağa bağlanabileceğini belirler: 12 V DC, 24 V DC, 230 V AC gibi.',
    how:
        'Pil veya şebeke, kaynağın uçları arasında gerilim oluşturur. Devre açıksa gerilim vardır ama akım akmaz. Paralel bağlı elemanların uçlarındaki gerilim aynıdır.',
    example:
        'Kalem pil yaklaşık 1,5 V, araç aküsü yaklaşık 12 V, ev prizi 230 V AC verir.',
    symbol: 'battery',
    calcId: 'ohm',
    simId: 'basic',
    related: ['akim', 'direnc'],
    safety:
        'Şebeke gerilimi (230/400 V) can tehlikesi oluşturur. Bu gerilimlerde yalnızca yetkin personel çalışmalıdır.',
    quiz: [
      QuizQ('Paralel bağlı iki lambanın uçlarındaki gerilim nasıldır?',
          ['Aynıdır', 'Yarıya bölünür', 'Sıfırdır'], 0, 'Paralel kollarda gerilim ortaktır.'),
      QuizQ('Devre açıkken kaynakta ne olur?',
          ['Gerilim vardır, akım yoktur', 'Akım vardır, gerilim yoktur', 'İkisi de yoktur'], 0,
          'Akım için kapalı yol gerekir; gerilim kaynak uçlarında yine vardır.'),
      QuizQ('Gerilim birimi nedir?', ['Watt', 'Farad', 'Volt'], 2, 'Gerilim volt (V) ile ölçülür.'),
    ],
  ),
  Lesson(
    id: 'direnc',
    group: LessonGroup.basics,
    title: 'Direnç ve Ohm kanunu',
    keywords: ['direnç', 'ohm', 'V=IR', 'akım sınırlama'],
    definition:
        'Direnç, bir malzemenin akımın geçişine gösterdiği zorluktur. Birimi ohm (Ω), simgesi R’dir.',
    whatFor:
        'Akımı sınırlamak, gerilim bölmek ve ısı üretmek (ısıtıcılar) için kullanılır.',
    how:
        'Ohm kanunu: V = I · R. Aynı gerilimde direnç artarsa akım azalır. Dirençte harcanan güç ısıya dönüşür: P = I² · R.',
    example:
        'LED’in önüne seri direnç konarak akım güvenli değerde tutulur.',
    symbol: 'resistor',
    calcId: 'ohm',
    simId: 'basic',
    related: ['akim', 'guc', 'diyot'],
    quiz: [
      QuizQ('12 V’a bağlı 6 Ω dirençten kaç amper geçer?', ['0,5 A', '2 A', '72 A'], 1, 'I = V / R = 12 / 6 = 2 A.'),
      QuizQ('Aynı gerilimde direnç artarsa akım ne olur?', ['Artar', 'Azalır', 'Değişmez'], 1, 'I = V / R olduğundan direnç artınca akım azalır.'),
      QuizQ('2 A geçen 10 Ω dirençte güç kaç watttır?', ['20 W', '40 W', '5 W'], 1, 'P = I² · R = 4 · 10 = 40 W.'),
    ],
  ),
  Lesson(
    id: 'guc',
    group: LessonGroup.basics,
    title: 'Güç ve enerji',
    keywords: ['güç', 'watt', 'kWh', 'enerji'],
    definition:
        'Elektrik gücü, birim zamanda dönüştürülen enerjidir. Birimi watt (W); DC’de P = V · I.',
    whatFor: 'Cihazın tüketimini, ısınmasını ve besleme kapasitesini belirler.',
    how:
        '1 W = 1 V × 1 A. Enerji = güç × süre; 1 kW’lık cihaz 1 saatte 1 kWh tüketir (fatura birimi). AC devrelerde aktif (W), reaktif (VAr) ve görünür (VA) güç ayrıdır.',
    example: '2000 W’lık ısıtıcı günde 3 saat çalışırsa 6 kWh tüketir.',
    symbol: 'lamp',
    calcId: 'power',
    related: ['direnc', 'gucfaktoru'],
    quiz: [
      QuizQ('24 V ve 5 A için DC güç kaç watttır?', ['29 W', '120 W', '4,8 W'], 1, 'P = V · I = 24 · 5 = 120 W.'),
      QuizQ('1 kW’lık cihaz 2 saat çalışırsa kaç kWh tüketir?', ['0,5 kWh', '2 kWh', '1 kWh'], 1, 'Enerji = 1 kW × 2 saat = 2 kWh.'),
      QuizQ('Elektrik faturasında hangi birim kullanılır?', ['kWh', 'kVA', 'kV'], 0, 'Tüketilen enerji kWh olarak ölçülür.'),
    ],
  ),
  Lesson(
    id: 'acdc',
    group: LessonGroup.basics,
    title: 'AC ve DC farkı',
    keywords: ['AC', 'DC', 'frekans', 'periyot', 'alternatif akım'],
    definition:
        'DC (doğru akım) yönü sabit akımdır. AC (alternatif akım) yönü ve değeri periyodik olarak değişen akımdır.',
    whatFor:
        'Piller, elektronik devreler ve PLC kumandaları DC; şebeke ve motorlar genellikle AC kullanır.',
    how:
        'Türkiye şebekesi 50 Hz’dir: saniyede 50 tam salınım, periyot 20 ms. Transformatör yalnızca AC ile çalışır; AC’yi DC’ye çevirmek için doğrultucu kullanılır.',
    example: 'Telefon şarj adaptörü 230 V AC’yi 5 V DC’ye çevirir.',
    calcId: 'frequency',
    related: ['gucfaktoru'],
    quiz: [
      QuizQ('Türkiye şebeke frekansı nedir?', ['50 Hz', '60 Hz', '100 Hz'], 0, 'Şebeke frekansı 50 Hz’dir.'),
      QuizQ('50 Hz’in periyodu nedir?', ['2 ms', '20 ms', '50 ms'], 1, 'T = 1 / f = 1 / 50 = 0,02 s = 20 ms.'),
      QuizQ('Hangisi DC kaynaktır?', ['Kalem pil', 'Ev prizi', 'Üç fazlı şebeke'], 0, 'Pil sabit yönlü DC verir.'),
    ],
  ),
  Lesson(
    id: 'gucfaktoru',
    group: LessonGroup.basics,
    title: 'Güç faktörü (cosφ)',
    keywords: ['güç faktörü', 'cosφ', 'reaktif güç', 'kompanzasyon'],
    definition:
        'Güç faktörü, aktif gücün görünür güce oranıdır: cosφ = P / S. Değeri 0 ile 1 arasındadır.',
    whatFor:
        'Motor gibi endüktif yüklerde şebekeden çekilen akımın ne kadarının faydalı işe dönüştüğünü gösterir.',
    how:
        'Endüktif yükler reaktif güç çeker; akım artar ama bu kısım iş yapmaz. cosφ düşükse aynı aktif güç için daha yüksek akım gerekir. Kondansatörlerle kompanzasyon yapılarak iyileştirilir.',
    example:
        '100 kW yük cosφ 0,8’de S = 125 kVA çeker; cosφ 0,95’te yaklaşık 105 kVA çeker.',
    calcId: 'pf',
    related: ['guc', 'kondansator'],
    quiz: [
      QuizQ('Güç faktörü hangi orandır?', ['P / S', 'S / P', 'Q / P'], 0, 'cosφ = aktif güç / görünür güç.'),
      QuizQ('Düşük güç faktörü ne anlama gelir?',
          ['Aynı güç için daha fazla akım', 'Daha az akım', 'Daha yüksek verim'], 0,
          'Aynı aktif güç için görünür güç ve akım artar.'),
      QuizQ('Kompanzasyonda hangi eleman kullanılır?', ['Kondansatör', 'Sigorta', 'Diyot'], 0,
          'Kondansatör, endüktif yükün reaktif gücünü karşılar.'),
    ],
  ),
  Lesson(
    id: 'kisadevre',
    group: LessonGroup.basics,
    title: 'Kısa devre ve aşırı yük',
    keywords: ['kısa devre', 'aşırı yük', 'koruma', 'sigorta'],
    definition:
        'Aşırı yük, devrenin nominal akımından uzun süre fazla akım çekmesidir. Kısa devre ise iletkenler arasında çok düşük dirençli bir yol oluşması ve akımın çok yüksek değerlere çıkmasıdır.',
    whatFor:
        'Hangi koruma elemanının hangi arızada devreye gireceğini ayırt etmek için bilinmesi gerekir.',
    how:
        'Aşırı yükte akım nominalin biraz üzerindedir, ısınma yavaş artar; termik koruma (termik röle, otomatik sigortanın termik elemanı) devreye girer. Kısa devrede akım ani ve çok büyüktür; sigorta veya manyetik koruma çok hızlı keser.',
    example:
        'Sıkışmış bir motor aşırı yüke yol açar; iki çıplak iletkenin birbirine değmesi kısa devredir. Temel devre simülasyonunda ikisini deneyebilirsiniz.',
    simId: 'basic',
    related: ['sigorta', 'termik'],
    safety:
        'Koruma elemanı seçimi ve kısa devre hesabı yetkin personel ve geçerli standartlar gerektirir.',
    quiz: [
      QuizQ('Sıkışan motor hangi arızaya yol açar?', ['Aşırı yük', 'Kısa devre', 'Toprak kaçağı'], 0, 'Motor nominalin üzerinde akım çeker, yavaş ısınır: aşırı yük.'),
      QuizQ('Kısa devrede akım nasıldır?', ['Ani ve çok yüksek', 'Sıfır', 'Nominale yakın'], 0, 'Çok düşük direnç nedeniyle akım çok büyür.'),
      QuizQ('Termik koruma hangi arıza için uygundur?', ['Aşırı yük', 'Sadece kısa devre', 'Gerilim yükselmesi'], 0, 'Termik elemanlar uzun süreli fazla akımda ısınarak devreye girer.'),
    ],
  ),

  // --------------------------------------------------------- Devre elemanları
  Lesson(
    id: 'kondansator',
    group: LessonGroup.components,
    title: 'Kondansatör',
    keywords: ['kondansatör', 'kapasite', 'farad', 'şarj', 'filtre'],
    definition:
        'Kondansatör, iki iletken levha arasında elektrik yükü ve enerji depolayan elemandır. Birimi farad (F); pratikte µF, nF ve pF kullanılır.',
    whatFor:
        'Filtreleme, zamanlama (RC devreleri), motor kalkışı ve güç faktörü kompanzasyonunda kullanılır.',
    how:
        'DC’de dolunca akım durur (DC’yi bloke eder), AC’yi geçirir; reaktansı XC = 1 / (2π · f · C). Frekans arttıkça XC düşer. Elektrolitik kondansatörlerin polaritesi vardır; ters bağlanırsa zarar görür.',
    example:
        'Güç kaynağında dalgalanmayı düzeltir; RC devresinde τ = R · C süresini belirler.',
    symbol: 'capacitor',
    calcId: 'rc',
    related: ['bobin', 'gucfaktoru'],
    safety:
        'Yüklü kondansatörler enerji kesildikten sonra da tehlikeli gerilim taşıyabilir; boşalmasını bekleyin.',
    quiz: [
      QuizQ('Kondansatör DC’de dolduktan sonra akım ne olur?', ['Durur', 'Artar', 'Sabit kalır'], 0, 'Dolu kondansatör DC’yi bloke eder.'),
      QuizQ('Frekans artarsa kapasitif reaktans (XC) ne olur?', ['Azalır', 'Artar', 'Değişmez'], 0, 'XC = 1 / (2π f C) olduğundan frekansla azalır.'),
      QuizQ('Elektrolitik kondansatör ters bağlanırsa ne olabilir?', ['Zarar görebilir', 'Kapasitesi artar', 'Hiçbir şey olmaz'], 0, 'Polariteli kondansatörler ters bağlantıda hasar görür.'),
    ],
  ),
  Lesson(
    id: 'bobin',
    group: LessonGroup.components,
    title: 'Bobin (indüktör)',
    keywords: ['bobin', 'endüktans', 'henri', 'manyetik alan'],
    definition:
        'Bobin, tel sarımından oluşan ve içinden akım geçince manyetik alanda enerji depolayan elemandır. Birimi henri (H).',
    whatFor:
        'Filtreler, röle ve kontaktör bobinleri, transformatörler ve motor sargılarında kullanılır.',
    how:
        'Akımdaki değişime karşı koyar. AC’de reaktansı XL = 2π · f · L; frekans arttıkça artar. Bobin akımı aniden kesilirse yüksek gerilim üretir; bu yüzden DC röle bobinlerine söndürme diyodu bağlanır.',
    example: 'Röle bobini, motor sargısı ve transformatör bobine dayalıdır.',
    symbol: 'inductor',
    calcId: 'reactance',
    related: ['kondansator', 'role', 'diyot'],
    quiz: [
      QuizQ('Frekans artarsa endüktif reaktans (XL) ne olur?', ['Artar', 'Azalır', 'Değişmez'], 0, 'XL = 2π f L olduğundan frekansla artar.'),
      QuizQ('Bobin akımı aniden kesilirse ne oluşur?', ['Yüksek gerilim darbesi', 'Akım artışı', 'Hiçbir şey'], 0, 'Manyetik alan çökerken yüksek gerilim üretir.'),
      QuizQ('DC röle bobinine paralel diyot neden konur?', ['Gerilim darbesini söndürmek için', 'Akımı artırmak için', 'Rengi değiştirmek için'], 0, 'Diyot, bobin kesilince oluşan ters gerilim darbesini bastırır.'),
    ],
  ),
  Lesson(
    id: 'diyot',
    group: LessonGroup.components,
    title: 'Diyot ve LED',
    keywords: ['diyot', 'LED', 'anot', 'katot', 'doğrultucu'],
    definition:
        'Diyot, akımı yalnızca bir yönde ileten yarı iletken elemandır. LED, akım geçince ışık yayan bir diyottur.',
    whatFor:
        'Doğrultma, ters bağlantıya karşı koruma, röle bobini söndürme ve gösterge lambalarında kullanılır.',
    how:
        'Anottan katoda (ileri yönde) yaklaşık 0,6–0,7 V eşik geriliminden (silikon diyot) sonra iletir; ters yönde akım geçirmez. LED’in akımı seri direnç ile sınırlanmalıdır; aksi halde yanar.',
    example:
        '5 V kaynaktan, 2 V ve 20 mA’lik kırmızı LED için seri direnç 150 Ω’dur.',
    symbol: 'led',
    calcId: 'led',
    related: ['direnc', 'bobin'],
    quiz: [
      QuizQ('Diyot akımı nasıl iletir?', ['Tek yönde', 'İki yönde', 'Hiç iletmez'], 0, 'İleri yönde iletir, ters yönde bloke eder.'),
      QuizQ('LED’e neden seri direnç bağlanır?', ['Akımı sınırlamak için', 'Işığı renklendirmek için', 'Gerilimi artırmak için'], 0, 'Direnç olmadan akım LED’i yakacak kadar yükselir.'),
      QuizQ('Silikon diyodun ileri eşik gerilimi yaklaşık kaç volttur?', ['0,7 V', '7 V', '70 V'], 0, 'Silikon diyot yaklaşık 0,6–0,7 V’ta iletmeye başlar.'),
    ],
  ),
  Lesson(
    id: 'role',
    group: LessonGroup.components,
    title: 'Röle',
    keywords: ['röle', 'bobin', 'kontak', 'izolasyon', 'ara röle'],
    definition:
        'Röle, küçük bir kumanda akımıyla bobinini enerjilendirip kontaklarını açıp kapatan elektromekanik anahtardır.',
    whatFor:
        'Düşük gerilimli kumanda ile yüksek gerilimli veya yüksek akımlı devreyi birbirinden yalıtarak anahtarlamak ve mantık oluşturmak için kullanılır.',
    how:
        'Bobin enerjilenince elektromıknatıs armatürü çeker; NO kontaklar kapanır, NC kontaklar açılır. Enerji kesilince yay kontakları eski haline getirir. Kontaklar bobin devresinden elektriksel olarak ayrıdır.',
    example:
        '24 V DC bir PLC çıkışı, ara röle ile 230 V AC’lik bir lambayı kumanda eder.',
    symbol: 'coil',
    related: ['nono', 'kontaktor', 'bobin'],
    quiz: [
      QuizQ('Bobin enerjisizken NO kontak nasıldır?', ['Açık', 'Kapalı', 'Yarı açık'], 0, 'NO (normalde açık) kontak dinlenmede açıktır.'),
      QuizQ('Rölenin başlıca yararı nedir?', ['Küçük akımla büyük yükü yalıtılmış biçimde anahtarlamak', 'Gerilimi yükseltmek', 'Akımı ölçmek'], 0, 'Kumanda ve güç devresi birbirinden ayrılır.'),
      QuizQ('Bobin enerjilenince NC kontak ne yapar?', ['Açılır', 'Kapanır', 'Değişmez'], 0, 'NC kontaklar kumandada konum değiştirip açılır.'),
    ],
  ),
  Lesson(
    id: 'sigorta',
    group: LessonGroup.components,
    title: 'Sigorta',
    keywords: ['sigorta', 'koruma', 'kısa devre', 'nominal akım'],
    definition:
        'Sigorta, aşırı akımda içindeki telin erimesiyle devreyi açan koruma elemanıdır.',
    whatFor: 'Kısa devre ve aşırı akımda iletkeni ve cihazı korumak için kullanılır.',
    how:
        'Nominal akım değeri ve kesme kapasitesi vardır; akım değeri aşılınca ve yeterli süre geçince erir. Eriyen sigorta değiştirilir (otomatik sigorta ise yeniden kurulur). Atma nedeni giderilmeden yenisi takılmamalıdır.',
    example:
        '2 A’lik sigorta, 4 A çeken lamba devresini keser; temel devre simülasyonunda deneyebilirsiniz.',
    symbol: 'fuse',
    simId: 'basic',
    related: ['kisadevre'],
    safety:
        'Sigortayı asla daha yüksek değerli bir sigortayla veya telle değiştirmeyin; kablo korunmasız kalır.',
    quiz: [
      QuizQ('Sigorta attığında ne yapılmalıdır?', ['Neden araştırılıp giderilmelidir', 'Hemen daha büyük sigorta takılmalıdır', 'Tel ile köprülenmelidir'], 0, 'Atma nedeni bulunmadan yeniden devreye almak tehlikelidir.'),
      QuizQ('Daha büyük değerli sigorta takmak neden tehlikelidir?', ['Kablo yeterince korunmaz', 'Daha az ışık verir', 'Gerilim düşer'], 0, 'Sigorta kabloyu korumak için seçilir; büyütmek korumayı bozar.'),
      QuizQ('Sigortanın görevi nedir?', ['Aşırı akımda devreyi açmak', 'Gerilimi yükseltmek', 'Akımı ölçmek'], 0, 'Aşırı akımda erir ve devreyi keser.'),
    ],
  ),
];
