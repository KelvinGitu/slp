import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/tab_page.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';
import 'package:solartide/features/quotes/views/widgets/new_quote_sheet.dart';
import 'package:solartide/features/quotes/views/widgets/quote_row.dart';
import 'package:solartide/features/quotes/views/widgets/search_field.dart';

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(filteredQuotesProvider);
    final filter = ref.watch(quoteStatusFilterProvider);
    final filtered = filter != null || ref.watch(quoteSearchProvider).isNotEmpty;

    void setFilter(QuoteStatus? s) => ref.read(quoteStatusFilterProvider.notifier).state = s;

    return TabPage(
      title: 'Quotes',
      trailing: PillButton(label: 'New', icon: PhosphorIconsRegular.plus, onPressed: () => showNewQuoteSheet(context)),
      children: [
        SearchField(
          hint: 'Search by client or quote number',
          onChanged: (v) => ref.read(quoteSearchProvider.notifier).state = v,
        ),
        const SizedBox(height: AppSpace.lg),
        // Filters as pills (§6.4): selected fills with textPrimary.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PillButton(label: 'All', selected: filter == null, onPressed: () => setFilter(null)),
              for (final s in QuoteStatus.values) ...[
                const SizedBox(width: AppSpace.sm),
                PillButton(label: s.label, selected: filter == s, onPressed: () => setFilter(s)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        ContentCard(
          child: quotes.when(
            loading: () => const ShimmerRows(count: 4),
            error: (_, _) => const EmptyState(
              icon: PhosphorIconsRegular.wifiSlash,
              title: "Couldn't load your quotes.",
              message: 'Check your connection and try again.',
            ),
            data: (list) {
              if (list.isEmpty) {
                return filtered
                    ? const EmptyState(
                        icon: PhosphorIconsRegular.magnifyingGlass,
                        title: 'No matching quotes.',
                        message: 'Try another status or search.',
                      )
                    : EmptyState(
                        icon: PhosphorIconsRegular.fileText,
                        title: 'No quotes yet.',
                        message: 'Start one for a client and it will show here.',
                        action: PillButton(
                          label: 'New quote',
                          icon: PhosphorIconsRegular.plus,
                          onPressed: () => showNewQuoteSheet(context),
                        ),
                      );
              }
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpace.lg),
                    QuoteRow(quote: list[i], onPressed: () => AppNav.openQuote(context, list[i].id)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
