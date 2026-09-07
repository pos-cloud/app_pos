import 'package:intl/intl.dart';

/// Formato numérico del POS: miles con `.` y decimales con `,`.
abstract final class AppNumberFormat {
  static final NumberFormat _money =
      NumberFormat.currency(locale: 'es_AR', symbol: '', decimalDigits: 2);

  static final NumberFormat _integer =
      NumberFormat('#,##0', 'es_AR');

  static final NumberFormat _quantity =
      NumberFormat('#,##0.##', 'es_AR');

  static String money(double value) {
    return '\$${_money.format(value).trim()}';
  }

  static String quantity(double value) {
    if (value == value.roundToDouble()) {
      return _integer.format(value);
    }
    return _quantity.format(value);
  }

  static String decimal(double value, {int digits = 2}) {
    if (digits <= 0) return _integer.format(value);
    return NumberFormat('#,##0.${'0' * digits}', 'es_AR').format(value);
  }

  static String percent(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${_quantity.format(value)}%';
  }

  /// Parsea texto con formato local (`1.234,56` o `1234,56`).
  static double? parse(String text) {
    final normalized =
        text.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }
}

extension AppNumberFormatExtension on double {
  String get asMoney => AppNumberFormat.money(this);

  String get asQuantity => AppNumberFormat.quantity(this);

  String get asPercent => AppNumberFormat.percent(this);
}

extension AppNumberFormatNullableExtension on double? {
  String get asMoneyOrEmpty {
    if (this == null) return '';
    return this!.asMoney;
  }
}
