/// Theme setting (STYLE_GUIDE §2.5). [system] is the default.
enum ThemePreference {
  system('System'),
  light('Light'),
  dark('Dark');

  const ThemePreference(this.label);
  final String label;
}
