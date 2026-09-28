import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// The mint call to action (STYLE_GUIDE §5.4). Only one per screen.
///
/// Styling comes from the theme's FilledButton; this adds the fixed-size
/// loading state so the button never jumps when it starts spinning.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.isLoading = false});

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.primaryButton),
      child: FilledButton(
        // A loading button stays mint (not the disabled gray) but ignores taps.
        onPressed: onPressed == null
            ? null
            : () {
                if (isLoading) return;
                // Light impact on press (§8).
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: AnimatedSwitcher(
          duration: MediaQuery.of(context).disableAnimations ? Duration.zero : AppDuration.stateChange,
          switchInCurve: Curves.easeOutCubic,
          child: isLoading
              ? const SizedBox.square(
                  key: ValueKey('loading'),
                  dimension: AppSize.iconInline,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onMint),
                )
              : Text(label, key: ValueKey(label), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
