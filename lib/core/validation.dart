import 'format.dart';

/// Kullanıcıya gösterilecek, anlaşılır Türkçe doğrulama hatası.
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => message;
}

void requirePositive(double? v, String name) {
  if (v == null || !v.isFinite || v <= 0) {
    throw ValidationException('$name sıfırdan büyük olmalıdır.');
  }
}

void requireNonNegative(double? v, String name) {
  if (v == null || !v.isFinite || v < 0) {
    throw ValidationException('$name negatif olamaz.');
  }
}

void requireRange(double v, double min, double max, String name) {
  if (!v.isFinite || v < min || v > max) {
    throw ValidationException(
        '$name ${fmtNum(min)} ile ${fmtNum(max)} arasında olmalıdır.');
  }
}

/// Güç faktörü: 0 < cosφ <= 1
void requirePowerFactor(double pf, [String name = 'Güç faktörü']) {
  if (!pf.isFinite || pf <= 0 || pf > 1 + 1e-12) {
    throw ValidationException('$name 0 ile 1 arasında olmalıdır (0 hariç).');
  }
}

/// Verim: 0 < η <= 1 (oran olarak)
void requireEfficiency(double eta) {
  if (!eta.isFinite || eta <= 0 || eta > 1 + 1e-12) {
    throw const ValidationException(
        'Verim %0 ile %100 arasında olmalıdır (0 hariç).');
  }
}
