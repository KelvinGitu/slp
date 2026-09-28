import 'package:flutter/widgets.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// The four layout sizes (STYLE_GUIDE §6.3).
///
/// - compact, under 600: phone, bottom nav, pages pushed on top
/// - medium, 600 to 899: the same, centred at 640
/// - expanded, 900 to 1199: nav rail; a detail replaces its list in place
/// - large, 1200 and up: nav rail; a detail sits in a panel beside its list
enum ScreenSize {
  compact,
  medium,
  expanded,
  large;

  static ScreenSize of(double width) {
    if (width >= AppBreakpoint.large) return large;
    if (width >= AppBreakpoint.wide) return expanded;
    if (width >= AppBreakpoint.medium) return medium;
    return compact;
  }

  /// Rail and dashboard layouts.
  bool get isWide => this == expanded || this == large;
}

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => ScreenSize.of(MediaQuery.sizeOf(this).width);

  bool get isWide => screenSize.isWide;

  /// Room for a detail panel beside a table.
  bool get hasSidePanel => screenSize == ScreenSize.large;
}
