import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/pressable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Off-white card on the gray canvas (STYLE_GUIDE §5.6). Depth is tonal; there
/// is no shadow and no border unless [bordered] is set for a card that sits on
/// a same-tone background.
class ContentCard extends StatelessWidget {
  const ContentCard({super.key, this.title, this.onOpen, required this.child, this.bordered = false, this.padding});

  final String? title;

  /// Opens the full list. Shows the chevron when set.
  final VoidCallback? onOpen;
  final Widget child;
  final bool bordered;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: bordered ? Border.all(color: p.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            _Header(title: title!, onOpen: onOpen),
            const SizedBox(height: AppSpace.lg),
          ],
          child,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.onOpen});

  final String title;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final row = Row(
      children: [
        Flexible(child: Text(title, style: AppText.title1.copyWith(color: p.textPrimary))),
        if (onOpen != null) ...[
          const SizedBox(width: AppSpace.xs),
          Icon(PhosphorIconsRegular.caretRight, size: AppSize.iconInline, color: p.textSecondary),
        ],
      ],
    );
    if (onOpen == null) return Semantics(header: true, child: row);
    return Pressable(onPressed: onOpen, semanticLabel: 'Open $title', child: row);
  }
}

/// Two stats side by side (§5.6): [leftLabel] over [leftValue] in
/// `positive`, [rightLabel] over [rightValue] in `negative`. Used for
/// "Subtotal / VAT" style pairs.
class StatPair extends StatelessWidget {
  const StatPair({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel, leftValue, rightLabel, rightValue;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget column(String label, String value, Color color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.label.copyWith(color: p.textSecondary)),
              const SizedBox(height: AppSpace.xs),
              Text(value, style: AppText.amount.copyWith(color: color)),
            ],
          ),
        );

    return Row(
      children: [
        column(leftLabel, leftValue, p.positive),
        const SizedBox(width: AppSpace.lg),
        column(rightLabel, rightValue, p.negative),
      ],
    );
  }
}
