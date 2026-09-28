import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Logs the real error behind a friendly message. The UI shows calm copy
/// (STYLE_GUIDE §10); this is what a developer needs to see in the console.
/// Debug builds only: release builds report through Crashlytics instead.
void logError(String where, Object error, [StackTrace? stack]) {
  if (!kDebugMode) return;
  debugPrint('[$where] ${error.runtimeType}: $error');
  developer.log('$error', name: where, error: error, stackTrace: stack, level: 1000);
}

/// Traces a step while debugging. Debug builds only.
void logDebug(String where, String message) {
  if (!kDebugMode) return;
  debugPrint('[$where] $message');
}
