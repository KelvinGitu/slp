import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/status_chip.dart';

/// Where a quote is in the sale. Shown as icon, word and color together
/// (STYLE_GUIDE §2.4); each maps to an existing accent family.
enum QuoteStatus implements StatusStyle {
  draft('Draft', PhosphorIconsRegular.pencilSimple),
  sent('Sent', PhosphorIconsRegular.paperPlaneTilt),
  accepted('Accepted', PhosphorIconsRegular.checkCircle),
  installed('Installed', PhosphorIconsRegular.solarPanel),
  declined('Declined', PhosphorIconsRegular.xCircle);

  const QuoteStatus(this.label, this.icon);

  @override
  final String label;
  @override
  final IconData icon;

  @override
  Accent accent(AppPalette p) => switch (this) {
        QuoteStatus.draft => p.neutral,
        QuoteStatus.sent => p.sky,
        QuoteStatus.accepted => p.green,
        QuoteStatus.installed => p.lavender,
        QuoteStatus.declined => p.coral,
      };

  /// Whether the quote counts towards won business on the dashboard.
  bool get isWon => this == QuoteStatus.accepted || this == QuoteStatus.installed;

  static QuoteStatus fromName(String? name) =>
      QuoteStatus.values.firstWhere((s) => s.name == name, orElse: () => QuoteStatus.draft);
}
