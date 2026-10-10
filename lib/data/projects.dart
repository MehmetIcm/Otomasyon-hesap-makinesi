import 'content_models.dart';

const String _projSafety =
    'Eğitim amaçlı anlatım ve simülasyondur; gerçek donanım testi değildir. Gerçek pano bağlantısı ve devreye alma yetkin elektrik personelince, geçerli standartlara göre yapılmalıdır.';

const List<Project> allProjects = [
  Project(
    id: 'proj_startstop',
    title: 'Start-Stop ile motor kontrolü',
    purpose:
        'Üç fazlı bir motoru Start ve Stop butonlarıyla kontaktör üzerinden çalıştırıp durdurmak ve mühürleme mantığını öğrenmek.',
    concepts: ['NO / NC kontak', 'Mühürleme', 'Kontaktör', 'Termik koruma', 'Acil stop'],
    parts: [
      'Start butonu (NO)',
      'Stop butonu (NC)',
      'Acil stop (NC)',
      'Kontaktör K1 (bobin, ana kontaklar, 13-14 yardımcı kontak)',
      'Termik röle F2 (95-96 NC)',
      'Üç fazlı asenkron motor M1',
      'Kumanda gerilimi kaynağı ve koruma elemanı',
    ],
    blockDiagram:
        'Kumanda: Kaynak → [Termik NC] → [Acil stop NC] → [Stop NC] → [Start NO ∥ K1 13-14] → K1 bobini → 0 V\n'
        'Güç: Şebeke → Koruma → K1 ana kontaklar → Termik röle → Motor M1',
    ladder:
        '|--[F2 95-96 NC]--[ACİL STOP NC]--[STOP NC]--+--[START NO]--+--( K1 )--|\n'
        '|                                            |              |          |\n'
        '|                                            +--[K1 NO]-----+          |',
    steps: [
      'Başlangıçta K1 bobini enerjisizdir, motor durur.',
      'Start’a basılınca K1 bobini enerjilenir.',
      'K1 ana kontakları kapanır ve motor çalışır; 13-14 yardımcı kontağı kapanarak mührü oluşturur.',
      'Start bırakılır: bobin mühür kontağından beslenir, motor çalışmaya devam eder.',
      'Stop’a basılınca bobin kesilir, kontaklar açılır ve motor durur.',
      'Aşırı yükte termik röle NC kontağı açar; motor durur. Reset sonrası yeniden Start gerekir.',
    ],
    io: [
      'Giriş I0.0: Start (NO)',
      'Giriş I0.1: Stop (NC)',
      'Giriş I0.2: Acil stop (NC)',
      'Giriş I0.3: Termik röle (NC)',
      'Çıkış Q0.0: K1 kontaktör bobini',
    ],
    tweaks: [
      'Simülasyonda termik röleyi attırıp resetleyin.',
      'Stop basılıyken Start’a basın; motorun çalışmadığını görün.',
      'Acil stop kilitliyken Start deneyin.',
    ],
    expected:
        'Start ile çalışır; Stop, acil stop veya termik ile durur ve kendiliğinden yeniden başlamaz.',
    mistakes: [
      'Stop butonunu NO bağlamak (kablo kopunca durmaz).',
      'Mühür kontağını Start’a paralel yerine seri bağlamak.',
      'Termik röleyi etiket akımının çok üzerine ayarlamak.',
      'Kontaktör bobin gerilimini kumanda kaynağına uygun seçmemek.',
    ],
    calcIds: ['motor', 'motorspeed'],
    simId: 'startstop',
    safety: _projSafety,
    quiz: [
      QuizQ('Mühür kontağı hangi elemana paralel bağlanır?', ['Start butonu', 'Stop butonu', 'Motor'], 0, 'Start bırakılınca bobine alternatif yol sağlar.'),
      QuizQ('Stop butonu bobin hattına nasıl girer?', ['Seri, NC', 'Paralel, NO', 'Motorun içine'], 0, 'NC ve seri olduğundan basılınca hattı keser.'),
      QuizQ('Termik röle attığında ne olur?', ['Bobin devresi açılır, motor durur', 'Motor hızlanır', 'Sigorta erir'], 0, 'Termik NC kontağı bobin hattını keser.'),
    ],
  ),
  Project(
    id: 'proj_pump',
    title: 'Depo seviye kontrolü ve pompa',
    purpose:
        'İki seviye sensörüyle depoyu otomatik dolduran pompa mantığını (histerezis) kurmak.',
    concepts: ['Dijital giriş/çıkış', 'Histerezis', 'Mühürleme mantığı', 'Sensör–program–çıkış'],
    parts: [
      'Alt seviye sensörü (S1)',
      'Üst seviye sensörü (S2)',
      'PLC veya kumanda rölesi',
      'Pompa kontaktörü K1 ve termik röle',
      'Pompa motoru',
    ],
    blockDiagram:
        'S1, S2 (giriş) → PLC / kumanda mantığı → K1 kontaktör (çıkış) → Pompa\n'
        'Depo seviyesi sensörlere geri döner (kapalı çevrim).',
    ladder:
        '|--+--[/ I0.0 ALT SEVİYE YOK]--+--[/ I0.1 ÜST SEVİYE YOK]--( Q0.0 POMPA )--|\n'
        '|  |                           |                                        |\n'
        '|  +--[ Q0.0 ]-----------------+                                        |',
    steps: [
      'Seviye alt sensörün altındayken pompa başlar.',
      'Pompa çalışırken seviye yükselir; alt sensör görülünce pompa mühür kontağıyla çalışmaya devam eder.',
      'Seviye üst sensöre ulaşınca pompa durur.',
      'Kullanım nedeniyle seviye düşer; alt sensörün altına inene kadar pompa çalışmaz.',
    ],
    io: [
      'Giriş I0.0: Alt seviye sensörü (su algılayınca 1)',
      'Giriş I0.1: Üst seviye sensörü (su algılayınca 1)',
      'Çıkış Q0.0: Pompa kontaktörü',
    ],
    tweaks: [
      'Simülasyonda kullanım vanasını açıp kapatarak seviye dalgalanmasını izleyin.',
      'Alt ve üst eşik arasındaki farkın pompa çalışma sıklığına etkisini yorumlayın.',
    ],
    expected:
        'Seviye alt ve üst eşik arasında kalır; pompa sık sık aç-kapa yapmaz.',
    mistakes: [
      'Tek sensör kullanmak (pompa çok sık devreye girip çıkar).',
      'Üst seviye sensörü arızalanırsa taşmaya karşı ek emniyet koymamak.',
      'Kuru çalışma koruması düşünmemek.',
    ],
    calcIds: ['power', 'motor'],
    simId: 'pump',
    safety: _projSafety,
    quiz: [
      QuizQ('Histerezis ne sağlar?', ['Pompanın sık aç-kapa yapmasını önler', 'Gerilimi yükseltir', 'Akımı ölçer'], 0, 'İki eşik arasındaki bant, kısa çevrimi engeller.'),
      QuizQ('Pompa hangi seviyede durur?', ['Üst sensör görülünce', 'Alt sensör görülünce', 'Depo boşalınca'], 0, 'Üst seviye sensörü pompayı durdurur.'),
      QuizQ('Pompa kontaktörü PLC için nedir?', ['Çıkış', 'Giriş', 'Sensör'], 0, 'Kontaktör bobini PLC çıkışıyla sürülür.'),
    ],
  ),
  Project(
    id: 'proj_traffic',
    title: 'Trafik lambası (iki yön)',
    purpose:
        'Zamanlayıcılarla sıralı bir mantık kurup iki yönlü kavşağı güvenli bir sırayla yönetmek.',
    concepts: ['Zamanlayıcı', 'Sıralı kontrol', 'Çelişen çıkışların engellenmesi', 'Durum makinesi'],
    parts: [
      'PLC veya zaman rölesi grubu',
      'A yönü: kırmızı, sarı, yeşil lamba',
      'B yönü: kırmızı, sarı, yeşil lamba',
    ],
    blockDiagram:
        'Zamanlayıcı / durum sayacı → faz seçici → A ve B lamba çıkışları',
    ladder:
        'Faz 1: A yeşil 8 s → Faz 2: A sarı 2 s → Faz 3: hepsi kırmızı 1 s\n'
        'Faz 4: B yeşil 6 s → Faz 5: B sarı 2 s → Faz 6: hepsi kırmızı 1 s → Faz 1',
    steps: [
      'A yönü yeşil, B yönü kırmızı: 8 saniye.',
      'A sarı: 2 saniye.',
      'Temizleme aralığı, hepsi kırmızı: 1 saniye.',
      'B yeşil, A kırmızı: 6 saniye.',
      'B sarı: 2 saniye.',
      'Temizleme aralığı ve döngü başa döner.',
    ],
    io: [
      'Çıkış Q0.0–Q0.2: A yönü kırmızı, sarı, yeşil',
      'Çıkış Q0.3–Q0.5: B yönü kırmızı, sarı, yeşil',
    ],
    tweaks: [
      'Simülasyonu duraklatıp fazlar arasında dolaşın.',
      'Yeşil sürelerini uzatıp kısaltmanın döngüye etkisini hesaplayın.',
    ],
    expected:
        'İki yön hiçbir zaman aynı anda yeşil veya sarı olmaz; döngü süresi 20 saniyedir.',
    mistakes: [
      'Temizleme (hepsi kırmızı) aralığını koymamak.',
      'Çıkışları ayrı ayrı zamanlayıp çakışma kontrolü yapmamak.',
    ],
    calcIds: ['pulse'],
    simId: 'traffic',
    safety:
        'Gerçek trafik sinyalizasyonu özel standartlara ve emniyet gereksinimlerine tabidir; bu proje yalnızca mantık öğretimi içindir.',
    quiz: [
      QuizQ('Hepsi kırmızı aralığı neden bırakılır?', ['Kavşağın boşalması için', 'Enerji tasarrufu için', 'Lambaları dinlendirmek için'], 0, 'Önceki yöndeki araçların kavşağı temizlemesi için güvenlik payıdır.'),
      QuizQ('İki yön aynı anda yeşil olabilir mi?', ['Hayır', 'Evet', 'Gece evet'], 0, 'Çelişen yeşil güvenlik hatasıdır.'),
      QuizQ('Bu mantığın temeli nedir?', ['Zamanlayıcıyla sıralı fazlar', 'Analog ölçekleme', 'Frekans dönüştürme'], 0, 'Sıralı faz ve zamanlayıcı kullanılır.'),
    ],
  ),
];
