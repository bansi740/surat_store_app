import 'package:intl/intl.dart';

class AppFormatter {
  static final NumberFormat inr = NumberFormat('#,##,##0', 'en_IN');

  static String formatPrice(num value) {
    return '₹${inr.format(value)}';
  }

  static double parsePrice(String value) {
    return double.tryParse(
      value.replaceAll('₹', '').replaceAll(',', '').trim(),
    ) ??
        0.0;
  }
}