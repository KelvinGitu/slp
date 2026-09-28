import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// A tab's scrollable page: section title, then content with the standard
/// screen padding and section gaps.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.title, required this.children, this.trailing});

  final String title;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.screenH, AppSpace.xl, AppSpace.screenH, AppSpace.section),
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppText.title1.copyWith(color: p.textPrimary)),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpace.section),
        ...children,
      ],
    );
  }
}
