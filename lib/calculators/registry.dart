import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/automation.dart';
import '../core/electrical.dart';
import '../core/electronics.dart';
import '../core/format.dart';
import '../core/more_calcs.dart';
import '../core/validation.dart';
import '../models/calc_models.dart';
import '../ui/converter_page.dart';

// ------------------------------------------------------------ Ortak birimler
const _vU = [UnitOpt('V'), UnitOpt('mV', 1e-3), UnitOpt('kV', 1e3)];
const _aU = [UnitOpt('A'), UnitOpt('mA', 1e-3), UnitOpt('kA', 1e3)];
const _rU = [
  UnitOpt('Ω'),
  UnitOpt('kΩ', 1e3),
  UnitOpt('MΩ', 1e6),
  UnitOpt('mΩ', 1e-3),
];
const _pU = [UnitOpt('W'), UnitOpt('kW', 1e3), UnitOpt('MW', 1e6)];
const _qU = [UnitOpt('VAr'), UnitOpt('kVAr', 1e3), UnitOpt('MVAr', 1e6)];
const _sU = [UnitOpt('VA'), UnitOpt('kVA', 1e3), UnitOpt('MVA', 1e6)];
const _hzU = [UnitOpt('Hz'), UnitOpt('kHz', 1e3), UnitOpt('MHz', 1e6)];
const _secU = [
  UnitOpt('s'),
  UnitOpt('ms', 1e-3),
  UnitOpt('µs', 1e-6),
  UnitOpt('ns', 1e-9),
];
const _capU = [
  UnitOpt('µF', 1e-6),
  UnitOpt('nF', 1e-9),
  UnitOpt('pF', 1e-12),
  UnitOpt('mF', 1e-3),
  UnitOpt('F'),
];
const _lenU = [UnitOpt('m'), UnitOpt('km', 1e3)];
const _pctU = [UnitOpt('%')];
const _etaU = [UnitOpt('%', 0.01)];
const _motorPU = [
  UnitOpt('kW', 1e3),
  UnitOpt('W'),
  UnitOpt('HP', hpMechanical),
];
const _timeAll = [
  UnitOpt('s'),
  UnitOpt('ms', 1e-3),
  UnitOpt('µs', 1e-6),
  UnitOpt('ns', 1e-9),
  UnitOpt('dakika', 60),
  UnitOpt('saat', 3600),
  UnitOpt('gün', 86400),
];
const _timeNames = [
  'Saniye (s)',
  'Milisaniye (ms)',
  'Mikrosaniye (µs)',
  'Nanosaniye (ns)',
  'Dakika',
  'Saat',
  'Gün',
];

const _prU = [
  UnitOpt('bar', 1e5),
  UnitOpt('kPa', 1e3),
  UnitOpt('MPa', 1e6),
  UnitOpt('psi', 6894.757293168),
  UnitOpt('Pa'),
];
const _dU = [UnitOpt('mm', 1e-3), UnitOpt('cm', 1e-2), UnitOpt('m')];
const _lU = [UnitOpt('H'), UnitOpt('mH', 1e-3), UnitOpt('µH', 1e-6)];
const _ohmOnly = [UnitOpt('Ω'), UnitOpt('kΩ', 1e3), UnitOpt('MΩ', 1e6)];

