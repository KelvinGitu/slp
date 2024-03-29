import 'package:intl/intl.dart';

class Utils {
  static formatPrice(int price) => 'KES ${price.toStringAsFixed(2)}';
  static formatDate(DateTime date) => DateFormat.yMd().format(date);
}