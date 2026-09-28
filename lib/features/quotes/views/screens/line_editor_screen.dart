import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/catalogue/providers/catalogue_providers.dart';
import 'package:solartide/features/quotes/controller/quote_controller.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';
import 'package:solartide/features/quotes/views/widgets/line_editor.dart';
import 'package:solartide/models/quote_model.dart';

/// Edits one component of a quote. One screen for all 46 components: the
/// catalogue item's kind decides which fields show.
class LineEditorScreen extends ConsumerWidget {
  const LineEditorScreen({super.key, required this.quoteId, required this.itemId});

  final String quoteId;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider(quoteId)).valueOrNull;
    final catalogueLoaded = ref.watch(catalogueProvider).hasValue;
    final item = ref.watch(catalogueByIdProvider)[itemId];
    final line = quote?.lineFor(itemId);

    if (quote == null || !catalogueLoaded) {
      return const SubPage(title: 'Component', children: [ShimmerRows(count: 3)]);
    }
    if (line == null) {
      return const SubPage(
        title: 'Component',
        children: [
          EmptyState(
            icon: PhosphorIconsRegular.question,
            title: 'This component is not on the quote.',
            message: 'Go back to the quote and pick another.',
          ),
        ],
      );
    }
    if (item == null) return _RemovedItem(quote: quote, line: line);
    // Keyed so switching quotes or items starts with fresh fields.
    return LineEditor(key: ValueKey('$quoteId/$itemId'), quote: quote, item: item, line: line);
  }
}

/// The line's item is no longer in the catalogue. Its frozen price still
/// counts; all that can be done is keep it or take it off.
class _RemovedItem extends ConsumerWidget {
  const _RemovedItem({required this.quote, required this.line});

  final QuoteModel quote;
  final QuoteLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return SubPage(
      title: line.name,
      children: [
        const EmptyState(
          icon: PhosphorIconsRegular.tag,
          title: 'This component was removed from your price catalogue.',
          message: 'It stays on this quote at the price it had. You can take it off.',
        ),
        const SizedBox(height: AppSpace.section),
        if (line.state != LineState.notRequired)
          Center(
            child: PillButton(
              label: 'Mark not required',
              icon: PhosphorIconsRegular.minusCircle,
              accent: p.neutral,
              onPressed: () async {
                final ok = await ref
                    .read(quoteControllerProvider.notifier)
                    .saveLine(quote, QuoteCalculator.notRequired(line), context);
                if (ok && context.mounted) await Navigator.of(context).maybePop();
              },
            ),
          ),
      ],
    );
  }
}
