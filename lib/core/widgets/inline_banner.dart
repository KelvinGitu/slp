import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/pressable.dart';

/// GPS, connection and battery messages (STYLE_GUIDE §5.13). The family says
/// how serious it is: coral for blockers, amber for warnings, neutral for
/// offline.
class InlineBanner extends StatelessWidget {
  const InlineBanner({super.key, required this.accent, required this.icon, required this.message, this.actionLabel, this.onAction});

  final Accent accent;
  final IconData icon;
  final String message;

  /// Inner button, e.g. "Settings" on the location-off banner.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
        decoration: BoxDecoration(color: accent.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Row(
          children: [
            Icon(icon, size: AppSize.iconInline, color: accent.on),
            const SizedBox(width: AppSpace.md),
            Expanded(child: Text(message, style: AppText.label.copyWith(color: accent.on))),
            if (actionLabel != null) ...[
              const SizedBox(width: AppSpace.md),
              Pressable(
                onPressed: onAction,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSize.minTouch),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
                      decoration: BoxDecoration(color: accent.strong, borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Text(actionLabel!, style: AppText.bodyStrong.copyWith(color: accent.on)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
