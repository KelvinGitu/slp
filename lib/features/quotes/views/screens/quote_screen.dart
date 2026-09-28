import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/detail_panel.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/hero_value.dart';
import 'package:solartide/core/widgets/inline_banner.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/status_chip.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/documents/logic/share_quote.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/controller/quote_controller.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';
import 'package:solartide/features/quotes/views/widgets/line_row.dart';
import 'package:solartide/features/quotes/views/widgets/quote_settings_sheet.dart';
import 'package:solartide/features/quotes/views/widgets/quote_totals_card.dart';
import 'package:solartide/models/quote_model.dart';

/// One quote: its total and status, the components grouped by category
/// (replacing the old 46-page walk-through), totals, and the one mint
/// action to finish it.
class QuoteScreen extends ConsumerWidget {
  const QuoteScreen({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider(quoteId));
    return quote.when(
      loading: () => const SubPage(title: 'Quote', children: [ShimmerRows(count: 5)]),
      error: (_, _) => const SubPage(
        title: 'Quote',
        children: [
          EmptyState(
            icon: PhosphorIconsRegular.wifiSlash,
            title: "Couldn't load this quote.",
            message: 'Check your connection and try again.',
          ),
        ],
      ),
      data: (q) => q == null || q.deleted
          ? const SubPage(
              title: 'Quote',
              children: [
                EmptyState(
                  icon: PhosphorIconsRegular.fileX,
                  title: 'This quote was deleted.',
                  message: 'Deleted quotes no longer show in your lists.',
                ),
              ],
            )
          : _QuoteView(quote: q),
    );
  }
}

class _QuoteView extends ConsumerWidget {
  const _QuoteView({required this.quote});

  final QuoteModel quote;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final status = await showOptionSheet<QuoteStatus>(
      context,
      title: 'Status',
      selected: quote.status,
      options: [for (final s in QuoteStatus.values) SheetOption(value: s, title: s.label, icon: s.icon)],
    );
    if (status != null && context.mounted) {
      await ref.read(quoteControllerProvider.notifier).setStatus(quote, status, context);
    }
  }

  /// Draft: confirm any "To do" lines are meant to be left off, mark it
  /// sent, then show the PDF.
  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final pending = quote.pendingCount;
    if (pending > 0) {
      final ok = await showConfirmSheet(
        context,
        title: '$pending ${pending == 1 ? 'component is' : 'components are'} still to do',
        message: "They won't appear on the quote. You can come back and add them later.",
        confirmLabel: 'Finish anyway',
        cancelLabel: 'Keep editing',
      );
      if (!ok || !context.mounted) return;
    }
    await ref.read(quoteControllerProvider.notifier).setStatus(quote, QuoteStatus.sent, context);
    if (context.mounted) AppNav.openDocument(context, quote.id);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmSheet(
      context,
      title: 'Delete ${quote.number}?',
      message: 'You can undo this straight after.',
      confirmLabel: 'Delete quote',
    );
    if (!ok || !context.mounted) return;
    final deleted = await ref.read(quoteControllerProvider.notifier).delete(quote, context);
    if (deleted && context.mounted) await closeSubPage(context);
  }

  Future<void> _duplicate(BuildContext context, WidgetRef ref) async {
    final id = await ref.read(quoteControllerProvider.notifier).duplicate(quote, context);
    if (id != null && context.mounted) AppNav.openQuote(context, id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final pending = quote.pendingCount;
    final groups = groupBy([...quote.lines]..sort(QuoteCalculator.compareLines), (QuoteLine l) => l.category);

    return SubPage(
      title: quote.number,
      actions: [
        IconButton(
          tooltip: 'Duplicate quote',
          icon: Icon(PhosphorIconsRegular.copy, size: AppSize.iconInline, color: p.textPrimary),
          onPressed: () => _duplicate(context, ref),
        ),
        IconButton(
          tooltip: 'Delete quote',
          icon: Icon(PhosphorIconsRegular.trash, size: AppSize.iconInline, color: p.textPrimary),
          onPressed: () => _delete(context, ref),
        ),
      ],
      bottom: quote.status == QuoteStatus.draft
          ? PrimaryButton(label: 'Finish quote', onPressed: () => _finish(context, ref))
          : PrimaryButton(label: 'View quote', onPressed: () => AppNav.openDocument(context, quote.id)),
      children: [
        HeroValue(
          label: [quote.client.name, quote.client.location].whereType<String>().join(', '),
          value: formatKes(quote.totals.total),
          chip: StatusStyleChip(quote.status),
          note: 'Valid until ${formatDate(quote.validUntil)}',
        ),
        const SizedBox(height: AppSpace.section),
        PillActionRow(
          actions: [
            PillAction(label: 'Status', icon: PhosphorIconsRegular.flag, onPressed: () => _changeStatus(context, ref)),
            PillAction(
              label: 'Parts list',
              icon: PhosphorIconsRegular.listBullets,
              onPressed: () => AppNav.openDocument(context, quote.id, list: true),
            ),
            PillAction(label: 'Share', icon: PhosphorIconsRegular.shareNetwork, onPressed: () => shareQuote(context, ref, quote)),
          ],
        ),
        if (pending > 0) ...[
          const SizedBox(height: AppSpace.section),
          InlineBanner(
            accent: p.amber,
            icon: PhosphorIconsRegular.listChecks,
            message: pending == quote.lines.length
                ? 'Go through each component. Tap one to add it or mark it not required.'
                : '$pending of ${quote.lines.length} components still to do.',
          ),
        ],
        for (final entry in groups.entries) ...[
          const SizedBox(height: AppSpace.section),
          ContentCard(
            title: entry.key,
            child: Column(
              children: [
                for (var i = 0; i < entry.value.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpace.lg),
                  LineRow(
                    line: entry.value[i],
                    onPressed: () => AppNav.openLine(context, quote.id, entry.value[i].itemId),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        QuoteTotalsCard(quote: quote, onEditRates: () => showQuoteSettingsSheet(context, quote)),
        const SizedBox(height: AppSpace.section),
      ],
    );
  }
}
