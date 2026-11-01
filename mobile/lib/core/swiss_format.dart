import 'package:intl/intl.dart';

enum PriceUnit { chf, rp }

class SwissFormat {
  static final _chf = NumberFormat.currency(
    locale: 'de_CH',
    symbol: 'CHF',
    decimalDigits: 2,
  );

  static String formatPrice(double chfPerKwh, {required PriceUnit unit}) {
    if (unit == PriceUnit.rp) {
      final rp = chfPerKwh * 100;
      return '${rp.toStringAsFixed(1)} Rp./kWh';
    }
    return '${(chfPerKwh).toStringAsFixed(3)} CHF/kWh';
  }

  static String formatChf(double amount) => _chf.format(amount);

  static String formatTime24(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  static String formatDate(DateTime dt, String locale) {
    return DateFormat.yMMMd(locale).format(dt);
  }

  static double toDisplayUnit(double chfPerKwh, PriceUnit unit) {
    return unit == PriceUnit.rp ? chfPerKwh * 100 : chfPerKwh;
  }

  static String unitLabel(PriceUnit unit) {
    return unit == PriceUnit.rp ? 'Rp./kWh' : 'CHF/kWh';
  }
}
