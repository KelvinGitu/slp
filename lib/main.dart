import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/app.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/providers/theme_provider.dart';
import 'package:solartide/core/utils/log.dart';
import 'package:solartide/firebase_options.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) => logError('uncaught', error, stack));
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolved before runApp so the first frame already uses the saved theme.
  await initializeThemePreferences();

  try {
    // A hot restart keeps the native Firebase app alive; initialising it
    // again throws duplicate-app.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    if (EmulatorConfig.enabled) await EmulatorConfig.connect();
  } catch (e, st) {
    // Keep going so the UI still renders; sign-in explains what's missing.
    logError('Firebase.initializeApp', e, st);
  }

  runApp(const ProviderScope(child: SolarTideApp()));
}
