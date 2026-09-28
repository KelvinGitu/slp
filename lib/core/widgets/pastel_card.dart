import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/pressable.dart';

/// Pastel feature card with an inner button in the deeper `strong` shade
/// (STYLE_GUIDE §5.5). Used for quick actions.
class PastelCard extends StatelessWidget {
  const PastelCard({
    super.key,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.onPressed,
    this.artworkIcon,
    this.width,
  });

  final Accent accent;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onPressed;

  /// Optional artwork, cropped by the bottom-right edge like the reference.
  /// A large line icon keeps it flat and simple.
  final IconData? artworkIcon;

  /// 280 inside a horizontal scroller; null to fill the parent.
  final double? width;

  static const double _artworkSize = 96;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: accent.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Stack(
        children: [
          if (artworkIcon != null)
            Positioned(
              right: -AppSpace.lg,
              bottom: -AppSpace.lg,
              child: ExcludeSemantics(
                child: Icon(artworkIcon, size: _artworkSize, color: accent.strong),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.title2.copyWith(color: accent.on)),
                const SizedBox(height: AppSpace.xs),
                Text(
                  subtitle,
                  style: AppText.label.copyWith(color: accent.on.withValues(alpha: AppOpacity.subtitleOnPastel)),
                ),
                const SizedBox(height: AppSpace.lg),
                _InnerButton(label: buttonLabel, accent: accent, onPressed: onPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerButton extends StatelessWidget {
  const _InnerButton({required this.label, required this.accent, this.onPressed});

  final String label;
  final Accent accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      child: ConstrainedBox(
        // Visually 40 tall; the hit area still meets 48 through Pressable's
        // opaque padding below.
        constraints: const BoxConstraints(minHeight: AppSize.minTouch),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSize.innerButton),
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl, vertical: AppSpace.sm),
            decoration: BoxDecoration(color: accent.strong, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Text(label, style: AppText.bodyStrong.copyWith(color: accent.on)),
          ),
        ),
      ),
    );
  }
}

/// Dashboard stat card: big number on top, label beneath (§5.5, stat variant).
class PastelStatCard extends StatelessWidget {
  const PastelStatCard({super.key, required this.accent, required this.value, required this.label, this.icon, this.onPressed});

  final Accent accent;
  final String value;
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(color: accent.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.display.copyWith(color: accent.on)),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSize.iconChip, color: accent.on),
                const SizedBox(width: AppSpace.xs),
              ],
              Flexible(child: Text(label, style: AppText.label.copyWith(color: accent.on))),
            ],
          ),
        ],
      ),
    );
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: onPressed == null ? card : Pressable(onPressed: onPressed, child: card),
    );
  }
}
