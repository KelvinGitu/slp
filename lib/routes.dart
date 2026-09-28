import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/auth/views/screens/login_screen.dart';
import 'package:solartide/features/auth/views/screens/sign_up_screen.dart';
import 'package:solartide/features/auth/views/screens/splash_screen.dart';
import 'package:solartide/features/business/views/screens/business_profile_screen.dart';
import 'package:solartide/features/business/views/screens/setup_screen.dart';
import 'package:solartide/features/catalogue/views/screens/catalogue_item_screen.dart';
import 'package:solartide/features/catalogue/views/screens/catalogue_screen.dart';
import 'package:solartide/features/clients/views/screens/client_detail_screen.dart';
import 'package:solartide/features/documents/views/screens/document_preview_screen.dart';
import 'package:solartide/features/home/views/screens/app_shell.dart';
import 'package:solartide/features/quotes/views/screens/line_editor_screen.dart';
import 'package:solartide/features/quotes/views/screens/quote_screen.dart';
import 'package:solartide/features/sizing/views/screens/sizing_screen.dart';

/// One route map per [RouteStage]. Every map redirects unknown paths to `/`,
/// so switching stages from a deep path (signing out from a quote) never
/// lands on a blank page.
///
/// Pages carry a `ValueKey` of their path so a pop never animates the wrong
/// page, as in global-events-tracker. Tabs aren't routes: the tab lives in
/// `appTabProvider`, so `/quotes/:id` stacks on the one shell at `/`.

/// Auth hasn't resolved yet. Nothing here navigates; the map switches
/// underneath once the session is known.
final resolvingRoutes = RouteMap(
  routes: {'/': (_) => const MaterialPage(child: SplashScreen())},
  onUnknownRoute: (_) => const Redirect('/'),
);

final signedOutRoutes = RouteMap(
  routes: {
    '/': (_) => const Redirect('/login'),
    '/login': (_) => const MaterialPage(key: ValueKey('login'), child: LoginScreen()),
    '/sign-up': (_) => const MaterialPage(key: ValueKey('sign-up'), child: SignUpScreen()),
  },
  onUnknownRoute: (_) => const Redirect('/'),
);

/// Signed in without a business profile. One screen until it's saved.
final setupRoutes = RouteMap(
  routes: {'/': (_) => const MaterialPage(key: ValueKey('setup'), child: SetupScreen())},
  onUnknownRoute: (_) => const Redirect('/'),
);

final signedInRoutes = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(key: ValueKey('shell'), child: AppShell()),
    '/quotes/:id': (route) {
      final id = route.pathParameters['id']!;
      return MaterialPage(key: ValueKey('quotes/$id'), child: QuoteScreen(quoteId: id));
    },
    '/quotes/:id/lines/:itemId': (route) {
      final id = route.pathParameters['id']!;
      final itemId = route.pathParameters['itemId']!;
      return MaterialPage(key: ValueKey('quotes/$id/lines/$itemId'), child: LineEditorScreen(quoteId: id, itemId: itemId));
    },
    '/quotes/:id/document': (route) {
      final id = route.pathParameters['id']!;
      final list = route.queryParameters['type'] == 'list';
      return MaterialPage(
        key: ValueKey('quotes/$id/document/$list'),
        child: DocumentPreviewScreen(quoteId: id, componentsList: list),
      );
    },
    '/clients/:id': (route) {
      final id = route.pathParameters['id']!;
      return MaterialPage(key: ValueKey('clients/$id'), child: ClientDetailScreen(clientId: id));
    },
    '/sizing': (route) => MaterialPage(
          key: const ValueKey('sizing'),
          child: SizingScreen(clientId: route.queryParameters['clientId']),
        ),
    '/settings/business': (_) => const MaterialPage(key: ValueKey('settings/business'), child: BusinessProfileScreen()),
    '/settings/catalogue': (_) => const MaterialPage(key: ValueKey('settings/catalogue'), child: CatalogueScreen()),
    '/settings/catalogue/:id': (route) {
      final id = route.pathParameters['id']!;
      return MaterialPage(key: ValueKey('settings/catalogue/$id'), child: CatalogueItemScreen(itemId: id));
    },
  },
  onUnknownRoute: (_) => const Redirect('/'),
);

RouteMap routesFor(RouteStage stage) => switch (stage) {
      RouteStage.resolving => resolvingRoutes,
      RouteStage.signedOut => signedOutRoutes,
      RouteStage.setup => setupRoutes,
      RouteStage.signedIn => signedInRoutes,
    };
