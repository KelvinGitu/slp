import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Empty list (STYLE_GUIDE §5.15): neutral circle and icon, one strong
/// sentence, one quiet one. No illustrations.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xxxl, horizontal: AppSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSize.emptyCircle,
            height: AppSize.emptyCircle,
            decoration: BoxDecoration(color: p.neutral.bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: AppSize.emptyIcon, color: p.neutral.on),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(title, textAlign: TextAlign.center, style: AppText.bodyStrong.copyWith(color: p.textPrimary)),
          const SizedBox(height: AppSpace.xs),
          Text(message, textAlign: TextAlign.center, style: AppText.label.copyWith(color: p.textSecondary)),
          if (action != null) ...[
            const SizedBox(height: AppSpace.xl),
            action!,
          ],
        ],
      ),
    );
  }
}
