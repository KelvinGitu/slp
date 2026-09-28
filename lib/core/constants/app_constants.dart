abstract final class AppConstants {
  static const appName = 'SolarTide';
  static const currency = 'KES';

  /// Kenyan standard VAT rate, as a percentage. Each business can override it
  /// in its profile; this is only the starting value.
  static const defaultVatPercent = 16.0;
  static const defaultMarkupPercent = 0.0;
  static const defaultQuoteValidityDays = 30;
  static const defaultQuotePrefix = 'ST';

  /// Peak sun hours used when NASA POWER can't be reached. Most of Kenya sits
  /// between 4.5 and 6.
  static const fallbackPeakSunHours = 5.0;
}
