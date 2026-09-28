import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/status_chip.dart';

/// Where one component of a quote stands. The original app showed "Done" in
/// orange and "NR" in purple; this keeps the meaning with icon + word + color.
enum LineState implements StatusStyle {
  pending('To do', PhosphorIconsRegular.circleDashed),
  included('Added', PhosphorIconsRegular.checkCircle),
  notRequired('Not required', PhosphorIconsRegular.minusCircle);

  const LineState(this.label, this.icon);

  @override
  final String label;
  @override
  final IconData icon;

  @override
  Accent accent(AppPalette p) => switch (this) {
        LineState.pending => p.amber,
        LineState.included => p.green,
        LineState.notRequired => p.neutral,
      };

  /// Pending lines still need a decision before the quote is finished.
  bool get isDecided => this != LineState.pending;

  static LineState fromName(String? name) =>
      LineState.values.firstWhere((s) => s.name == name, orElse: () => LineState.pending);
}