String _money(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
ResultLine _pct(String label, double v) =>
    ResultLine(label, fmtNum(v, sig: 4), '%');

const String _cableCaution =
    'Bu sonuç yalnızca gerilim düşümü ölçütüne göre ön değerlendirmedir. '
    'Kablonun akım taşıma kapasitesi yalnızca kesite bağlı değildir; döşeme '
    'şekli, ortam sıcaklığı, gruplama, kısa devre dayanımı ve ilgili '
    'standartlar ayrıca kontrol edilmelidir. Kesin kablo kesiti veya koruma '
    'elemanı seçimi yapmaz; gerçek tesisatta yetkili uzman kontrolü gerekir.';

const String _vdropAssumptions =
    'Varsayımlar: Özdirenç 20 °C için bakırda 1/56, alüminyumda 1/35 '
    'Ω·mm²/m alınmıştır; sıcaklık düzeltmesi ρ = ρ20·(1 + α·(T − 20)) ile '
    'yapılır (α bakır 0,00393, alüminyum 0,00403). Reaktans ve kablo '
    'kapasitansı ihmal edilmiştir; büyük kesitlerde ve uzun hatlarda gerçek '
    'düşüm daha yüksek olabilir.';

List<String> _names(List<BandColor> l) => [for (final c in l) c.label];
List<int> _swatches(List<BandColor> l) => [for (final c in l) c.argb];

// ------------------------------------------------------------------ Hesaplar
CalcResult _ohm(CalcInput c) {
  final r = ohmLaw(v: c.opt('v'), i: c.opt('i'), r: c.opt('r'), p: c.opt('p'));
  final items = <(String, String, double, String)>[
    ('v', 'Gerilim', r.v, 'V'),
    ('i', 'Akım', r.i, 'A'),
    ('r', 'Direnç', r.r, 'Ω'),
    ('p', 'Güç', r.p, 'W'),
  ];
  return CalcResult(
    lines: [
      for (final e in items)
        if (c.opt(e.$1) == null) engLine(e.$2, e.$3, e.$4),
      for (final e in items)
        if (c.opt(e.$1) != null) engLine('${e.$2} (girilen)', e.$3, e.$4),
    ],
    formula: 'V = I · R\n'
        'P = V · I = I² · R = V² / R\n'
        'V: gerilim (V), I: akım (A), R: direnç (Ω), P: güç (W)',
    note: 'DC veya saf omik (cosφ = 1) devreler için geçerlidir.',
  );
}

CalcResult _power(CalcInput c) {
  final t = PhaseType.values[c.choice('type')];
  final eta = c.opt('eta') ?? 1.0;
  final r = electricPower(
    type: t,
    u: c.req('u'),
    i: c.opt('i'),
    p: c.opt('p'),
    pf: t == PhaseType.dc ? 1.0 : (c.opt('pf') ?? 1.0),
    eta: eta,
  );
  final formula = switch (t) {
    PhaseType.dc => 'P = U · I\nU: gerilim (V), I: akım (A), P: güç (W)',
    PhaseType.single => 'P = U · I · cosφ\nS = U · I\nQ = √(S² − P²)\n'
        'U: gerilim (V), I: akım (A), cosφ: güç faktörü',
    PhaseType.three => 'P = √3 · U · I · cosφ\nS = √3 · U · I\nQ = √(S² − P²)\n'
        'U: hatlar arası gerilim (V), I: hat akımı (A), cosφ: güç faktörü',
  };
  return CalcResult(
    lines: [
      if (c.opt('p') != null) engLine('Akım (I)', r.i, 'A'),
      engLine('Aktif güç (P)', r.pIn, 'W'),
      if (t != PhaseType.dc) ...[
        engLine('Görünür güç (S)', r.s, 'VA'),
        engLine('Reaktif güç (Q)', r.q, 'VAr'),
      ],
      if (eta < 1) engLine('Çıkış gücü (P × η)', r.pOut, 'W'),
    ],
    formula: eta < 1 ? '$formula\nPçıkış = P · η' : formula,
    note:
        'Girilen güç, şebekeden çekilen aktif (giriş) güç olarak kabul edilir.',
  );
}

CalcResult _energy(CalcInput c) {
  final r = energyCost(
    powerW: c.req('p'),
    hoursPerDay: c.req('h'),
    days: c.req('d'),
    quantity: c.req('n'),
    pricePerKwh: c.req('price'),
  );
  return CalcResult(
    lines: [
      ResultLine('Toplam maliyet', _money(r.cost), '₺'),
      ResultLine('Toplam enerji', fmtNum(r.kwh), 'kWh'),
      ResultLine('Günlük enerji', fmtNum(r.dailyKwh), 'kWh'),
      ResultLine('Günlük maliyet', _money(r.dailyCost), '₺'),
      ResultLine(
          'Yıllık tahmini maliyet (365 gün)', _money(r.dailyCost * 365), '₺'),
    ],
    formula: 'E (kWh) = P (kW) × günlük saat × gün × adet\n'
        'Maliyet = E × birim fiyat (₺/kWh)',
    note: 'Fiyatı faturanızdaki vergiler dahil birim fiyatla girerseniz sonuç '
        'gerçeğe daha yakın olur. Para birimi girdiğiniz fiyat birimidir.',
  );
}

CalcResult _vdrop(CalcInput c) {
  final three = c.choice('ph') == 1;
  final r = voltageDrop(
    threePhase: three,
    conductor: Conductor.values[c.choice('mat')],
    u: c.req('u'),
    i: c.req('i'),
    lengthM: c.req('l'),
    sectionMm2: c.req('s'),
    pf: c.req('pf'),
    tempC: c.req('t'),
  );
  final lim = c.opt('lim');
  final over = lim != null && r.dropPct > lim;
  return CalcResult(
    lines: [
      engLine('Gerilim düşümü (ΔU)', r.dropV, 'V'),
      _pct('Gerilim düşümü (%)', r.dropPct),
      engLine('Yük ucundaki gerilim', r.uLoad, 'V'),
      engLine('İletken direnci (tek iletken)', r.rConductor, 'Ω'),
      engLine('Hat kaybı', r.lossW, 'W'),
      if (lim != null)
        ResultLine('Sınır kontrolü', over ? 'Sınırı aşıyor' : 'Sınır içinde'),
    ],
    formula:
        '${three ? 'ΔU = √3 · L · I · cosφ · ρ / S' : 'ΔU = 2 · L · I · cosφ · ρ / S'}\nΔU% = ΔU / U × 100\nL: tek yön uzunluk (m), I: akım (A), S: kesit (mm²),\nρ: özdirenç (Ω·mm²/m) = ${fmtNum(r.rho, sig: 5)}',
    warning: over
        ? 'Hesaplanan düşüm belirttiğiniz sınırı aşıyor. Daha büyük kesit veya daha kısa hat değerlendirin.'
        : '',
    note: _vdropAssumptions,
  );
}

CalcResult _section(CalcInput c) {
  final three = c.choice('ph') == 1;
  final r = cableSection(
    threePhase: three,
    conductor: Conductor.values[c.choice('mat')],
    u: c.req('u'),
    i: c.req('i'),
    lengthM: c.req('l'),
    allowedDropPct: c.req('lim'),
    pf: c.req('pf'),
    tempC: c.req('t'),
  );
  final first = r.candidates.isEmpty ? null : r.candidates.first;
  return CalcResult(
    lines: [
      first == null
          ? const ResultLine('Önerilen standart kesit', 'Bulunamadı')
          : ResultLine('Gerilim düşümüne göre en küçük standart kesit',
              fmtNum(first.section), 'mm²'),
      ResultLine(
          'Hesaplanan en küçük kesit', fmtNum(r.minSection, sig: 4), 'mm²'),
      engLine('İzin verilen gerilim düşümü', r.allowedDropV, 'V'),
      for (final cand in r.candidates)
        ResultLine(
          '${fmtNum(cand.section)} mm² için ΔU',
          '${fmtNum(cand.dropV, sig: 4)} V (%${fmtNum(cand.dropPct, sig: 3)})',
        ),
    ],
    formula:
        '${three ? 'Smin = √3 · L · I · cosφ · ρ / ΔUizin' : 'Smin = 2 · L · I · cosφ · ρ / ΔUizin'}\nΔUizin = izin verilen % × U / 100\nSonuç, standart kesit serisinden (1,5 … 630 mm²) bir üst değere yuvarlanır.',
    warning: r.exceedsRange
        ? 'Gereken kesit standart serinin (630 mm²) üzerinde. Paralel kablo, daha yüksek gerilim veya farklı hat düzeni değerlendirilmelidir.'
        : 'Akım taşıma kapasitesi, döşeme şekli, ortam sıcaklığı ve standartlar ayrıca kontrol edilmelidir; bu değer yalnızca gerilim düşümü açısından bir ön değerdir.',
    note: _vdropAssumptions,
  );
}

CalcResult _resistor(CalcInput c) {
  final n = c.choice('n');
  final bands = <BandColor>[
    digitColors[c.choice('d1')],
    digitColors[c.choice('d2')],
    if (n != 0) digitColors[c.choice('d3')],
    multiplierColors[c.choice('m')],
    toleranceColors[c.choice('tol')],
    if (n == 2) tempCoColors[c.choice('tc')],
  ];
  final r = readResistor(bands);
  final tc = r.tempCoPpm;
  final formula = switch (n) {
    0 => '(1. rakam 2. rakam) × çarpan, ± tolerans',
    1 => '(1. rakam 2. rakam 3. rakam) × çarpan, ± tolerans',
    _ =>
      '(1. rakam 2. rakam 3. rakam) × çarpan, ± tolerans, sıcaklık katsayısı',
  };
  return CalcResult(
    lines: [
      engLine('Direnç değeri', r.ohms, 'Ω'),
      ResultLine('Tolerans', '±${fmtNum(r.tolPct)}', '%'),
      engLine('En düşük değer', r.min, 'Ω'),
      engLine('En yüksek değer', r.max, 'Ω'),
      if (tc != null) ResultLine('Sıcaklık katsayısı', fmtNum(tc), 'ppm/K'),
      ResultLine('Renk sırası', bands.map((b) => b.label).join(' – ')),
    ],
    formula: formula,
    note: 'Altın çarpan ×0,1, gümüş çarpan ×0,01 anlamına gelir. Okumaya, '
        'tolerans bandından en uzakta olan uçtan başlayın (tolerans bandı '
        'genellikle diğer bantlardan biraz ayrık durur).',
  );
}

CalcResult _network(CalcInput c) {
  final parallel = c.choice('mode') == 1;
  final r = c.list('r');
  final res = resistorNetwork(parallel: parallel, r: r, v: c.opt('v'));
  final lines = <ResultLine>[engLine('Eşdeğer direnç (Reş)', res.req, 'Ω')];
  final iTotal = res.iTotal;
  final pTotal = res.pTotal;
  final vEach = res.vEach;
  final iEach = res.iEach;
  if (iTotal != null && pTotal != null && vEach != null && iEach != null) {
    lines.add(engLine('Toplam akım', iTotal, 'A'));
    lines.add(engLine('Toplam güç', pTotal, 'W'));
    final n = math.min(r.length, 10);
    for (var k = 0; k < n; k++) {
      lines.add(ResultLine(
        'R${k + 1} = ${fmtEng(r[k], 'Ω')}',
        '${fmtEng(vEach[k], 'V')} • ${fmtEng(iEach[k], 'A')}',
      ));
    }
  }
  return CalcResult(
    lines: lines,
    formula: parallel
        ? '1/Reş = 1/R1 + 1/R2 + … + 1/Rn\nParalelde her koldaki gerilim aynıdır: Ii = V / Ri'
        : 'Reş = R1 + R2 + … + Rn\nSeride akım aynıdır: I = V / Reş, Vi = I · Ri',
    note: r.length > 10 && iTotal != null
        ? 'İlk 10 direncin dağılımı gösterildi. Direnç satırları "gerilim • akım" sırasındadır.'
        : (iTotal != null
            ? 'Direnç satırları "gerilim • akım" sırasındadır.'
            : 'Gerilim girerseniz toplam akım, güç ve dağılımlar da hesaplanır.'),
  );
}

CalcResult _capacitor(CalcInput c) {
  final series = c.choice('mode') == 0;
  final ceq = capacitorEquivalent(series: series, c: c.list('c'));
  final f = c.opt('f');
  return CalcResult(
    lines: [
      engLine('Eşdeğer kapasite (Ceş)', ceq, 'F'),
      if (f != null)
        engLine(
            'Kapasitif reaktans (XC)', capacitiveReactance(c: ceq, f: f), 'Ω'),
    ],
    formula:
        '${series ? '1/Ceş = 1/C1 + 1/C2 + … + 1/Cn' : 'Ceş = C1 + C2 + … + Cn'}\nXC = 1 / (2π · f · C)',
    note: 'Seri bağlantıda toplam kapasite en küçük değerden de küçüktür. '
        'Gerçek devrede kondansatörün gerilim değerini ve polaritesini kontrol edin.',
  );
}

CalcResult _frequency(CalcInput c) {
  final fromF = c.choice('mode') == 0;
  final double f;
  final double t;
  if (fromF) {
    f = c.req('f');
    t = periodFromFrequency(f);
  } else {
    t = c.req('t');
    f = frequencyFromPeriod(t);
  }
  final period = engLine('Periyot (T)', t, 's');
  final freq = engLine('Frekans (f)', f, 'Hz');
  return CalcResult(
    lines: [
      if (fromF) period else freq,
      if (fromF) freq else period,
      engLine('Açısal frekans (ω)', 2 * math.pi * f, 'rad/s'),
    ],
    formula: 'T = 1 / f\nf = 1 / T\nω = 2π · f',
  );
}

CalcResult _motor(CalcInput c) {
  final fromPower = c.choice('dir') == 0;
  final u = c.req('u');
  final pf = c.req('pf');
  final eta = c.req('eta');
  final m = fromPower
      ? motorFromShaftPower(pOutW: c.req('p'), u: u, pf: pf, eta: eta)
      : motorFromCurrent(i: c.req('i'), u: u, pf: pf, eta: eta);
  return CalcResult(
    lines: [
      if (fromPower)
        engLine('Şebekeden çekilen akım (I)', m.current, 'A')
      else
        engLine('Mil (çıkış) gücü', m.pOutW, 'W'),
      ResultLine(
        'Mil gücü (kW / HP / PS)',
        '${fmtNum(m.pOutW / 1000, sig: 5)} kW • ${fmtNum(m.pOutW / hpMechanical, sig: 5)} HP • ${fmtNum(m.pOutW / hpMetric, sig: 5)} PS',
      ),
      engLine('Giriş gücü (elektriksel)', m.pInW, 'W'),
      engLine('Görünür güç (S)', m.sVa, 'VA'),
      engLine('Reaktif güç (Q)', m.qVar, 'VAr'),
      engLine('Kayıp güç', m.lossW, 'W'),
    ],
    formula: 'Pgiriş = √3 · U · I · cosφ\n'
        'Pmil = Pgiriş · η\n'
        'I = Pmil / (η · √3 · U · cosφ)\n'
        '1 HP = 745,7 W (mekanik), 1 PS = 735,5 W',
    note:
        'Levha değerlerindeki nominal gerilim, cosφ ve verim kullanılmalıdır. '
        'Kalkış akımı nominal akımın birkaç katıdır; koruma elemanı ve kablo '
        'seçimi için ayrıca değerlendirilmelidir.',
  );
}

CalcResult _pf(CalcInput c) {
  if (c.choice('mode') == 0) {
    final t = powerTriangle(p: c.opt('p'), q: c.opt('q'), s: c.opt('s'));
    return CalcResult(
      lines: [
        ResultLine('Güç faktörü (cosφ)', fmtNum(t.pf, sig: 4)),
        ResultLine('Faz açısı (φ)', fmtNum(t.phiDeg, sig: 4), '°'),
        engLine('Aktif güç (P)', t.p, 'W'),
        engLine('Reaktif güç (Q)', t.q, 'VAr'),
        engLine('Görünür güç (S)', t.s, 'VA'),
      ],
      formula: 'S² = P² + Q²\ncosφ = P / S\nφ = arccos(cosφ)',
      note: 'Reaktif güç endüktif (geri kalan) yük olarak kabul edilmiştir.',
    );
  }
  final r = pfCompensation(
    pW: c.req('pc'),
    pf1: c.req('pf1'),
    pf2: c.req('pf2'),
    uLine: c.opt('uc'),
    freq: c.opt('fc'),
  );
  final i1 = r.i1;
  final i2 = r.i2;
  final cd = r.cDelta;
  final cs = r.cStar;
  return CalcResult(
    lines: [
      engLine('Gereken kompanzasyon gücü (Qc)', r.qc, 'VAr'),
      engLine('Mevcut reaktif güç (Q1)', r.q1, 'VAr'),
      engLine('Hedef reaktif güç (Q2)', r.q2, 'VAr'),
      engLine('Mevcut görünür güç (S1)', r.s1, 'VA'),
      engLine('Hedef görünür güç (S2)', r.s2, 'VA'),
      if (i1 != null && i2 != null) ...[
        engLine('Mevcut hat akımı', i1, 'A'),
        engLine('Hedef hat akımı', i2, 'A'),
      ],
      if (cd != null && cs != null) ...[
        engLine('Kondansatör (üçgen, faz başına)', cd, 'F'),
        engLine('Kondansatör (yıldız, faz başına)', cs, 'F'),
      ],
    ],
    formula: 'Qc = P · (tanφ1 − tanφ2)\n'
        'Üçgen: C = Qc / (3 · ω · U²),  Yıldız: C = Qc / (ω · U²)\n'
        'ω = 2π · f,  I = S / (√3 · U)',
    note: 'Üç fazlı, dengeli yük varsayılmıştır. Harmonikli şebekelerde '
        'rezonans riski için reaktör (detuned) gerekebilir; gerçek kompanzasyon '
        'panosu seçimini uzmana yaptırın.',
  );
}

CalcResult _plc(CalcInput c) {
  const presets = <(double, double, String)>[
    (4.0, 20.0, 'mA'),
    (0.0, 20.0, 'mA'),
    (0.0, 10.0, 'V'),
    (1.0, 5.0, 'V'),
  ];
  final s = c.choice('sig');
  final double lo;
  final double hi;
  final String unit;
  if (s < presets.length) {
    lo = presets[s].$1;
    hi = presets[s].$2;
    unit = presets[s].$3;
  } else {
    lo = c.req('lo');
    hi = c.req('hi');
    unit = '';
  }
  final elo = c.req('elo');
  final ehi = c.req('ehi');
  if (c.choice('dir') == 0) {
    final x = c.req('x');
    final y = scaleLinear(x: x, inMin: lo, inMax: hi, outMin: elo, outMax: ehi);
    final fr = fractionOf(x, lo, hi);
    final out = fr < -1e-9 || fr > 1 + 1e-9;
    var warning = out
        ? 'Sinyal tanımlı aralığın dışında; sonuç aralık dışına taşar (sensör hatası, kalibrasyon veya kablolama kontrol edilmeli).'
        : '';
    if (s == 0 && x < 3.8) {
      warning =
          '$warning${warning.isEmpty ? '' : ' '}4 mA altındaki sinyal kablo kopukluğu veya sensör arızası belirtisi olabilir.';
    }
    return CalcResult(
      lines: [
        numLine('Mühendislik değeri', y),
        _pct('Ölçek yüzdesi', fr * 100),
        ResultLine('12 bit sayı (0–4095)', '${(fr * 4095).round()}'),
        ResultLine('Siemens analog sayı (0–27648)', '${(fr * 27648).round()}'),
      ],
      formula: 'Y = Ymin + (X − Xmin) · (Ymax − Ymin) / (Xmax − Xmin)\n'
          'Sinyal aralığı: ${fmtNum(lo)} … ${fmtNum(hi)} $unit\n'
          'Mühendislik aralığı: ${fmtNum(elo)} … ${fmtNum(ehi)}',
      warning: warning,
      note:
          'Sayısal değerler yaklaşıktır; gerçek modülün çözünürlüğü ve kayması için üretici dokümanına bakın.',
    );
  }
  final y = c.req('y');
  final sig = scaleLinear(x: y, inMin: elo, inMax: ehi, outMin: lo, outMax: hi);
  final fr = fractionOf(y, elo, ehi);
  final out = fr < -1e-9 || fr > 1 + 1e-9;
  return CalcResult(
    lines: [
      ResultLine('Sinyal', fmtNum(sig), unit),
      _pct('Ölçek yüzdesi', fr * 100),
    ],
    formula: 'X = Xmin + (Y − Ymin) · (Xmax − Xmin) / (Ymax − Ymin)\n'
        'Sinyal aralığı: ${fmtNum(lo)} … ${fmtNum(hi)} $unit\n'
        'Mühendislik aralığı: ${fmtNum(elo)} … ${fmtNum(ehi)}',
    warning: out
        ? 'Girilen değer mühendislik aralığının dışında; sinyal aralığı da aşılır.'
        : '',
  );
}

CalcResult _pulse(CalcInput c) {
  final mode = c.choice('mode');
  if (mode == 2) {
    final sec = c.req('tv');
    if (sec < 0) {
      throw const ValidationException('Süre negatif olamaz.');
    }
    return CalcResult(
      lines: [
        for (var k = 0; k < _timeAll.length; k++)
          ResultLine(_timeNames[k], fmtNum(sec / _timeAll[k].factor)),
      ],
      formula: '1 dk = 60 s, 1 saat = 3600 s, 1 gün = 86400 s\n'
          '1 ms = 10⁻³ s, 1 µs = 10⁻⁶ s, 1 ns = 10⁻⁹ s',
    );
  }
  final PulseResult p;
  if (mode == 0) {
    p = pulseFromFreqDuty(c.req('f'), c.req('d'));
  } else {
    p = pulseFromTimes(c.req('on'), c.req('off'));
  }
  final vs = c.opt('vs');
  return CalcResult(
    lines: [
      if (mode == 0) ...[
        engLine('Periyot (T)', p.period, 's'),
        engLine('Açık süre (ON)', p.tOn, 's'),
        engLine('Kapalı süre (OFF)', p.tOff, 's'),
      ] else ...[
        engLine('Frekans (f)', p.freq, 'Hz'),
        engLine('Periyot (T)', p.period, 's'),
        _pct('Çalışma oranı (duty)', p.dutyPct),
      ],
      if (vs != null)
        engLine('Ortalama çıkış gerilimi', vs * p.dutyPct / 100, 'V'),
    ],
    formula: 'T = 1 / f = tON + tOFF\n'
        'Duty = tON / T × 100\n'
        'Vort = Duty/100 × Vçıkış',
    note:
        'Çalışma oranı (duty cycle), sinyalin bir periyotta açık kaldığı süre yüzdesidir.',
  );
}

CalcResult _motorSpeed(CalcInput c) {
  final f = c.req('f');
  final mode = c.choice('mode');
  final nr = mode == 0 ? c.opt('nr') : c.opt('nr2');
  final poles =
      mode == 0 ? 2 * (c.choice('poles') + 1) : estimatePoles(f, c.req('nr2'));
  final ns = syncSpeedRpm(f, poles);
  final slip = nr == null ? null : slipPercent(ns, nr);
  return CalcResult(
    lines: [
      ResultLine('Senkron hız (ns)', fmtNum(ns, sig: 5), 'd/dk'),
      ResultLine(mode == 0 ? 'Kutup sayısı (p)' : 'Tahmin edilen kutup sayısı',
          '$poles'),
      if (nr != null && slip != null) ...[
        ResultLine('Kayma (s)', fmtNum(slip, sig: 4), '%'),
        ResultLine(
            'Rotor frekansı (s · f)', fmtNum(f * slip / 100, sig: 3), 'Hz'),
      ],
    ],
    formula: 'ns = 120 · f / p\ns = (ns − nr) / ns × 100\nf2 = s · f\n'
        'ns: senkron hız (d/dk), f: frekans (Hz), p: kutup sayısı, nr: rotor hızı (d/dk)',
    note:
        'Etiketteki devir, tam yükteki rotor hızıdır ve her zaman senkron hızdan biraz düşüktür. '
        'Örn. 50 Hz, 4 kutup: ns = 1500 d/dk.',
  );
}

CalcResult _led(CalcInput c) {
  final r = ledResistor(vs: c.req('vs'), vf: c.req('vf'), iA: c.req('i'));
  return CalcResult(
    lines: [
      engLine('Hesaplanan seri direnç', r.r, 'Ω'),
      engLine('Seçilecek standart değer (E12)', r.rE12, 'Ω'),
      engLine('Direncin gücü', r.pResistor, 'W'),
      engLine('LED gücü', r.pLed, 'W'),
    ],
    formula: 'R = (Vkaynak − Vf) / If\nP = (Vkaynak − Vf) · If',
    note:
        'Direnç gücü için en az 2 kat pay bırakın. LED ileri gerilimi (Vf) renge ve modele göre değişir; '
        'veri sayfasına bakın. Standart değer, hesaplanana eşit veya bir üst E12 değeridir.',
  );
}

CalcResult _divider(CalcInput c) {
  final rl = c.opt('rl');
  final r = voltageDivider(
      vin: c.req('vin'), r1: c.req('r1'), r2: c.req('r2'), rLoad: rl);
  final unloaded =
      voltageDivider(vin: c.req('vin'), r1: c.req('r1'), r2: c.req('r2'));
  return CalcResult(
    lines: [
      engLine('Çıkış gerilimi (Vout)', r.vout, 'V'),
      engLine('Bölücü akımı', r.current, 'A'),
      engLine('R1 gücü', r.pR1, 'W'),
      engLine('R2 gücü', r.pR2, 'W'),
      if (rl != null) engLine('Yüksüz çıkış gerilimi', unloaded.vout, 'V'),
    ],
    formula:
        'Vout = Vin · R2 / (R1 + R2)\nYük varsa R2 yerine R2 ∥ Ryük kullanılır.',
    note:
        'Gerilim bölücü güç aktarmak için değil, ölçüm/referans için uygundur; yük çıkış gerilimini düşürür.',
  );
}

CalcResult _rc(CalcInput c) {
  final charging = c.choice('mode') == 0;
  final r = rcCircuit(
      r: c.req('r'),
      c: c.req('c'),
      charging: charging,
      v: c.opt('v'),
      t: c.opt('t'));
  final vc = r.vc;
  final pct = r.percent;
  return CalcResult(
    lines: [
      engLine('Zaman sabiti (τ)', r.tau, 's'),
      engLine('5τ (yaklaşık %99,3 tamamlanma)', r.t99, 's'),
      if (pct != null)
        ResultLine(charging ? 'Şarj düzeyi' : 'Kalan gerilim oranı',
            fmtNum(pct, sig: 4), '%'),
      if (vc != null) engLine('Kondansatör gerilimi (Vc)', vc, 'V'),
    ],
    formula:
        'τ = R · C\nŞarj: Vc = V · (1 − e^(−t/τ))\nDeşarj: Vc = V · e^(−t/τ)',
    note:
        'Gerilim ve süre girerseniz o andaki kondansatör gerilimi de hesaplanır.',
  );
}

CalcResult _reactance(CalcInput c) {
  final f = c.req('f');
  final l = c.opt('l');
  final cap = c.opt('c');
  if (l == null && cap == null) {
    throw const ValidationException(
        'Endüktans veya kapasite değerlerinden en az birini girin.');
  }
  return CalcResult(
    lines: [
      if (l != null)
        engLine('Endüktif reaktans (XL)', inductiveReactance(l: l, f: f), 'Ω'),
      if (cap != null)
        engLine(
            'Kapasitif reaktans (XC)', capacitiveReactance(c: cap, f: f), 'Ω'),
      if (l != null && cap != null)
        engLine(
            'Rezonans frekansı (f0)', resonanceFrequency(l: l, c: cap), 'Hz'),
    ],
    formula: 'XL = 2π · f · L\nXC = 1 / (2π · f · C)\nf0 = 1 / (2π · √(L · C))',
    note:
        'Reaktans omik dirençten farklıdır; akım ile gerilim arasında faz farkı oluşturur.',
  );
}

CalcResult _conveyor(CalcInput c) {
  if (c.choice('mode') == 1) {
    final rpm = encoderRpm(pulsesPerSecond: c.req('pps'), ppr: c.req('ppr'));
    return CalcResult(
      lines: [
        ResultLine('Devir', fmtNum(rpm, sig: 5), 'd/dk'),
        ResultLine('Devir', fmtNum(rpm / 60, sig: 5), 'devir/s'),
      ],
      formula: 'n = (darbe/s) / PPR × 60',
      note:
          'PPR: enkoderin bir tam devirdeki darbe sayısı. Dörtlü (x4) sayımda darbe frekansı 4 kat görünür.',
    );
  }
  final r = conveyorSpeed(
      motorRpm: c.req('rpm'),
      gearRatio: c.req('ratio'),
      rollerDiameterM: c.req('d'));
  return CalcResult(
    lines: [
      ResultLine('Bant hızı', fmtNum(r.speedMs, sig: 5), 'm/s'),
      ResultLine('Bant hızı', fmtNum(r.speedMs * 60, sig: 5), 'm/dk'),
      ResultLine('Bant hızı', fmtNum(r.speedMs * 3.6, sig: 5), 'km/h'),
      ResultLine('Tambur devri', fmtNum(r.outRpm, sig: 5), 'd/dk'),
    ],
    formula: 'ntambur = nmotor / i\nv = ntambur · π · D / 60',
    note:
        'i: redüktör oranı, D: tambur çapı. Kayma ve yük altındaki devir düşüşü ihmal edilmiştir.',
  );
}

CalcResult _cylinder(CalcInput c) {
  final r = cylinderForce(
    pressurePa: c.req('p'),
    boreM: c.req('d'),
    rodM: c.opt('rod'),
    eta: c.req('eta'),
  );
  final pull = r.forcePull;
  final aPull = r.areaPull;
  return CalcResult(
    lines: [
      engLine('İleri (itme) kuvveti', r.forcePush, 'N'),
      ResultLine(
          'İleri kuvvet (kgf)', fmtNum(r.forcePush / 9.80665, sig: 5), 'kgf'),
      ResultLine('Piston alanı', fmtNum(r.areaPush * 1e4, sig: 5), 'cm²'),
      if (pull != null && aPull != null) ...[
        engLine('Geri (çekme) kuvveti', pull, 'N'),
        ResultLine('Halka alanı', fmtNum(aPull * 1e4, sig: 5), 'cm²'),
      ],
    ],
    formula:
        'A = π · D² / 4\nİleri: F = P · A · η\nGeri: F = P · (π/4 · (D² − d²)) · η',
    note:
        'Basınç etkin (manometre) basınçtır. Sürtünme, yük ve hava tüketimi ayrıca değerlendirilir; '
        'seçimde emniyet payı bırakın. Basınçlı sistemlerde güvenlik kurallarına uyun.',
  );
}

CalcResult _awg(CalcInput c) {
  if (c.choice('mode') == 0) {
    final v = c.req('awg');
    if (v != v.roundToDouble()) {
      throw const ValidationException(
          'AWG numarası tam sayı olmalıdır (0000 için −3, 000 için −2, 00 için −1).');
    }
    final n = v.toInt();
    return CalcResult(
      lines: [
        ResultLine('Kesit', fmtNum(awgAreaMm2(n), sig: 4), 'mm²'),
        ResultLine('Tel çapı', fmtNum(awgDiameterMm(n), sig: 4), 'mm'),
      ],
      formula: 'd (mm) = 0,127 · 92^((36 − n) / 39)\nA = π · d² / 4',
      note:
          'Tek telli iletken için geçerlidir. Çok telli kablolarda etkin kesit ve akım taşıma kapasitesi farklıdır.',
    );
  }
  final n = nearestAwg(c.req('area'));
  return CalcResult(
    lines: [
      ResultLine('En yakın AWG', n < 0 ? '${'0' * (1 - n)} (AWG)' : '$n'),
      ResultLine('AWG kesiti', fmtNum(awgAreaMm2(n), sig: 4), 'mm²'),
      ResultLine('Tel çapı', fmtNum(awgDiameterMm(n), sig: 4), 'mm'),
    ],
    formula:
        'AWG kesiti: A = π/4 · (0,127 · 92^((36 − n) / 39))²\nİstenen kesite en yakın n seçilir.',
    note:
        'AWG ile mm² arasındaki eşleşme yaklaşıktır. Akım taşıma kapasitesi için standart tablolara ve '
        'döşeme koşullarına bakın; bu araç kesin seçim yapmaz.',
  );
}

// ------------------------------------------------------------- Kayıt listesi
final List<CalcDef> allCalcs = [
  CalcDef(
    id: 'ohm',
    title: 'Ohm Kanunu',
    subtitle: 'Gerilim, akım, direnç ve güç: iki değerden diğerleri',
    keywords: 'ohm volt amper direnc guc v i r p',
    category: CalcCategory.electric,
    icon: Icons.bolt,
    fields: [
      FieldDef.number('v', 'Gerilim (V)',
          units: _vU,
          required: false,
          hint: 'Dört alandan tam olarak ikisini doldurun'),
      FieldDef.number('i', 'Akım (I)', units: _aU, required: false),
      FieldDef.number('r', 'Direnç (R)', units: _rU, required: false),
      FieldDef.number('p', 'Güç (P)', units: _pU, required: false),
    ],
    compute: _ohm,
  ),
  CalcDef(
    id: 'power',
    title: 'Elektrik Gücü',
    subtitle: 'DC, tek fazlı ve üç fazlı AC güç hesapları',
    keywords: 'guc watt kw dc ac tek faz uc faz akim gerilim verim cos',
    category: CalcCategory.electric,
    icon: Icons.electric_bolt,
    fields: [
      FieldDef.choice('type', 'Sistem', ['DC', 'Tek fazlı AC', 'Üç fazlı AC'],
          optionIndex: 1),
      FieldDef.number('u', 'Gerilim (U)',
          units: _vU,
          defaultText: '230',
          hint: 'Üç fazlıda hatlar arası gerilim (ör. 400 V)'),
      FieldDef.number('i', 'Akım (I)',
          units: _aU,
          required: false,
          hint: 'Akım veya aktif güçten yalnızca birini girin'),
      FieldDef.number('p', 'Aktif güç (P)', units: _pU, required: false),
      FieldDef.number('pf', 'Güç faktörü (cosφ)',
          defaultText: '1',
          hint: '0 ile 1 arasında',
          visible: (c) => c['type'] != 0),
      FieldDef.number('eta', 'Verim (η)', units: _etaU, defaultText: '100'),
    ],
    compute: _power,
  ),
  CalcDef(
    id: 'energy',
    title: 'Enerji Tüketimi ve Maliyet',
    subtitle: 'kWh tüketimi ve birim fiyata göre maliyet',
    keywords: 'enerji kwh maliyet fatura tuketim elektrik fiyat',
    category: CalcCategory.electric,
    icon: Icons.payments,
    fields: [
      FieldDef.number('p', 'Cihaz gücü', units: _pU, defaultText: '1000'),
      FieldDef.number('h', 'Günlük çalışma süresi',
          units: const [UnitOpt('saat'), UnitOpt('dakika', 1 / 60)],
          defaultText: '8'),
      FieldDef.number('d', 'Çalışılan gün sayısı',
          units: const [UnitOpt('gün')], defaultText: '30'),
      FieldDef.number('n', 'Adet',
          units: const [UnitOpt('adet')], defaultText: '1'),
      FieldDef.number('price', 'Birim enerji fiyatı',
          units: const [UnitOpt('₺/kWh')],
          hint: 'Faturanızdaki kWh başına fiyat'),
    ],
    compute: _energy,
  ),
  CalcDef(
    id: 'motor',
    title: 'Üç Fazlı Motor',
    subtitle: 'Güç, akım, cosφ, verim ve kW/HP dönüşümü',
    keywords: 'motor uc faz asenkron hp beygir kw akim verim cos',
    category: CalcCategory.electric,
    icon: Icons.settings,
    fields: [
      FieldDef.choice(
          'dir', 'Hesap yönü', ['Mil gücünden akım', 'Akımdan mil gücü']),
      FieldDef.number('p', 'Mil (çıkış) gücü',
          units: _motorPU, defaultText: '7,5', visible: (c) => c['dir'] == 0),
      FieldDef.number('i', 'Hat akımı (I)',
          units: _aU, visible: (c) => c['dir'] == 1),
      FieldDef.number('u', 'Hat gerilimi (U)', units: _vU, defaultText: '400'),
      FieldDef.number('pf', 'Güç faktörü (cosφ)',
          defaultText: '0,85', hint: 'Motor etiketindeki değer'),
      FieldDef.number('eta', 'Verim (η)',
          units: _etaU, defaultText: '90', hint: 'Motor etiketindeki değer'),
    ],
    compute: _motor,
  ),
  CalcDef(
    id: 'pf',
    title: 'Güç Faktörü',
    subtitle: 'Güç üçgeni ve kompanzasyon için reaktif güç',
    keywords: 'guc faktoru cos reaktif kompanzasyon kvar kondansator',
    category: CalcCategory.electric,
    icon: Icons.show_chart,
    fields: [
      FieldDef.choice('mode', 'Hesap türü',
          ['Güç üçgeni (P, Q, S)', 'Kompanzasyon (üç fazlı)']),
      FieldDef.number('p', 'Aktif güç (P)',
          units: _pU,
          required: false,
          hint: 'P, Q, S değerlerinden ikisini girin',
          visible: (c) => c['mode'] == 0),
      FieldDef.number('q', 'Reaktif güç (Q)',
          units: _qU, required: false, visible: (c) => c['mode'] == 0),
      FieldDef.number('s', 'Görünür güç (S)',
          units: _sU, required: false, visible: (c) => c['mode'] == 0),
      FieldDef.number('pc', 'Aktif güç (P)',
          units: _pU,
          unitIndex: 1,
          defaultText: '100',
          visible: (c) => c['mode'] == 1),
      FieldDef.number('pf1', 'Mevcut güç faktörü',
          defaultText: '0,80', visible: (c) => c['mode'] == 1),
      FieldDef.number('pf2', 'Hedef güç faktörü',
          defaultText: '0,95', visible: (c) => c['mode'] == 1),
      FieldDef.number('uc', 'Hat gerilimi (isteğe bağlı)',
          units: _vU,
          required: false,
          hint: 'Kondansatör kapasitesi ve akım için',
          visible: (c) => c['mode'] == 1),
      FieldDef.number('fc', 'Frekans',
          units: const [UnitOpt('Hz')],
          required: false,
          defaultText: '50',
          visible: (c) => c['mode'] == 1),
    ],
    compute: _pf,
  ),
  CalcDef(
    id: 'vdrop',
    title: 'Gerilim Düşümü',
    subtitle: 'Tek ve üç fazlı hatlarda gerilim düşümü',
    keywords: 'gerilim dusumu kablo kesit uzunluk bakir aluminyum hat kaybi',
    category: CalcCategory.cable,
    icon: Icons.trending_down,
    caution: _cableCaution,
    fields: [
      FieldDef.choice('ph', 'Sistem', ['Tek fazlı', 'Üç fazlı']),
      FieldDef.choice('mat', 'İletken malzeme', ['Bakır', 'Alüminyum']),
      FieldDef.number('u', 'Besleme gerilimi (U)',
          units: _vU,
          defaultText: '230',
          hint: 'Üç fazlıda hatlar arası gerilim'),
      FieldDef.number('i', 'Akım (I)', units: _aU),
      FieldDef.number('l', 'Kablo uzunluğu (tek yön)',
          units: _lenU, hint: 'Kaynak ile yük arasındaki mesafe'),
      FieldDef.number('s', 'Kablo kesiti (S)',
          units: const [UnitOpt('mm²')], hint: 'Örn. 2,5'),
      FieldDef.number('pf', 'Güç faktörü (cosφ)', defaultText: '1'),
      FieldDef.number('t', 'İletken sıcaklığı',
          units: const [UnitOpt('°C')],
          defaultText: '20',
          hint: 'Yük altındaki kablo için daha yüksek (ör. 70 °C) girilebilir'),
      FieldDef.number('lim', 'İzin verilen düşüm (isteğe bağlı)',
          units: _pctU, required: false),
    ],
    compute: _vdrop,
  ),
  CalcDef(
    id: 'section',
    title: 'Kablo Kesiti Yardımcısı',
    subtitle: 'Gerilim düşümüne göre ön kesit değerlendirmesi',
    keywords: 'kablo kesit mm2 iletken standart secim akim tasima',
    category: CalcCategory.cable,
    icon: Icons.cable,
    caution: _cableCaution,
    fields: [
      FieldDef.choice('ph', 'Sistem', ['Tek fazlı', 'Üç fazlı']),
      FieldDef.choice('mat', 'İletken malzeme', ['Bakır', 'Alüminyum']),
      FieldDef.number('u', 'Besleme gerilimi (U)',
          units: _vU,
          defaultText: '230',
          hint: 'Üç fazlıda hatlar arası gerilim'),
      FieldDef.number('i', 'Akım (I)', units: _aU),
      FieldDef.number('l', 'Kablo uzunluğu (tek yön)', units: _lenU),
      FieldDef.number('lim', 'İzin verilen gerilim düşümü',
          units: _pctU,
          defaultText: '3',
          hint: 'Proje veya ilgili standarda göre belirleyin'),
      FieldDef.number('pf', 'Güç faktörü (cosφ)', defaultText: '1'),
      FieldDef.number('t', 'İletken sıcaklığı',
          units: const [UnitOpt('°C')], defaultText: '20'),
    ],
    compute: _section,
  ),
  CalcDef(
    id: 'resistor',
    title: 'Direnç Renk Kodları',
    subtitle: '4, 5 ve 6 bantlı direnç okuma',
    keywords: 'direnc renk kodu bant tolerans sicaklik katsayisi',
    category: CalcCategory.electronics,
    icon: Icons.palette,
    fields: [
      FieldDef.choice('n', 'Bant sayısı', ['4 bant', '5 bant', '6 bant']),
      FieldDef.choice('d1', '1. bant (1. rakam)', _names(digitColors),
          swatches: _swatches(digitColors), optionIndex: 1),
      FieldDef.choice('d2', '2. bant (2. rakam)', _names(digitColors),
          swatches: _swatches(digitColors)),
      FieldDef.choice('d3', '3. bant (3. rakam)', _names(digitColors),
          swatches: _swatches(digitColors), visible: (c) => c['n'] != 0),
      FieldDef.choice('m', 'Çarpan bandı', _names(multiplierColors),
          swatches: _swatches(multiplierColors), optionIndex: 2),
      FieldDef.choice('tol', 'Tolerans bandı', _names(toleranceColors),
          swatches: _swatches(toleranceColors), optionIndex: 6),
      FieldDef.choice('tc', 'Sıcaklık katsayısı bandı', _names(tempCoColors),
          swatches: _swatches(tempCoColors),
          optionIndex: 1,
          visible: (c) => c['n'] == 2),
    ],
    compute: _resistor,
  ),
  CalcDef(
    id: 'network',
    title: 'Seri ve Paralel Direnç',
    subtitle: 'Eşdeğer direnç, akım ve gerilim dağılımı',
    keywords: 'seri paralel direnc esdeger akim gerilim dagilim',
    category: CalcCategory.electronics,
    icon: Icons.account_tree,
    fields: [
      FieldDef.choice('mode', 'Bağlantı', ['Seri', 'Paralel']),
      FieldDef.list('r', 'Direnç değerleri',
          units: _rU,
          defaultText: '100 220 470',
          hint: 'Değerleri boşluk veya ; ile ayırın'),
      FieldDef.number('v', 'Besleme gerilimi (isteğe bağlı)',
          units: _vU,
          required: false,
          hint: 'Girilirse akım ve güç dağılımı hesaplanır'),
    ],
    compute: _network,
  ),
  CalcDef(
    id: 'capacitor',
    title: 'Kondansatör',
    subtitle: 'Seri/paralel eşdeğer kapasite ve reaktans',
    keywords: 'kondansator kapasite seri paralel reaktans xc farad',
    category: CalcCategory.electronics,
    icon: Icons.battery_charging_full,
    fields: [
      FieldDef.choice('mode', 'Bağlantı', ['Seri', 'Paralel']),
      FieldDef.list('c', 'Kapasite değerleri',
          units: _capU,
          defaultText: '10 22',
          hint: 'Değerleri boşluk veya ; ile ayırın'),
      FieldDef.number('f', 'Frekans (isteğe bağlı)',
          units: _hzU,
          required: false,
          hint: 'Girilirse kapasitif reaktans (XC) hesaplanır'),
    ],
    compute: _capacitor,
  ),
  CalcDef(
    id: 'frequency',
    title: 'Frekans ve Periyot',
    subtitle: 'Hz, kHz, MHz ve s, ms, µs dönüşümleri',
    keywords: 'frekans periyot hz khz mhz saniye milisaniye mikrosaniye',
    category: CalcCategory.electronics,
    icon: Icons.graphic_eq,
    fields: [
      FieldDef.choice(
          'mode', 'Hesap yönü', ['Frekanstan periyoda', 'Periyottan frekansa']),
      FieldDef.number('f', 'Frekans (f)',
          units: _hzU, defaultText: '50', visible: (c) => c['mode'] == 0),
      FieldDef.number('t', 'Periyot (T)',
          units: _secU,
          unitIndex: 1,
          defaultText: '20',
          visible: (c) => c['mode'] == 1),
    ],
    compute: _frequency,
  ),
  CalcDef(
    id: 'plc',
    title: 'PLC Analog Ölçekleme',
    subtitle: '4–20 mA, 0–10 V ve özel aralık ölçekleme',
    keywords: 'plc analog olcekleme 4-20 ma 0-10 v sinyal sensor otomasyon',
    category: CalcCategory.automation,
    icon: Icons.tune,
    fields: [
      FieldDef.choice('dir', 'Hesap yönü',
          ['Sinyal → mühendislik değeri', 'Mühendislik değeri → sinyal']),
      FieldDef.choice('sig', 'Sinyal türü',
          ['4–20 mA', '0–20 mA', '0–10 V', '1–5 V', 'Özel aralık']),
      FieldDef.number('lo', 'Sinyal alt sınırı (mA veya V)',
          defaultText: '0', visible: (c) => c['sig'] == 4),
      FieldDef.number('hi', 'Sinyal üst sınırı (mA veya V)',
          defaultText: '10', visible: (c) => c['sig'] == 4),
      FieldDef.number('elo', 'Mühendislik alt değeri',
          defaultText: '0', hint: 'Ör. 0 °C, 0 bar, 0 %'),
      FieldDef.number('ehi', 'Mühendislik üst değeri', defaultText: '100'),
      FieldDef.number('x', 'Sinyal değeri (mA veya V)',
          defaultText: '12', visible: (c) => c['dir'] == 0),
      FieldDef.number('y', 'Mühendislik değeri',
          defaultText: '50', visible: (c) => c['dir'] == 1),
    ],
    compute: _plc,
  ),
  CalcDef(
    id: 'pulse',
    title: 'Zamanlayıcı ve Darbe',
    subtitle: 'Frekans, periyot, duty cycle ve zaman dönüşümü',
    keywords: 'zamanlayici darbe pwm duty calisma orani periyot sure timer',
    category: CalcCategory.automation,
    icon: Icons.timer,
    fields: [
      FieldDef.choice('mode', 'Hesap türü', [
        'Frekans ve duty → süreler',
        'Süreler → frekans ve duty',
        'Zaman birimi dönüşümü'
      ]),
      FieldDef.number('f', 'Frekans',
          units: _hzU, defaultText: '1', visible: (c) => c['mode'] == 0),
      FieldDef.number('d', 'Çalışma oranı (duty cycle)',
          units: _pctU, defaultText: '50', visible: (c) => c['mode'] == 0),
      FieldDef.number('on', 'Açık kalma süresi (ON)',
          units: _secU,
          unitIndex: 1,
          defaultText: '1',
          visible: (c) => c['mode'] == 1),
      FieldDef.number('off', 'Kapalı kalma süresi (OFF)',
          units: _secU,
          unitIndex: 1,
          defaultText: '3',
          visible: (c) => c['mode'] == 1),
      FieldDef.number('vs', 'Çıkış gerilimi (isteğe bağlı)',
          units: _vU,
          required: false,
          hint: 'Girilirse ortalama gerilim hesaplanır',
          visible: (c) => c['mode'] != 2),
      FieldDef.number('tv', 'Süre',
          units: _timeAll, defaultText: '90', visible: (c) => c['mode'] == 2),
    ],
    compute: _pulse,
  ),
  CalcDef(
    id: 'motorspeed',
    title: 'Motor Hızı ve Kayma',
    subtitle: 'Senkron hız, kutup sayısı, kayma ve rotor frekansı',
    keywords: 'senkron hiz kayma kutup sayisi devir rpm motor frekans',
    category: CalcCategory.electric,
    icon: Icons.speed,
    fields: [
      FieldDef.choice('mode', 'Hesap türü',
          ['Kutup sayısı biliniyor', 'Etiket devrinden kutup tahmini']),
      FieldDef.number('f', 'Şebeke frekansı',
          units: const [UnitOpt('Hz')], defaultText: '50'),
      FieldDef.choice('poles', 'Kutup sayısı',
          ['2 kutup', '4 kutup', '6 kutup', '8 kutup', '10 kutup', '12 kutup'],
          optionIndex: 1, visible: (c) => c['mode'] == 0),
      FieldDef.number('nr', 'Etiket (rotor) devri',
          units: const [UnitOpt('d/dk')],
          required: false,
          hint: 'Girilirse kayma hesaplanır',
          visible: (c) => c['mode'] == 0),
      FieldDef.number('nr2', 'Etiket (rotor) devri',
          units: const [UnitOpt('d/dk')],
          defaultText: '1450',
          visible: (c) => c['mode'] == 1),
    ],
    compute: _motorSpeed,
  ),
  CalcDef(
    id: 'awg',
    title: 'AWG ve mm² Dönüşümü',
    subtitle: 'AWG numarasından kesit/çap ve en yakın AWG',
    keywords: 'awg mm2 kesit tel cap iletken donusum',
    category: CalcCategory.cable,
    icon: Icons.straighten,
    caution: _cableCaution,
    fields: [
      FieldDef.choice(
          'mode', 'Hesap türü', ['AWG → mm²', 'mm² → en yakın AWG']),
      FieldDef.number('awg', 'AWG numarası',
          defaultText: '10',
          hint: '0000 için −3, 000 için −2, 00 için −1',
          visible: (c) => c['mode'] == 0),
      FieldDef.number('area', 'Kesit',
          units: const [UnitOpt('mm²')],
          defaultText: '2,5',
          visible: (c) => c['mode'] == 1),
    ],
    compute: _awg,
  ),
  CalcDef(
    id: 'led',
    title: 'LED Seri Direnci',
    subtitle: 'LED için seri direnç ve standart E12 değeri',
    keywords: 'led seri direnc diyot vf akim',
    category: CalcCategory.electronics,
    icon: Icons.lightbulb_outline,
    fields: [
      FieldDef.number('vs', 'Besleme gerilimi', units: _vU, defaultText: '5'),
      FieldDef.number('vf', 'LED ileri gerilimi (Vf)',
          units: _vU,
          defaultText: '2',
          hint: 'Veri sayfasından; kırmızı yaklaşık 2 V'),
      FieldDef.number('i', 'LED akımı (If)',
          units: const [UnitOpt('mA', 1e-3), UnitOpt('A')], defaultText: '20'),
    ],
    compute: _led,
  ),
  CalcDef(
    id: 'divider',
    title: 'Gerilim Bölücü',
    subtitle: 'İki dirençli bölücü ve yük etkisi',
    keywords: 'gerilim bolucu direnc vout referans yuk',
    category: CalcCategory.electronics,
    icon: Icons.call_split,
    fields: [
      FieldDef.number('vin', 'Giriş gerilimi (Vin)',
          units: _vU, defaultText: '12'),
      FieldDef.number('r1', 'R1 (üst direnç)',
          units: _ohmOnly, unitIndex: 1, defaultText: '10'),
      FieldDef.number('r2', 'R2 (alt direnç)',
          units: _ohmOnly, unitIndex: 1, defaultText: '10'),
      FieldDef.number('rl', 'Yük direnci (isteğe bağlı)',
          units: _ohmOnly, unitIndex: 1, required: false),
    ],
    compute: _divider,
  ),
  CalcDef(
    id: 'rc',
    title: 'RC Zaman Sabiti',
    subtitle: 'Kondansatör şarj ve deşarj hesabı',
    keywords: 'rc zaman sabiti tau sarj desarj kondansator',
    category: CalcCategory.electronics,
    icon: Icons.hourglass_bottom,
    fields: [
      FieldDef.choice('mode', 'İşlem', ['Şarj', 'Deşarj']),
      FieldDef.number('r', 'Direnç (R)',
          units: _ohmOnly, unitIndex: 1, defaultText: '10'),
      FieldDef.number('c', 'Kapasite (C)', units: _capU, defaultText: '100'),
      FieldDef.number('v', 'Kaynak/başlangıç gerilimi (isteğe bağlı)',
          units: _vU, required: false),
      FieldDef.number('t', 'Süre (isteğe bağlı)',
          units: _secU, required: false),
    ],
    compute: _rc,
  ),
  CalcDef(
    id: 'reactance',
    title: 'Reaktans ve Rezonans',
    subtitle: 'Endüktif/kapasitif reaktans ve rezonans frekansı',
    keywords: 'reaktans xl xc bobin endüktans kondansator rezonans',
    category: CalcCategory.electronics,
    icon: Icons.waves,
    fields: [
      FieldDef.number('f', 'Frekans', units: _hzU, defaultText: '50'),
      FieldDef.number('l', 'Endüktans (L)',
          units: _lU, required: false, hint: 'L ve C den en az birini girin'),
      FieldDef.number('c', 'Kapasite (C)', units: _capU, required: false),
    ],
    compute: _reactance,
  ),
  CalcDef(
    id: 'conveyor',
    title: 'Konveyör ve Enkoder',
    subtitle: 'Bant hızı, redüktör oranı ve enkoderden devir',
    keywords: 'konveyor bant hizi reduktor enkoder devir ppr tambur',
    category: CalcCategory.automation,
    icon: Icons.linear_scale,
    fields: [
      FieldDef.choice('mode', 'Hesap türü',
          ['Konveyör bant hızı', 'Enkoder darbesinden devir']),
      FieldDef.number('rpm', 'Motor devri',
          units: const [UnitOpt('d/dk')],
          defaultText: '1450',
          visible: (c) => c['mode'] == 0),
      FieldDef.number('ratio', 'Redüktör oranı (i)',
          defaultText: '20',
          hint: 'Örn. 20 → 20:1',
          visible: (c) => c['mode'] == 0),
      FieldDef.number('d', 'Tambur çapı',
          units: _dU, defaultText: '100', visible: (c) => c['mode'] == 0),
      FieldDef.number('pps', 'Darbe frekansı',
          units: _hzU, defaultText: '1000', visible: (c) => c['mode'] == 1),
      FieldDef.number('ppr', 'Enkoder çözünürlüğü (PPR)',
          defaultText: '360', visible: (c) => c['mode'] == 1),
    ],
    compute: _conveyor,
  ),
  CalcDef(
    id: 'cylinder',
    title: 'Pnömatik Silindir Kuvveti',
    subtitle: 'Basınç, piston alanı ve kuvvet ilişkisi',
    keywords: 'pnomatik silindir kuvvet basinc piston alan bar newton',
    category: CalcCategory.automation,
    icon: Icons.compress,
    fields: [
      FieldDef.number('p', 'Çalışma basıncı', units: _prU, defaultText: '6'),
      FieldDef.number('d', 'Piston çapı', units: _dU, defaultText: '50'),
      FieldDef.number('rod', 'Piston kolu çapı (isteğe bağlı)',
          units: _dU,
          required: false,
          hint: 'Girilirse geri kuvvet de hesaplanır'),
      FieldDef.number('eta', 'Verim (sürtünme payı)',
          units: _etaU, defaultText: '100'),
    ],
    compute: _cylinder,
  ),
  CalcDef(
    id: 'converter',
    title: 'Birim Dönüştürücü',
    subtitle:
        'Akım, gerilim, güç, enerji, direnç, kapasite, frekans, uzunluk, alan, sıcaklık',
    keywords: 'birim donusturucu cevirici hp kw kwh celsius fahrenheit inc',
    category: CalcCategory.tools,
    icon: Icons.swap_horiz,
    customBuilder: () => const ConverterPage(),
  ),
];

CalcDef? findCalc(String id) {
  for (final c in allCalcs) {
    if (c.id == id) return c;
  }
  return null;
}
