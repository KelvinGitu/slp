import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/pressable.dart';

/// List row (STYLE_GUIDE §5.7): 64 minimum, avatar, name over subtitle,
/// right-aligned value or chip. Rows are separated by space, not dividers.
class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.leading, required this.title, this.subtitle, this.trailing, this.onPressed});

  final Widget leading;
  final String title;

  /// "20 April 2026 - Draft".
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.listRow),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpace.md),
          // The title takes whatever the trailing value doesn't need.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppText.bodyStrong.copyWith(color: p.textPrimary)),
                if (subtitle != null) Text(subtitle!, style: AppText.label.copyWith(color: p.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpace.md),
            // Sized to its content and pinned to the right edge; capped so a
            // long chip at 1.5x text can't crowd the title out entirely.
            // (A fixed cap, not a LayoutBuilder: rows sit inside
            // IntrinsicHeight on wide layouts, which can't measure one.)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSize.listTrailingMax),
              child: trailing!,
            ),
          ],
        ],
      ),
    );
    return onPressed == null ? row : Pressable(onPressed: onPressed, child: row);
  }
}

/// Person avatar: photo when there is one, else initials on peach (§5.7).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.name, this.photoUrl, this.size = AppSize.avatar, this.ringColor});

  final String name;
  final String? photoUrl;
  final double size;

  /// Status ring for map pins (§5.14).
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final peach = context.palette.peach;
    final url = photoUrl;
    final initials = initialsOf(name);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: peach.bg,
        shape: BoxShape.circle,
        border: ringColor == null ? null : Border.all(color: ringColor!, width: 3),
        image: url == null ? null : DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: url != null
          ? null
          : ExcludeSemantics(
              child: Text(
                initials,
                // Fixed-size disc, so the label must not grow with text scale.
                textScaler: TextScaler.noScaling,
                style: AppText.caption.copyWith(color: peach.on, fontSize: size * 0.35),
              ),
            ),
    );
  }
}

/// Event avatar for arrival, departure and alert rows: accent circle with a
/// 20px icon (§5.7).
class EventAvatar extends StatelessWidget {
  const EventAvatar({super.key, required this.accent, required this.icon});

  final Accent accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.avatar,
      height: AppSize.avatar,
      decoration: BoxDecoration(color: accent.bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: AppSize.iconInline, color: accent.on),
    );
  }
}
