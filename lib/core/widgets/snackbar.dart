import 'dart:async';
import 'dart:ui' show FlutterView;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Short, calm feedback (STYLE_GUIDE §10). Errors use the same styling; the
/// copy carries the meaning, and red stays reserved for real errors.
///
/// Drawn on the root overlay rather than through ScaffoldMessenger: a
/// SnackBar belongs to the page's Scaffold, so one raised from inside a
/// bottom sheet or dialog appeared *under* it and was missed. The overlay sits
/// above every route, sheet and dialog.
void showSnackBar(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _current?.dismiss();
  _current = _Toast(overlay, message, Directionality.of(context), View.of(context))..show();
}

_Toast? _current;

class _Toast {
  _Toast(this._overlay, this._message, this._direction, this._view);

  final OverlayState _overlay;
  final String _message;
  final TextDirection _direction;
  final FlutterView _view;

  static const _visibleFor = Duration(seconds: 4);

  late final OverlayEntry _entry = OverlayEntry(builder: (_) => _ToastView(message: _message, onDismiss: dismiss));
  Timer? _timer;
  bool _removed = false;

  void show() {
    _overlay.insert(_entry);
    // Screen readers hear it too, as a SnackBar would announce itself.
    SemanticsService.sendAnnouncement(_view, _message, _direction);
    _timer = Timer(_visibleFor, dismiss);
  }

  void dismiss() {
    _timer?.cancel();
    if (_removed) return;
    _removed = true;
    _entry.remove();
    if (identical(_current, this)) _current = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    // Fade in on the next frame (200 ms, §8).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations;
    // Above the keyboard when it's open, else above the system nav bar.
    final bottom = (media.viewInsets.bottom > 0 ? media.viewInsets.bottom : media.viewPadding.bottom) + AppSpace.lg;

    return Positioned(
      left: AppSpace.screenH,
      right: AppSpace.screenH,
      bottom: bottom,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoint.mediumMaxContent),
          child: AnimatedOpacity(
            opacity: _shown || reduceMotion ? 1 : 0,
            duration: reduceMotion ? Duration.zero : AppDuration.stateChange,
            curve: Curves.easeOutCubic,
            child: Material(
              color: p.textPrimary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: widget.onDismiss,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
                  child: Text(widget.message, style: AppText.body.copyWith(color: p.scaffold)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
