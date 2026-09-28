import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Shared frame for sign-in, sign-up and setup: brand, a big title, a quiet
/// subtitle, then the form, centred and capped so it reads well in a browser.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.maxWidth = 440,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final double maxWidth;

  /// Pinned to the bottom, hidden while typing so the keyboard gets the room.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget capped(Widget child) => Center(
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenH),
                child: capped(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpace.huge),
                      const BrandMark(),
                      const SizedBox(height: AppSpace.huge),
                      Semantics(
                        header: true,
                        child: Text(title, style: AppText.display.copyWith(color: p.textPrimary)),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(subtitle, style: AppText.label.copyWith(color: p.textSecondary)),
                      const SizedBox(height: AppSpace.section),
                      ...children,
                      const SizedBox(height: AppSpace.section),
                    ],
                  ),
                ),
              ),
            ),
            if (footer != null && MediaQuery.viewInsetsOf(context).bottom == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
                child: capped(footer!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mark and name, on the same left edge as the rest of the screen.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: AppSize.minTouch,
          height: AppSize.minTouch,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: p.amber.bg, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Icon(PhosphorIconsRegular.sun, size: AppSize.iconNav, color: p.amber.on),
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(child: Text(AppConstants.appName, style: AppText.title2.copyWith(color: p.textPrimary))),
      ],
    );
  }
}

/// A quiet text link under a form ("Forgot password?", "Create an account").
class AuthLink extends StatelessWidget {
  const AuthLink({super.key, required this.label, required this.onPressed, this.alignment = Alignment.centerRight});

  final String label;
  final VoidCallback onPressed;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Align(
      alignment: alignment,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: p.textSecondary,
          minimumSize: const Size(AppSize.minTouch, AppSize.minTouch),
          textStyle: AppText.label.copyWith(fontFamily: AppText.fontFamily),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

/// Password field eye toggle.
class PasswordToggle extends StatelessWidget {
  const PasswordToggle({super.key, required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: visible ? 'Hide password' : 'Show password',
        onPressed: onPressed,
        icon: Icon(
          visible ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
          size: AppSize.iconInline,
          color: context.palette.textSecondary,
        ),
      );
}
