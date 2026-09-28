import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/providers/clock_provider.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/theme/app_theme.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/features/clients/providers/client_providers.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';
import 'package:solartide/features/sizing/providers/sizing_providers.dart';
import 'package:solartide/features/sizing/repository/irradiance_repository.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/client_model.dart';
import 'package:solartide/models/quote_model.dart';
import 'package:solartide/models/user_model.dart';

/// 19:00 on 20 April 2026.
final fixedNow = DateTime(2026, 4, 20, 19);

final testUser = UserModel(uid: 'u1', name: 'Wanjiku Kamau', email: 'w@example.co.ke', createdAt: fixedNow);

const testBusiness = BusinessProfile(
  name: 'Jua Power Installers',
  phone: '0712 345 678',
  mpesaPaybill: '247247',
  mpesaAccount: 'JUA',
);

final testClient = ClientModel(
  id: 'c1',
  name: 'Otieno Family Residence with a long name',
  phone: '0722 000 111',
  location: 'Kisumu',
  createdAt: fixedNow,
);

/// A draft with a few lines added, one not required, the rest to do.
QuoteModel testQuote({QuoteStatus status = QuoteStatus.draft}) {
  final byId = {for (final i in defaultCatalogue) i.id: i};
  var lines = QuoteCalculator.linesFor(defaultCatalogue);
  QuoteLine line(String id) => lines.firstWhere((l) => l.itemId == id);
  final changed = [
    QuoteCalculator.include(byId['panels']!, line('panels'), inputs: {'count': 12}),
    QuoteCalculator.include(byId['inverter']!, line('inverter'), picks: [(optionId: '5000w', quantity: 1)]),
    QuoteCalculator.include(byId['batteries']!, line('batteries'), picks: [(optionId: '200ah', quantity: 8)]),
    QuoteCalculator.include(byId['earthing']!, line('earthing'), picks: [
      (optionId: 'rod', quantity: 2),
      (optionId: 'cable_16mm', quantity: 25),
    ]),
    QuoteCalculator.include(byId['labour']!, line('labour'), inputs: {'technicians': 4, 'days': 3}),
    QuoteCalculator.notRequired(line('busbar')),
  ];
  for (final c in changed) {
    lines = [for (final l in lines) l.itemId == c.itemId ? c : l];
  }
  return QuoteModel(
    id: 'q1',
    number: 'ST-2026-0007',
    client: testClient.toSnapshot(),
    status: status,
    lines: lines,
    markupPercent: 10,
    vatPercent: 16,
    totals: QuoteCalculator.totals(lines, markupPercent: 10, vatPercent: 16),
    createdAt: fixedNow,
    updatedAt: fixedNow,
    validUntil: fixedNow.add(const Duration(days: 30)),
    notes: 'Two-year workmanship warranty.',
  );
}

/// Overrides that make any signed-in screen pumpable without Firebase,
/// the network or real time.
List<Override> signedInOverrides({List<QuoteModel>? quotes}) {
  final list = quotes ?? [testQuote(), testQuote(status: QuoteStatus.accepted)];
  return [
    firebaseReadyProvider.overrideWithValue(false),
    currentUidProvider.overrideWithValue(testUser.uid),
    currentUserProvider.overrideWithValue(testUser),
    nowProvider.overrideWith((ref) => Stream.value(fixedNow)),
    businessProfileProvider.overrideWith((ref) => Stream.value(testBusiness)),
    clientsProvider.overrideWith((ref) => Stream.value([testClient])),
    quotesProvider.overrideWith((ref) => Stream.value(list)),
    quoteProvider.overrideWith((ref, id) => Stream.value(list.firstWhere((q) => q.id == id))),
    sunHoursProvider.overrideWith((ref, place) async => const SunHours(annual: 5.8, lowestMonth: 4.7)),
  ];
}

/// Pumps [child] inside the app theme at a given size, brightness and text
/// scale. Overflow and layout errors fail the test.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
  Size size = const Size(360, 800),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildTheme(brightness),
        home: MediaQuery(
          data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    ),
  );
  // Streams and futures resolve over a couple of frames. Not pumpAndSettle:
  // shimmer placeholders animate forever.
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Every combination the style guide says to check (§12, rule 3), on a small
/// phone and a 1280 px browser window.
const variants = [
  (Brightness.light, 1.0, Size(360, 800)),
  (Brightness.light, 1.5, Size(360, 800)),
  (Brightness.dark, 1.0, Size(360, 800)),
  (Brightness.dark, 1.5, Size(360, 800)),
  (Brightness.light, 1.0, Size(1280, 800)),
  (Brightness.dark, 1.5, Size(1280, 800)),
];

String describe((Brightness, double, Size) v) => '${v.$1.name} @${v.$2}x ${v.$3.width.round()}px';

