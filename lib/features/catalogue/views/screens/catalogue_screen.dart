import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/catalogue/controller/catalogue_controller.dart';
import 'package:solartide/features/catalogue/providers/catalogue_providers.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/views/widgets/search_field.dart';
import 'package:solartide/models/catalogue_item.dart';

/// Settings > Price catalogue. Every component and its price, grouped the way
/// quotes list them.
class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  String _query = '';

  Future<void> _reset() async {
    final ok = await showConfirmSheet(
      context,
      title: 'Reset all prices?',
      message: 'Every component goes back to its starting price and options. Quotes already made keep their prices.',
      confirmLabel: 'Reset prices',
    );
    if (ok && mounted) await ref.read(catalogueControllerProvider.notifier).resetToDefaults(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final catalogue = ref.watch(catalogueProvider);
    final q = _query.trim().toLowerCase();

    return SubPage(
      title: 'Price catalogue',
      actions: [
        IconButton(
          tooltip: 'Reset prices',
          icon: Icon(PhosphorIconsRegular.arrowCounterClockwise, size: AppSize.iconInline, color: p.textPrimary),
          onPressed: _reset,
        ),
      ],
      children: [
        SearchField(hint: 'Search components', onChanged: (v) => setState(() => _query = v)),
        ...catalogue.when(
          loading: () => [const SizedBox(height: AppSpace.section), const ShimmerRows(count: 6)],
          error: (_, _) => [
            const EmptyState(
              icon: PhosphorIconsRegular.wifiSlash,
              title: "Couldn't load your prices.",
              message: 'Check your connection and try again.',
            ),
          ],
          data: (items) {
            final shown = q.isEmpty ? items : items.where((i) => i.name.toLowerCase().contains(q)).toList();
            if (shown.isEmpty) {
              return [
                const SizedBox(height: AppSpace.section),
                const EmptyState(
                  icon: PhosphorIconsRegular.magnifyingGlass,
                  title: 'No matching components.',
                  message: 'Try part of the name.',
                ),
              ];
            }
            return [
              for (final entry in groupBy(shown, (CatalogueItem i) => i.category).entries) ...[
                const SizedBox(height: AppSpace.section),
                ContentCard(
                  title: entry.key,
                  child: Column(
                    children: [
                      for (var i = 0; i < entry.value.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpace.lg),
                        _ItemRow(item: entry.value[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ];
          },
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final CatalogueItem item;

  /// "KES 10,000 per panel", "5 options, KES 60,000 to 145,000".
  static String priceText(CatalogueItem i) {
    if (i.kind == ComponentKind.custom) return 'Amount typed on each quote';
    if (i.options.isEmpty) {
      return i.kind == ComponentKind.fixed ? formatKes(i.unitPrice) : '${formatKes(i.unitPrice)} per ${i.unit}';
    }
    final prices = i.options.map((o) => o.price);
    final lo = prices.reduce((a, b) => a < b ? a : b), hi = prices.reduce((a, b) => a > b ? a : b);
    final range = lo == hi ? formatKes(lo) : '${formatKes(lo)} to ${formatAmount(hi)}';
    return '${i.options.length} options, $range';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListRow(
      leading: EventAvatar(
        accent: item.active ? p.lavender : p.neutral,
        icon: item.active ? PhosphorIconsRegular.tag : PhosphorIconsRegular.eyeSlash,
      ),
      title: item.name,
      subtitle: item.active ? priceText(item) : 'Hidden from new quotes - ${priceText(item)}',
      onPressed: () => AppNav.openCatalogueItem(context, item.id),
    );
  }
}
