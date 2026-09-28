import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Icon, word and color together — never color alone (STYLE_GUIDE §5.8).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.icon, required this.accent});

  StatusChip.status(StatusStyle status, AppPalette palette, {super.key})
      : label = status.label,
        icon = status.icon,
        accent = status.accent(palette);

  final String label;
  final IconData icon;
  final Accent accent;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.chipPaddingH, vertical: AppSpace.xs),
        decoration: BoxDecoration(color: accent.bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSize.iconChip, color: accent.on),
            const SizedBox(width: AppSpace.xs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(color: accent.on),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Anything that renders as a status chip. Enums implement this so the
/// icon/word/color mapping for each status lives next to the status itself
/// (see `QuoteStatus`, `LineState`).
abstract interface class StatusStyle {
  String get label;
  IconData get icon;
  Accent accent(AppPalette palette);
}

/// Convenience for the common case.
class StatusStyleChip extends StatelessWidget {
  const StatusStyleChip(this.status, {super.key});

  final StatusStyle status;

  @override
  Widget build(BuildContext context) => StatusChip.status(status, context.palette);
}
