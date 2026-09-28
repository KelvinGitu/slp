import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/providers/clock_provider.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/utils/responsive.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/hero_value.dart';
import 'package:solartide/core/widgets/pastel_card.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/screen_header.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/clients/views/widgets/client_form_sheet.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/home/providers/dashboard_providers.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';
import 'package:solartide/features/quotes/views/widgets/new_quote_sheet.dart';
import 'package:solartide/features/quotes/views/widgets/quote_row.dart';

/// Home (STYLE_GUIDE §6.1 and §6.2 adapted): greeting, this month's won
/// value, the one mint action (New quote), quick actions, quote counts by
/// status and the latest quotes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _recentCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final now = ref.watch(nowProvider).valueOrNull ?? DateTime.now();
    final stats = ref.watch(dashboardStatsProvider);
    final quotes = ref.watch(quotesProvider);
    final wide = context.isWide;

    final s = stats.valueOrNull ?? const DashboardStats();
    final cards = [
      PastelStatCard(
        accent: p.neutral,
        value: '${s.count(QuoteStatus.draft)}',
        label: 'Drafts',
        icon: QuoteStatus.draft.icon,
        onPressed: () => _openQuotes(context, ref, QuoteStatus.draft),
      ),
      PastelStatCard(
        accent: p.sky,
        value: '${s.count(QuoteStatus.sent)}',
        label: 'Sent',
        icon: QuoteStatus.sent.icon,
        onPressed: () => _openQuotes(context, ref, QuoteStatus.sent),
      ),
      PastelStatCard(
        accent: p.green,
        value: '${s.count(QuoteStatus.accepted)}',
        label: 'Accepted',
        icon: QuoteStatus.accepted.icon,
        onPressed: () => _openQuotes(context, ref, QuoteStatus.accepted),
      ),
      PastelStatCard(
        accent: p.lavender,
        value: '${s.count(QuoteStatus.installed)}',
        label: 'Installed',
        icon: QuoteStatus.installed.icon,
        onPressed: () => _openQuotes(context, ref, QuoteStatus.installed),
      ),
    ];

    final recent = ContentCard(
      title: 'Recent quotes',
      onOpen: () => AppNav.openTab(context, AppTab.quotes),
      child: quotes.when(
        loading: () => const ShimmerRows(count: 3),
        error: (_, _) => const EmptyState(
          icon: PhosphorIconsRegular.wifiSlash,
          title: "Couldn't load your quotes.",
          message: 'Check your connection. They will appear when you are back online.',
        ),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: PhosphorIconsRegular.fileText,
                title: 'No quotes yet.',
                message: 'Tap New quote to price your first installation.',
              )
            : Column(
                children: [
                  for (final q in list.take(_recentCount)) ...[
                    QuoteRow(quote: q, onPressed: () => AppNav.openQuote(context, q.id)),
                    if (q != list.take(_recentCount).last) const SizedBox(height: AppSpace.lg),
                  ],
                ],
              ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.screenH, AppSpace.lg, AppSpace.screenH, AppSpace.section),
      children: [
        ScreenHeader(name: user?.firstName ?? '', now: now),
        const SizedBox(height: AppSpace.section),
        HeroValue(
          label: s.wonCountThisMonth == 1 ? 'Won this month, 1 quote' : 'Won this month, ${s.wonCountThisMonth} quotes',
          value: formatKes(s.wonThisMonth),
          note: s.openValue > 0 ? '${formatKes(s.openValue)} in drafts and sent quotes' : null,
        ),
        const SizedBox(height: AppSpace.section),
        PrimaryButton(label: 'New quote', onPressed: () => showNewQuoteSheet(context)),
        const SizedBox(height: AppSpace.md),
        PillActionRow(
          actions: [
            PillAction(
              label: 'Size a system',
              icon: PhosphorIconsRegular.lightning,
              onPressed: () => AppNav.openSizing(context),
            ),
            PillAction(
              label: 'Add client',
              icon: PhosphorIconsRegular.userPlus,
              onPressed: () => showClientFormSheet(context),
            ),
            PillAction(
              label: 'Prices',
              icon: PhosphorIconsRegular.tag,
              onPressed: () => AppNav.openCatalogue(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.section),
        if (wide)
          Row(children: [
            for (final c in cards) ...[
              Expanded(child: c),
              if (c != cards.last) const SizedBox(width: AppSpace.md),
            ],
          ])
        else
          _Grid(children: cards),
        const SizedBox(height: AppSpace.section),
        recent,
      ],
    );
  }

  static void _openQuotes(BuildContext context, WidgetRef ref, QuoteStatus status) {
    AppNav.openTab(context, AppTab.quotes);
    ref.read(quoteStatusFilterProvider.notifier).state = status;
  }
}

/// Two by two on a phone (§6.2).
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    Widget row(Widget a, Widget b) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: a), const SizedBox(width: AppSpace.md), Expanded(child: b)],
          ),
        );
    return Column(
      children: [
        row(children[0], children[1]),
        const SizedBox(height: AppSpace.md),
        row(children[2], children[3]),
      ],
    );
  }
}
