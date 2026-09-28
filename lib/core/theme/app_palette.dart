import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Theme-dependent colors (STYLE_GUIDE §2.1, §2.3, §2.5). Widgets read these
/// through `context.palette`, never as hard-coded hex.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.scaffold,
    required this.card,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.positive,
    required this.negative,
    required this.navInactive,
    required this.navActive,
    required this.green,
    required this.sky,
    required this.amber,
    required this.orange,
    required this.coral,
    required this.lavender,
    required this.peach,
    required this.neutral,
  });

  final Color scaffold, card, surface, border;
  final Color textPrimary, textSecondary, positive, negative, navInactive, navActive;
  final Accent green, sky, amber, orange, coral, lavender, peach, neutral;

  static const light = AppPalette(
    scaffold: Color(0xFFEFEFEF),
    card: Color(0xFFF9F9F9),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE4E4E6),
    textPrimary: Color(0xFF1C2024),
    textSecondary: Color(0xFF6C6C6C),
    positive: Color(0xFF17708F),
    negative: Color(0xFF20505C),
    navInactive: Color(0xFF7B7E85),
    navActive: Color(0xFF1C2024),
    green: Accent(Color(0xFFA9EF99), Color(0xFF99DD88), Color(0xFF1B4D12)),
    sky: Accent(Color(0xFF8EE2FE), Color(0xFF75CFEA), Color(0xFF0B4A5E)),
    amber: Accent(Color(0xFFFFE28A), Color(0xFFF7CE55), Color(0xFF4A3600)),
    orange: Accent(Color(0xFFFFD0A8), Color(0xFFFF9F5A), Color(0xFF5A2A00)),
    coral: Accent(Color(0xFFFFB3AA), Color(0xFFFF9A8F), Color(0xFF5C1414)),
    lavender: Accent(Color(0xFFD3CBFF), Color(0xFFBDB1FB), Color(0xFF2E1F7A)),
    // Peach and neutral have no `strong` in the guide; bg stands in so the
    // field is never null.
    peach: Accent(Color(0xFFE2BDB0), Color(0xFFE2BDB0), Color(0xFF5A2E22)),
    // DEPARTURE from STYLE_GUIDE §2.3: the guide's neutral `on` (#6C6C6C) is
    // 4.14:1 on #E4E4E6, below the 4.5:1 its own §9 requires for the Offline
    // chip's 12sp caption. Darkened to #5C5C5C (5.27:1).
    neutral: Accent(Color(0xFFE4E4E6), Color(0xFFE4E4E6), Color(0xFF5C5C5C)),
  );

  static const dark = AppPalette(
    scaffold: Color(0xFF0F1114),
    card: Color(0xFF171A1E),
    surface: Color(0xFF1E2227),
    border: Color(0xFF2A2F35),
    textPrimary: Color(0xFFF2F4F5),
    textSecondary: Color(0xFF9AA1A8),
    positive: Color(0xFF4CC3E8),
    negative: Color(0xFF7FB3C4),
    navInactive: Color(0xFF7A8087),
    navActive: Color(0xFFF2F4F5),
    green: Accent(Color(0xFF1E3B1A), Color(0xFF2B5324), Color(0xFFA9EF99)),
    sky: Accent(Color(0xFF0F3442), Color(0xFF174A5C), Color(0xFF8EE2FE)),
    amber: Accent(Color(0xFF3D3210), Color(0xFF54451A), Color(0xFFF7CE55)),
    orange: Accent(Color(0xFF40260F), Color(0xFF5C3717), Color(0xFFFFB27A)),
    coral: Accent(Color(0xFF4A1B1E), Color(0xFF652528), Color(0xFFFFB3AA)),
    lavender: Accent(Color(0xFF2A2450), Color(0xFF3A3270), Color(0xFFD3CBFF)),
    // The guide gives no dark peach. Avatars are the only use, so the light
    // pair is kept: it reads as a photo-like disc on either canvas.
    peach: Accent(Color(0xFFE2BDB0), Color(0xFFE2BDB0), Color(0xFF5A2E22)),
    neutral: Accent(Color(0xFF242A30), Color(0xFF242A30), Color(0xFF9AA1A8)),
  );

  // Themes switch instantly, so a simple threshold is enough here.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette && t >= 0.5 ? other : this;

  @override
  AppPalette copyWith() => this; // not used
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
