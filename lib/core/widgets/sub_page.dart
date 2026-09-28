import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/detail_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A pushed screen: back button, title, scrolling content with the standard
/// padding, and an optional pinned bottom action (the screen's one mint
/// button). Content is capped at [maxWidth] so forms stay readable in a
/// browser.
///
/// Inside a dashboard [DetailPanelScope] the same page drops its app bar and
/// shows a title row with a close button instead (STYLE_GUIDE §6.3).
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
    this.actions,
    this.maxWidth = AppBreakpoint.mediumMaxContent,
  });

  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final List<Widget>? actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final panel = DetailPanelScope.maybeOf(context);
    if (panel != null) return _panel(p, panel.onClose);
    // Centred as a column, but each child fills the column's full width, so
    // headings and short text stay left-aligned instead of centring.
    Widget capped(Widget child) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(width: double.infinity, child: child),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                icon: Icon(PhosphorIconsRegular.arrowLeft, color: p.textPrimary),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(title, style: AppText.title1.copyWith(color: p.textPrimary)),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpace.screenH, AppSpace.sm, AppSpace.screenH, AppSpace.section),
                children: [for (final c in children) capped(c)],
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.screenH, AppSpace.sm, AppSpace.screenH, AppSpace.lg),
                child: capped(bottom!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _panel(AppPalette p, VoidCallback onClose) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.lg, AppSpace.sm, AppSpace.sm),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: AppText.title1.copyWith(color: p.textPrimary)),
                ),
              ),
              ...?actions,
              IconButton(
                tooltip: 'Close',
                icon: Icon(PhosphorIconsRegular.x, size: AppSize.iconInline, color: p.textPrimary),
                style: IconButton.styleFrom(minimumSize: const Size.square(AppSize.minTouch)),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.sm, AppSpace.xl, AppSpace.section),
            children: children,
          ),
        ),
        if (bottom != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.sm, AppSpace.xl, AppSpace.lg),
            child: bottom,
          ),
      ],
    );
  }
}

/// Section label above a group of fields or rows.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpace.section, bottom: AppSpace.md),
        child: Semantics(
          header: true,
          child: Text(text, style: AppText.title2.copyWith(color: context.palette.textPrimary)),
        ),
      );
}
