import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Press feedback for pills, cards and chips: scale to 0.97 over 100 ms, no
/// ripple (STYLE_GUIDE §5.3, §8). Skipped when the OS asks for no animation.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onPressed, this.semanticLabel, this.haptic = true});

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Light impact on press (§8). Off for controls that fire their own.
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (widget.onPressed == null || _down == down) return;
    setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final enabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _down && !reduceMotion ? AppOpacity.pressScale : 1,
          duration: reduceMotion ? Duration.zero : AppDuration.press,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
