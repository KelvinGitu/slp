import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/providers/theme_provider.dart';
import 'package:solartide/core/theme/app_theme.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Built once: rebuilding ThemeData on every frame triggers a theme cross-fade
// on navigation.
final _lightTheme = buildTheme(Brightness.light);
final _darkTheme = buildTheme(Brightness.dark);

class SolarTideApp extends ConsumerStatefulWidget {
  const SolarTideApp({super.key});

  @override
  ConsumerState<SolarTideApp> createState() => _SolarTideAppState();
}

class _SolarTideAppState extends ConsumerState<SolarTideApp> {
  RouteStage? _stage;
  late RoutemasterDelegate _delegate;

  @override
  void initState() {
    super.initState();
    // A new account (or the next person on a shared browser) starts on Home
    // with nothing selected.
    ref.listenManual<String?>(currentUidProvider, (previous, next) {
      if (previous != next) {
        ref.read(appTabProvider.notifier).state = AppTab.home;
        ref.read(detailSelectionProvider.notifier).state = null;
      }
    });
  }

  /// The delegate is recreated only when the stage changes (sign in, sign
  /// out, setup done). Routemaster carries its state across a new delegate
  /// and rebuilds from the new route map; a theme change doesn't touch
  /// routing.
  RoutemasterDelegate _delegateFor(RouteStage stage) {
    if (stage != _stage) {
      _stage = stage;
      final routes = routesFor(stage);
      _delegate = RoutemasterDelegate(navigatorKey: navigatorKey, routesBuilder: (_) => routes);
    }
    return _delegate;
  }

  @override
  Widget build(BuildContext context) {
    final stage = ref.watch(routeStageProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: Duration.zero,
      routerDelegate: _delegateFor(stage),
      routeInformationParser: const RoutemasterParser(),
      builder: (context, child) {
        // Layouts are built to survive 1.5x (STYLE_GUIDE §3); beyond that the
        // totals and stat cards can't hold their layout.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(maxScaleFactor: 1.5)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
