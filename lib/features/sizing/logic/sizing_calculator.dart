import 'dart:math' as math;

import 'package:solartide/core/enums/sizing_role.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/models/catalogue_item.dart';
import 'package:solartide/models/quote_model.dart';
import 'package:solartide/models/sizing_result.dart';

/// One appliance on the load sheet.
class Appliance {
  const Appliance({required this.name, required this.watts, this.quantity = 1, required this.hoursPerDay});

  final String name;
  final int watts;
  final int quantity;
  final double hoursPerDay;

  double get dailyWh => watts * quantity * hoursPerDay;
  int get peakWatts => watts * quantity;
}

/// Everything the calculator needs besides the catalogue.
class SizingInput {
  const SizingInput({
    required this.dailyWh,
    required this.peakWatts,
    required this.peakSunHours,
    required this.sunHoursSource,
    this.withBatteries = true,
    this.autonomyDays = 1,
    this.systemVoltage = 24,
    this.locationLabel,
  });

  /// From a load sheet: Σ watts × quantity × hours.
  factory SizingInput.fromAppliances(
    List<Appliance> appliances, {
    required double peakSunHours,
    required SunHoursSource sunHoursSource,
    bool withBatteries = true,
    int autonomyDays = 1,
    int systemVoltage = 24,
    String? locationLabel,
  }) =>
      SizingInput(
        dailyWh: appliances.fold(0, (sum, a) => sum + a.dailyWh),
        // Everything on at once: conservative, which is right for an inverter.
        peakWatts: appliances.fold(0, (sum, a) => sum + a.peakWatts),
        peakSunHours: peakSunHours,
        sunHoursSource: sunHoursSource,
        withBatteries: withBatteries,
        autonomyDays: autonomyDays,
        systemVoltage: systemVoltage,
        locationLabel: locationLabel,
      );

  final double dailyWh;
  final int peakWatts;
  final double peakSunHours;
  final SunHoursSource sunHoursSource;
  final bool withBatteries;
  final int autonomyDays;

  /// 12, 24 or 48 V battery bank.
  final int systemVoltage;
  final String? locationLabel;
}

/// Off-grid and hybrid sizing, simplified to what an installer checks on
/// site. Rules of thumb, not a design tool; the installer adjusts the quote
/// afterwards.
abstract final class SizingCalculator {
  /// Share of the panels' rated output that reaches the loads after heat,
  /// dust, wiring and inverter losses.
  static const performanceRatio = 0.75;

  /// Inverter continuous rating over the peak load.
  static const inverterHeadroom = 1.25;

  /// Usable share of battery capacity (lithium; lead-acid is lower, which
  /// the installer can allow for with extra autonomy).
  static const depthOfDischarge = 0.8;

  /// Used when the catalogue has no panel rating.
  static const defaultPanelWatts = 450;

  static SizingResult size(SizingInput input, List<CatalogueItem> catalogue) {
    final panel = _byRole(catalogue, SizingRole.panel);
    final inverter = _byRole(catalogue, SizingRole.inverter);
    final battery = _byRole(catalogue, SizingRole.battery);

    final psh = input.peakSunHours <= 0 ? 1.0 : input.peakSunHours;
    final arrayWatts = input.dailyWh / (psh * performanceRatio);
    final panelWatts = (panel?.rating ?? 0) > 0 ? panel!.rating! : defaultPanelWatts;
    final panelCount = input.dailyWh <= 0 ? 0 : (arrayWatts / panelWatts).ceil();

    final inverterWatts = input.peakWatts * inverterHeadroom;
    final inverterOption = inverter == null ? null : _smallestAtLeast(inverter.options, inverterWatts);

    final batteryWh = input.withBatteries ? input.dailyWh * input.autonomyDays / depthOfDischarge : 0.0;
    final batteryPick = battery == null || batteryWh <= 0 ? null : _cheapestBank(battery, batteryWh, input.systemVoltage);

    return SizingResult(
      dailyWh: input.dailyWh,
      peakSunHours: psh,
      sunHoursSource: input.sunHoursSource,
      arrayWatts: arrayWatts,
      panelWatts: panelWatts,
      panelCount: panelCount,
      inverterWatts: inverterWatts,
      batteryWh: batteryWh,
      autonomyDays: input.withBatteries ? input.autonomyDays : 0,
      systemVoltage: input.systemVoltage,
      locationLabel: input.locationLabel,
      inverterOptionId: inverterOption?.id,
      batteryOptionId: batteryPick?.option.id,
      batteryCount: batteryPick?.count ?? 0,
    );
  }

