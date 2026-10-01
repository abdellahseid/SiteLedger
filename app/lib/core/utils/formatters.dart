import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _compactCurrency = NumberFormat.compact(locale: 'en_US');
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • HH:mm');

  static String currency(num amount, {bool compact = false}) {
    if (compact && amount >= 100000) {
      return 'ETB ${_compactCurrency.format(amount)}';
    }
    return 'ETB ${_currencyFormat.format(amount)}';
  }

  static String date(DateTime? dt) {
    if (dt == null) return '—';
    return _dateFormat.format(dt);
  }

  static String dateTime(DateTime? dt) {
    if (dt == null) return '—';
    return _dateTimeFormat.format(dt);
  }

  static String quantity(num qty, String unit) {
    if (qty == qty.roundToDouble()) {
      return '${qty.toInt()} $unit';
    }
    return '${qty.toStringAsFixed(1)} $unit';
  }
}
