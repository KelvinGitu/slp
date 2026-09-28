import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Screen header (STYLE_GUIDE §5.1): menu, time-of-day greeting over the name,
/// then the date and a bell with an unread dot.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.name, required this.now, this.onMenu, this.onBell, this.hasUnread = false});

  final String name;

  /// Local time; drives the greeting and the date.
  final DateTime now;
  final VoidCallback? onMenu;
  final VoidCallback? onBell;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // No menu on the wide dashboard, where the rail holds settings.
        if (onMenu != null) ...[
          IconButton(
            onPressed: onMenu,
            tooltip: 'Menu',
            icon: Icon(PhosphorIconsRegular.equals, size: AppSize.iconInline, color: p.textPrimary),
            style: IconButton.styleFrom(minimumSize: const Size.square(AppSize.minTouch)),
          ),
          const SizedBox(width: AppSpace.xs),
        ],
        // Greeting over the date, so both get the full width between the icons.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text('${greetingFor(now)}, $name',style: AppText.title1.copyWith(color: p.textPrimary)),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(formatDate(now), style: AppText.label.copyWith(color: p.textSecondary)),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: onBell,
          tooltip: hasUnread ? 'Alerts, unread' : 'Alerts',
          style: IconButton.styleFrom(minimumSize: const Size.square(AppSize.minTouch)),
          icon: Badge(
            isLabelVisible: hasUnread,
            smallSize: AppSpace.sm,
            backgroundColor: AppColors.danger,
            child: Icon(PhosphorIconsRegular.bell, size: AppSize.iconNav, color: p.textPrimary),
          ),
        ),
      ],
    );
  }
}
