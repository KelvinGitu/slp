import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/pressable.dart';
import 'package:solartide/models/catalogue_item.dart';

/// A pickable catalogue option: radio mark, label and detail, price per
/// unit. Selected gets the same 1.5px `textPrimary` outline as a focused
/// input (§5.10), so the choice reads without colour.
class OptionTile extends StatelessWidget {
  const OptionTile({super.key, required this.option, required this.selected, required this.onPressed, this.trailing});

  final CatalogueOption option;
  final bool selected;
  final VoidCallback onPressed;

  /// Replaces the price, e.g. a quantity field for multi-select.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final perUnit = option.unit == 'piece' ? formatKes(option.price) : '${formatKes(option.price)} / ${option.unit}';
    return Semantics(
      selected: selected,
      button: true,
      child: Pressable(
        onPressed: onPressed,
        haptic: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSize.listRow),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? p.textPrimary : p.border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(
                selected ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
                size: AppSize.iconInline,
                color: selected ? p.textPrimary : p.textSecondary,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.label, style: AppText.bodyStrong.copyWith(color: p.textPrimary)),
                    if (option.detail != null)
                      Text(option.detail!, style: AppText.label.copyWith(color: p.textSecondary)),
                    if (trailing != null) Text(perUnit, style: AppText.label.copyWith(color: p.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.md),
              trailing ??
                  // Gives way to the label at large text sizes rather than
                  // overflowing the tile.
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: AppSize.listTrailingMax),
                      child: Text(
                        perUnit,
                        textAlign: TextAlign.end,
                        style: AppText.amount.copyWith(color: p.textPrimary),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
