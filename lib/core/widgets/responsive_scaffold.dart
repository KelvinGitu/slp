import 'package:flutter/material.dart';
import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/responsive.dart';
import 'package:solartide/core/widgets/pressable.dart';

class NavItem {
  const NavItem({required this.label, required this.icon, required this.selectedIcon, this.badge = false});

  final String label;

  /// Regular weight when unselected, fill weight when selected (§5.9).
  final IconData icon;
  final IconData selectedIcon;

  /// Small dot for something that needs attention.
  final bool badge;
}

/// App shell for both roles (STYLE_GUIDE §5.9, §6.3).
///
/// - under 600: single column, bottom nav
/// - 600 to 899: single column capped at 640, bottom nav
/// - 900 and up: 240px rail, content capped at 1440
///
/// [banner] pins above the content on every tab.
/// [railFooter] sits at the bottom of the rail (the signed-in user's name and
/// settings).
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.banner,
    this.railFooter,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;
  final Widget? banner;
  final Widget? railFooter;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;

    if (size.isWide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpace.md),
                child: _Rail(items: items, selectedIndex: selectedIndex, onSelected: onSelected, footer: railFooter),
              ),
              Expanded(child: _content(AppBreakpoint.dashboardMaxContent)),
            ],
          ),
        ),
      );
    }

    final maxWidth = size == ScreenSize.medium ? AppBreakpoint.mediumMaxContent : double.infinity;
    return Scaffold(
      body: SafeArea(bottom: false, child: _content(maxWidth)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final item in items)
            NavigationDestination(
              label: item.label,
              icon: _badged(Icon(item.icon), item.badge),
              selectedIcon: _badged(Icon(item.selectedIcon), item.badge),
            ),
        ],
      ),
    );
  }

  Widget _content(double maxWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (banner != null)
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.screenH, AppSpace.sm, AppSpace.screenH, 0),
                child: banner,
              ),
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: body),
          ),
        ),
      ],
    );
  }

  static Widget _badged(Widget icon, bool badge) =>
      Badge(isLabelVisible: badge, smallSize: AppSpace.sm, backgroundColor: AppColors.danger, child: icon);
}

class _Rail extends StatelessWidget {
  const _Rail({required this.items, required this.selectedIndex, required this.onSelected, this.footer});

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: AppSize.railWidth,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.sm, AppSpace.sm, AppSpace.sm, AppSpace.xxl),
            child: Text(AppConstants.appName, style: AppText.title2.copyWith(color: p.textPrimary)),
          ),
          for (var i = 0; i < items.length; i++) _row(p, i),
          if (footer != null) ...[const Spacer(), footer!],
        ],
      ),
    );
  }

  Widget _row(AppPalette p, int i) {
    final item = items[i];
    final selected = i == selectedIndex;
    final color = selected ? p.navActive : p.navInactive;
    return Semantics(
      selected: selected,
      child: Pressable(
        onPressed: () => onSelected(i),
        haptic: false,
        child: SizedBox(
          height: AppSize.railRow,
          child: Row(
            children: [
              const SizedBox(width: AppSpace.sm),
              ResponsiveScaffold._badged(
                Icon(selected ? item.selectedIcon : item.icon, size: AppSize.iconNav, color: color),
                item.badge,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
