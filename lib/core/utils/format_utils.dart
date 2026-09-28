import 'package:intl/intl.dart';
import 'package:solartide/core/constants/app_constants.dart';

/// Greeting by local hour (STYLE_GUIDE §5.1). "Good night" covers 22:00 to
/// 04:00.
String greetingFor(DateTime time) {
  final h = time.hour;
  if (h >= 22 || h < 4) return 'Good night';
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

/// 24-hour clock, "18:00".
String formatTime(DateTime? time) => time == null ? '--:--' : DateFormat('HH:mm').format(time);

/// "20 April 2026".
String formatDate(DateTime date) => DateFormat('d MMMM y').format(date);

/// "21 Sep 2026", for list rows where the full date would wrap.
String formatShortDate(DateTime date) => DateFormat('d MMM y').format(date);

final _kes = NumberFormat('#,##0', 'en_US');
final _kesCents = NumberFormat('#,##0.00', 'en_US');

/// "KES 125,000". Quotes are priced in whole shillings; pass [cents] for the
/// PDF, where VAT can leave a fraction.
String formatKes(num amount, {bool cents = false}) =>
    '${AppConstants.currency} ${(cents ? _kesCents : _kes).format(amount)}';

/// Plain number with separators and no currency, "125,000".
String formatAmount(num amount) => _kes.format(amount);

/// "ST-2026-0007".
String formatQuoteNumber(String prefix, int year, int sequence) =>
    '$prefix-$year-${sequence.toString().padLeft(4, '0')}';

/// "12 panels", "35 m", "90 min", "1 roll".
String formatUnits(int quantity, String unit) => switch (unit) {
      'm' => '$quantity m',
      'minute' => '$quantity min',
      _ => quantity == 1 ? '1 $unit' : '$quantity ${unit}s',
    };

/// "3.2 kWp", "850 W". Keeps sizing results readable whatever the magnitude.
String formatPower(double watts) =>
    watts >= 1000 ? '${(watts / 1000).toStringAsFixed(1)} kW' : '${watts.round()} W';

/// "12.5 kWh".
String formatEnergy(double wattHours) => '${(wattHours / 1000).toStringAsFixed(1)} kWh';

/// Initials for the default avatar: "Amos Otieno" → "AO".
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
