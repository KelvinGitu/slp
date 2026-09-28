import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/pressable.dart';

/// White pill for secondary actions (STYLE_GUIDE §5.3).
///
/// [selected] is the report-filter variant (§6.4): textPrimary fill with
/// surface text. [outlined] adds the 1px border for low-emphasis actions (§5.4).
/// [accent] tints it with a pastel family (quick actions on Home).
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.selected = false,
    this.outlined = false,
    this.height = AppSize.pillButton,
    this.expand = false,
    this.accent,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool selected;
  final bool outlined;
  final double height;

  /// Fill the available width instead of hugging the content.
  final bool expand;

  /// Fill with the family's `bg` and draw the label and icon in its `on`.
  final Accent? accent;

  static const double horizontalPadding = AppSpace.lg;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = accent;
    final fg = selected
        ? p.surface
        : onPressed == null
            ? p.textSecondary
            : a?.on ?? p.textPrimary;

    return Pressable(
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height, minWidth: AppSize.minTouch),
        child: Container(
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: AppSpace.sm),
          decoration: BoxDecoration(
            color: selected ? p.textPrimary : a?.bg ?? p.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: outlined ? Border.all(color: p.border) : null,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSize.iconInline, color: fg),
                const SizedBox(width: AppSpace.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PillAction {
  const PillAction({required this.label, required this.icon, this.onPressed, this.accent});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Accent? accent;
}

/// Pills sharing the width equally with 12px gaps (§5.3).
///
/// When the labels don't fit side by side — a 360 px phone, or text scaled to
/// 1.5 — the pills stack full-width instead of truncating. The decision is
/// made by measuring the real labels, not by guessing at a breakpoint.
class PillActionRow extends StatelessWidget {
  const PillActionRow({super.key, required this.actions});

  final List<PillAction> actions;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = AppSpace.md * (actions.length - 1);
        final slot = (constraints.maxWidth - gaps) / actions.length;
        final fits = actions.every((a) => _contentWidth(a.label, scaler) <= slot);

        if (fits) {
          return Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpace.md),
                Expanded(child: _pill(actions[i], expand: true)),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpace.md),
              _pill(actions[i], expand: true),
            ],
          ],
        );
      },
    );
  }

  Widget _pill(PillAction a, {required bool expand}) =>
      PillButton(label: a.label, icon: a.icon, onPressed: a.onPressed, expand: expand, accent: a.accent);

  static double _contentWidth(String label, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: AppText.bodyStrong.copyWith(fontFamily: AppText.fontFamily)),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width + AppSize.iconInline + AppSpace.sm + PillButton.horizontalPadding * 2;
  }
}