  /// Fills the panel, inverter and battery lines of a new quote from
  /// [result]. Everything else stays "To do".
  static List<QuoteLine> applyToLines(List<QuoteLine> lines, SizingResult result, List<CatalogueItem> catalogue) {
    final byId = {for (final i in catalogue) i.id: i};
    return [
      for (final line in lines)
        switch (byId[line.itemId]?.sizingRole) {
          SizingRole.panel when result.panelCount > 0 =>
            QuoteCalculator.include(byId[line.itemId]!, line, inputs: {_firstInput(byId[line.itemId]!): result.panelCount}),
          SizingRole.inverter when result.inverterOptionId != null => QuoteCalculator.include(
              byId[line.itemId]!,
              line,
              picks: [(optionId: result.inverterOptionId!, quantity: 1)],
            ),
          SizingRole.battery when result.batteryOptionId != null => QuoteCalculator.include(
              byId[line.itemId]!,
              line,
              picks: [(optionId: result.batteryOptionId!, quantity: result.batteryCount)],
            ),
          SizingRole.battery when result.batteryWh <= 0 => QuoteCalculator.notRequired(line),
          _ => line,
        },
    ];
  }

  /// Whether sizing found an inverter big enough in the catalogue.
  static bool inverterFits(SizingResult r) => r.inverterWatts <= 0 || r.inverterOptionId != null;

  static String _firstInput(CatalogueItem item) => item.inputs.isEmpty ? 'count' : item.inputs.first.id;

  static CatalogueItem? _byRole(List<CatalogueItem> catalogue, SizingRole role) {
    for (final i in catalogue) {
      if (i.sizingRole == role && i.active) return i;
    }
    return null;
  }

  static CatalogueOption? _smallestAtLeast(List<CatalogueOption> options, double watts) {
    final fitting = options.where((o) => (o.rating ?? 0) >= watts).toList()
      ..sort((a, b) => a.rating!.compareTo(b.rating!));
    return fitting.isEmpty ? null : fitting.first;
  }

  /// Picks the capacity whose bank costs least. Batteries are wired in
  /// series up to the system voltage, then in parallel strings until the
  /// bank holds [neededWh].
  static ({CatalogueOption option, int count})? _cheapestBank(CatalogueItem battery, double neededWh, int systemVoltage) {
    final cellVoltage = battery.nominalVoltage ?? 12;
    final inSeries = math.max(1, (systemVoltage / cellVoltage).round());
    ({CatalogueOption option, int count})? best;
    for (final o in battery.options) {
      final ah = o.rating ?? 0;
      if (ah <= 0) continue;
      final stringWh = ah * cellVoltage * inSeries;
      final count = (neededWh / stringWh).ceil() * inSeries;
      if (best == null || o.price * count < best.option.price * best.count) best = (option: o, count: count);
    }
    return best;
  }
}

/// Starting points for the load sheet, so the installer isn't typing wattages
/// from memory. Typical Kenyan household figures.
const appliancePresets = [
  Appliance(name: 'LED bulb', watts: 9, quantity: 6, hoursPerDay: 5),
  Appliance(name: 'TV (43")', watts: 80, hoursPerDay: 5),
  Appliance(name: 'Fridge', watts: 150, hoursPerDay: 10),
  Appliance(name: 'Phone charging', watts: 10, quantity: 3, hoursPerDay: 2),
  Appliance(name: 'Laptop', watts: 60, hoursPerDay: 6),
  Appliance(name: 'Wi-Fi router', watts: 12, hoursPerDay: 24),
  Appliance(name: 'Water pump (0.5 hp)', watts: 370, hoursPerDay: 1),
  Appliance(name: 'Microwave', watts: 1000, hoursPerDay: 0.25),
  Appliance(name: 'Iron box', watts: 1000, hoursPerDay: 0.5),
  Appliance(name: 'Security lights', watts: 20, quantity: 4, hoursPerDay: 12),
];
