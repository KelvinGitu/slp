import 'package:solartide/core/utils/firestore_json.dart';

/// Where the peak sun hours in a sizing came from.
enum SunHoursSource {
  nasaPower,
  fallback;

  static SunHoursSource fromName(String? name) =>
      SunHoursSource.values.firstWhere((s) => s.name == name, orElse: () => SunHoursSource.fallback);
}

/// The output of the sizing calculator, stored on a quote that was started
/// from it so the PDF can show the design basis.
class SizingResult {
  const SizingResult({
    required this.dailyWh,
    required this.peakSunHours,
    required this.sunHoursSource,
    required this.arrayWatts,
    required this.panelWatts,
    required this.panelCount,
    required this.inverterWatts,
    required this.batteryWh,
    required this.autonomyDays,
    required this.systemVoltage,
    this.locationLabel,
    this.inverterOptionId,
    this.batteryOptionId,
    this.batteryCount = 0,
  });

  /// Energy the client uses per day.
  final double dailyWh;
  final double peakSunHours;
  final SunHoursSource sunHoursSource;

  /// Array size needed after losses.
  final double arrayWatts;
  final int panelWatts;
  final int panelCount;

  /// Smallest continuous rating that covers the peak load with headroom.
  final double inverterWatts;

  /// Usable storage needed after depth of discharge. Zero when the client
  /// doesn't want batteries.
  final double batteryWh;
  final int autonomyDays;
  final int systemVoltage;
  final String? locationLabel;

  /// Catalogue options the calculator picked, if the catalogue had one big
  /// enough.
  final String? inverterOptionId;
  final String? batteryOptionId;
  final int batteryCount;

  factory SizingResult.fromMap(Map<String, dynamic> map) => SizingResult(
        dailyWh: doubleFrom(map['dailyWh']) ?? 0,
        peakSunHours: doubleFrom(map['peakSunHours']) ?? 0,
        sunHoursSource: SunHoursSource.fromName(map['sunHoursSource'] as String?),
        arrayWatts: doubleFrom(map['arrayWatts']) ?? 0,
        panelWatts: intFrom(map['panelWatts']) ?? 0,
        panelCount: intFrom(map['panelCount']) ?? 0,
        inverterWatts: doubleFrom(map['inverterWatts']) ?? 0,
        batteryWh: doubleFrom(map['batteryWh']) ?? 0,
        autonomyDays: intFrom(map['autonomyDays']) ?? 0,
        systemVoltage: intFrom(map['systemVoltage']) ?? 0,
        locationLabel: map['locationLabel'] as String?,
        inverterOptionId: map['inverterOptionId'] as String?,
        batteryOptionId: map['batteryOptionId'] as String?,
        batteryCount: intFrom(map['batteryCount']) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'dailyWh': dailyWh,
        'peakSunHours': peakSunHours,
        'sunHoursSource': sunHoursSource.name,
        'arrayWatts': arrayWatts,
        'panelWatts': panelWatts,
        'panelCount': panelCount,
        'inverterWatts': inverterWatts,
        'batteryWh': batteryWh,
        'autonomyDays': autonomyDays,
        'systemVoltage': systemVoltage,
        'locationLabel': locationLabel,
        'inverterOptionId': inverterOptionId,
        'batteryOptionId': batteryOptionId,
        'batteryCount': batteryCount,
      };
}
