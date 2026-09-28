import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/features/auth/views/screens/login_screen.dart';
import 'package:solartide/features/auth/views/screens/sign_up_screen.dart';
import 'package:solartide/features/business/views/screens/business_profile_screen.dart';
import 'package:solartide/features/business/views/screens/setup_screen.dart';
import 'package:solartide/features/catalogue/views/screens/catalogue_item_screen.dart';
import 'package:solartide/features/catalogue/views/screens/catalogue_screen.dart';
import 'package:solartide/features/clients/views/screens/client_detail_screen.dart';
import 'package:solartide/features/clients/views/screens/clients_screen.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/home/views/screens/app_shell.dart';
import 'package:solartide/features/quotes/views/screens/line_editor_screen.dart';
import 'package:solartide/features/quotes/views/screens/quote_screen.dart';
import 'package:solartide/features/sizing/views/screens/sizing_screen.dart';

import '../helpers/pump.dart';

/// Each screen at every style-guide variant: light and dark, text scale 1.0
/// and 1.5, 360 px and 1280 px. A RenderFlex overflow fails the test.
void main() {
  final screens = <String, Widget Function()>{
    'login': () => const LoginScreen(),
    'sign up': () => const SignUpScreen(),
    'setup': () => const SetupScreen(),
    'shell (home)': () => const AppShell(),
    'quote': () => const QuoteScreen(quoteId: 'q1'),
    'line: panels (quantity, linked)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'mc4_connectors'),
    'line: labour (two inputs)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'labour'),
    'line: PV cable (length)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'pv_cable'),
    'line: batteries (choice × count)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'batteries'),
    'line: battery cable (multi)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'battery_cable'),
    'line: busbar (fixed)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'busbar'),
    'line: miscellaneous (custom)': () => const LineEditorScreen(quoteId: 'q1', itemId: 'miscellaneous'),
    'clients': () => const Scaffold(body: ClientsScreen()),
    'client detail': () => const ClientDetailScreen(clientId: 'c1'),
    'catalogue': () => const CatalogueScreen(),
    'catalogue item (options)': () => const CatalogueItemScreen(itemId: 'inverter'),
    'catalogue item (panel rating)': () => const CatalogueItemScreen(itemId: 'panels'),
    'business details': () => const BusinessProfileScreen(),
    'sizing': () => const SizingScreen(clientId: 'c1'),
  };

  for (final entry in screens.entries) {
    group(entry.key, () {
      for (final v in variants) {
        testWidgets(describe(v), (tester) async {
          await pumpThemed(
            tester,
            entry.value(),
            brightness: v.$1,
            textScale: v.$2,
            size: v.$3,
            overrides: signedInOverrides(),
          );
          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  testWidgets('login shows sign in and the sign-up link', (tester) async {
    await pumpThemed(tester, const LoginScreen(), overrides: [firebaseReadyProvider.overrideWithValue(false)]);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('New to SolarTide? Create an account'), findsOneWidget);
  });

  testWidgets('quote lists categories, the total and the finish action', (tester) async {
    await pumpThemed(tester, const QuoteScreen(quoteId: 'q1'), overrides: signedInOverrides());
    expect(find.text('ST-2026-0007'), findsOneWidget);
    expect(find.text('Panels and mounting'), findsOneWidget);
    expect(find.text('Finish quote'), findsOneWidget);
  });

  testWidgets('line editor suggests MC4 connectors from the panels', (tester) async {
    await pumpThemed(
      tester,
      const LineEditorScreen(quoteId: 'q1', itemId: 'mc4_connectors'),
      overrides: signedInOverrides(),
    );
    // 12 panels × 4 connectors, prefilled on a fresh line: KES 5,760.
    expect(find.text('KES 5,760'), findsOneWidget);
    expect(find.text('Add to quote'), findsOneWidget);
  });

  testWidgets('wide layout shows the quote beside the list', (tester) async {
    await pumpThemed(
      tester,
      const AppShell(),
      size: const Size(1280, 800),
      overrides: [
        ...signedInOverrides(),
        appTabProvider.overrideWith((ref) => AppTab.quotes),
        detailSelectionProvider.overrideWith((ref) => const QuoteSelection('q1')),
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Quotes'), findsWidgets);
    expect(find.text('ST-2026-0007'), findsWidgets);
  });

  testWidgets('sizing suggests panels from the default load', (tester) async {
    await pumpThemed(tester, const SizingScreen(clientId: 'c1'), overrides: signedInOverrides());
    expect(find.textContaining('× 450 W'), findsWidgets);
    expect(find.text('Start the quote'), findsOneWidget);
  });

  // Keeps the unused-override lint quiet if a future screen drops Riverpod.
  test('overrides build', () => expect(signedInOverrides(), isA<List<Override>>()));
}
