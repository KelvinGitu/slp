import 'package:flutter_test/flutter_test.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/features/sizing/logic/sizing_calculator.dart';
import 'package:solartide/models/sizing_result.dart';

SizingInput input({
  double dailyWh = 3000,
  int peakWatts = 1500,
  double psh = 5,
  bool batteries = true,
  int autonomy = 1,
  int voltage = 24,
}) =>
    SizingInput(
      dailyWh: dailyWh,
      peakWatts: peakWatts,
      peakSunHours: psh,
      sunHoursSource: SunHoursSource.nasaPower,
      withBatteries: batteries,
      autonomyDays: autonomy,
      systemVoltage: voltage,
    );

void main() {
  test('load sheet sums energy and assumes everything on at once for peak', () {
    final i = SizingInput.fromAppliances(
      const [
        Appliance(name: 'Fridge', watts: 150, hoursPerDay: 10),
        Appliance(name: 'Bulbs', watts: 9, quantity: 6, hoursPerDay: 5),
      ],
      peakSunHours: 5,
      sunHoursSource: SunHoursSource.fallback,
    );
    expect(i.dailyWh, 1500 + 270);
    expect(i.peakWatts, 150 + 54);
  });

  test('array: daily energy over sun hours and performance ratio, rounded up to whole panels', () {
    final r = SizingCalculator.size(input(), defaultCatalogue);
    expect(r.arrayWatts, closeTo(800, 0.01)); // 3000 / (5 × 0.75)
    expect(r.panelWatts, 450);
    expect(r.panelCount, 2);
  });

  test('inverter: smallest catalogue rating above peak × 1.25', () {
    final r = SizingCalculator.size(input(peakWatts: 1500), defaultCatalogue);
    expect(r.inverterWatts, 1875);
    expect(r.inverterOptionId, '2000w');
  });

  test('inverter too big for the catalogue picks nothing', () {
    final r = SizingCalculator.size(input(peakWatts: 9000), defaultCatalogue);
    expect(r.inverterOptionId, isNull);
    expect(SizingCalculator.inverterFits(r), isFalse);
  });

  test('batteries: bank covers autonomy after depth of discharge, cheapest capacity wins', () {
    final r = SizingCalculator.size(input(dailyWh: 3000, autonomy: 1, voltage: 24), defaultCatalogue);
    expect(r.batteryWh, 3750); // 3000 / 0.8
    // Default prices scale with capacity, so the smallest bank that holds
    // 3750 Wh costs least: 2 × 12 V in series per string.
    expect(r.batteryCount.isEven, isTrue);
    expect(r.batteryOptionId, isNotNull);
  });

  test('no batteries when the client does not want them', () {
    final r = SizingCalculator.size(input(batteries: false), defaultCatalogue);
    expect(r.batteryWh, 0);
    expect(r.batteryOptionId, isNull);
  });

  test('applyToLines fills panels, inverter and batteries only', () {
    final r = SizingCalculator.size(input(), defaultCatalogue);
    final lines = SizingCalculator.applyToLines(QuoteCalculator.linesFor(defaultCatalogue), r, defaultCatalogue);
    final byId = {for (final l in lines) l.itemId: l};
    expect(byId[CatalogueIds.panels]!.quantity, r.panelCount);
    expect(byId[CatalogueIds.inverter]!.selections.single.optionId, '2000w');
    expect(byId[CatalogueIds.batteries]!.quantity, r.batteryCount);
    expect(byId['busbar']!.state, LineState.pending);
  });

  test('without batteries the battery line is marked not required', () {
    final r = SizingCalculator.size(input(batteries: false), defaultCatalogue);
    final lines = SizingCalculator.applyToLines(QuoteCalculator.linesFor(defaultCatalogue), r, defaultCatalogue);
    expect(lines.firstWhere((l) => l.itemId == CatalogueIds.batteries).state, LineState.notRequired);
  });
}
