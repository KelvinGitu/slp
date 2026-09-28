import 'package:flutter/material.dart';

/// Text styles (STYLE_GUIDE §3). Colors are applied at the call site from
/// `context.palette`; these carry size, weight and tracking only.
abstract final class AppText {
  /// Bundled in assets/fonts/GoogleSans (see pubspec.yaml).
  static const fontFamily = 'GoogleSans';

  static const _tab = [FontFeature.tabularFigures()];

  static const display = TextStyle(fontSize: 40, height: 44 / 40, fontWeight: FontWeight.w700, letterSpacing: -0.8, fontFeatures: _tab);
  static const title1 = TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w500);
  static const title2 = TextStyle(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w500);
  static const body = TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const bodyStrong = TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w500);
  static const amount = TextStyle(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w500, fontFeatures: _tab);
  static const label = TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const caption = TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.1);
}
