import 'package:flutter/material.dart';

/// Spacing on a 4-point grid (STYLE_GUIDE §4).
abstract final class AppSpace {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24, xxxl = 32, huge = 40;

  /// Horizontal padding for every screen.
  static const double screenH = 20;

  /// Vertical gap between sections.
  static const double section = 24;
}

abstract final class AppRadius {
  static const double sm = 8, md = 12, lg = 16, xl = 24, pill = 999;
}

/// Fixed component dimensions from STYLE_GUIDE §5. Kept here so widgets never
/// carry magic numbers (§12, rule 1).
abstract final class AppSize {
  // Icons (§7).
  static const double iconChip = 14, iconInline = 20, iconNav = 24, iconHero = 48;

  // Buttons.
  static const double pillButton = 48;
  static const double primaryButton = 56;
  static const double innerButton = 40;
  static const double bannerButton = 44;
  static const double minTouch = 48;

  // Rows, chips, inputs.
  static const double listRow = 64;

  /// Widest a list row's trailing value (chip, time) may get before it
  /// truncates, so the title always keeps room.
  static const double listTrailingMax = 176;
  static const double avatar = 40;
  static const double chip = 28;
  static const double chipPaddingH = 10;
  static const double input = 56;

  /// A quantity field beside an option (cable lugs, piping).
  static const double qtyField = 96;

  // Navigation (§5.9, §6.3).
  static const double bottomNav = 72;
  static const double railWidth = 240;
  static const double railRow = 48;

  // Wide layouts (§6.3): the detail panel beside a list, and table rows (§6.4).
  static const double detailPanel = 420;
  static const double tableRow = 56;

  // Pastel feature card in a horizontal scroller (§5.5).
  static const double featureCardWidth = 280;


  // Drag handle on scrollable bottom sheets.
  static const Size sheetHandle = Size(40, 4);

  // Empty state (§5.15).
  static const double emptyCircle = 64;
  static const double emptyIcon = 28;



}

/// Responsive breakpoints (§6.3).
abstract final class AppBreakpoint {
  static const double medium = 600;
  static const double wide = 900;
  static const double large = 1200;
  static const double mediumMaxContent = 640;
  static const double wideMaxContent = 1200;

  /// The dashboard's content cap beside the rail.
  static const double dashboardMaxContent = 1440;
}

/// Motion (§8).
abstract final class AppDuration {
  static const press = Duration(milliseconds: 100);
  static const stateChange = Duration(milliseconds: 200);
  static const sheet = Duration(milliseconds: 250);
  static const page = Duration(milliseconds: 300);
}

abstract final class AppOpacity {
  static const double subtitleOnPastel = 0.8;
  static const double scrim = 0.4;
  static const double pressScale = 0.97;
}

class Accent {
  const Accent(this.bg, this.strong, this.on);

  /// Card or chip fill.
  final Color bg;

  /// Button that sits inside a card of [bg].
  final Color strong;

  /// Text and icons on both [bg] and [strong].
  final Color on;
}

/// Colors that are the same in light and dark (§2.2).
abstract final class AppColors {
  static const mint = Color(0xFF36E3C5);
  static const mintBorder = Color(0xFF29CDB0);
  static const onMint = Color(0xFF0A4A40);
  /// Reserved for real errors and destructive failures. Never decorative.
  static const danger = Color(0xFFD92D32);
  static const onDanger = Colors.white;
  static const scrim = Colors.black;
  static const onScrim = Colors.white;
}
