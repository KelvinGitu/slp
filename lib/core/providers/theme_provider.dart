import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solartide/core/enums/theme_preference.dart';

// Resolved in main() before runApp so the first frame already reflects the
// saved preference instead of flashing the system theme.
SharedPreferences? _globalPrefs;

Future<void> initializeThemePreferences() async {
  try {
    _globalPrefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Theme preferences unavailable: $e');
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemePreference>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemePreference> {
  static const _key = 'theme_preference';

  ThemeNotifier() : super(ThemePreference.system) {
    final saved = _globalPrefs?.getString(_key);
    if (saved != null) {
      state = ThemePreference.values.firstWhere((e) => e.name == saved, orElse: () => ThemePreference.system);
    }
  }

  Future<void> setTheme(ThemePreference theme) async {
    state = theme;
    await _globalPrefs?.setString(_key, theme.name);
  }
}

final themeModeProvider = Provider<ThemeMode>((ref) {
  return switch (ref.watch(themeNotifierProvider)) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
});
