import 'dart:math' as math;

/// Metindeki sayıyı okur. Ondalık ayraç olarak virgül veya nokta kabul edilir.
double? parseNumber(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  final v = double.tryParse(t);
  if (v == null || !v.isFinite) return null;
  return v;
}

/// Boşluk veya ';' ile ayrılmış sayı listesini okur. Geçersizse null döner.
List<double>? parseNumberList(String text) {
  final parts =
      text.split(RegExp(r'[\s;]+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return null;
  final out = <double>[];
  for (final p in parts) {
    final v = parseNumber(p);
    if (v == null) return null;
    out.add(v);
  }
  return out;
}

/// Sayıyı Türkçe biçimde (ondalık virgül) anlamlı hane sayısıyla yazar.
String fmtNum(double v, {int sig = 6}) {
  if (v.isNaN || v.isInfinite) return '—';
  if (v == 0) return '0';
  var s = v.toStringAsPrecision(sig);
  var exp = '';
  final e = s.indexOf('e');
  if (e >= 0) {
    exp = '×10^${int.parse(s.substring(e + 1))}';
    s = s.substring(0, e);
  }
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return '${s.replaceAll('.', ',')}$exp';
}

/// Değeri uygun SI önekiyle yazar (ör. 4700 Ω -> 4,7 kΩ).
String fmtEng(double v, String unit) {
  if (!v.isFinite) return '— $unit';
  if (v == 0) return '0 $unit';
  const prefixes = <int, String>{
    -12: 'p',
    -9: 'n',
    -6: 'µ',
    -3: 'm',
    0: '',
    3: 'k',
    6: 'M',
    9: 'G',
  };
  final a = v.abs();
  var exp = -12;
  for (final e in prefixes.keys) {
    if (a >= math.pow(10, e) * (1 - 1e-9)) exp = e;
  }
  final scaled = v / math.pow(10, exp);
  final prefix = prefixes[exp] ?? '';
  return '${fmtNum(scaled)} $prefix$unit';
}

/// Türkçe karakterleri sadeleştirip küçük harfe çevirir (arama için).
String normalizeTr(String s) {
  const map = <String, String>{
    'İ': 'i', 'I': 'i', 'ı': 'i', 'Ş': 's', 'ş': 's', 'Ğ': 'g', 'ğ': 'g',
    'Ü': 'u', 'ü': 'u', 'Ö': 'o', 'ö': 'o', 'Ç': 'c', 'ç': 'c',
  };
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(map[ch] ?? ch.toLowerCase());
  }
  return b.toString();
}
