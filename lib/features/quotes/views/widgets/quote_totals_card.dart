import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/models/quote_model.dart';

/// Cost, markup, VAT and total. Markup is shown here for the installer; the
/// client's PDF folds it into the line prices.
class QuoteTotalsCard extends StatelessWidget {
  const QuoteTotalsCard({super.key, required this.quote, this.onEditRates});

  final QuoteModel quote;
  final VoidCallback? onEditRates;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = quote.totals;

    Widget row(String label, int amount, {bool strong = false}) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: (strong ? AppText.bodyStrong : AppText.label)
                      .copyWith(color: strong ? p.textPrimary : p.textSecondary),
                ),
              ),
              Text(
                formatKes(amount),
                style: (strong ? AppText.title2 : AppText.amount).copyWith(color: p.textPrimary),
              ),
            ],
          ),
        );

    return ContentCard(
      title: 'Totals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row('Components at cost', t.cost),
          row('Markup ${_pct(quote.markupPercent)}', t.markup),
          row('VAT ${_pct(quote.vatPercent)}', t.vat),
          Divider(color: p.border, height: AppSpace.lg),
          row('Total', t.total, strong: true),
          if (onEditRates != null)
            Align(
              alignment: Alignment.centerLeft,
              child: PillButton(
                label: 'Markup and VAT',
                icon: PhosphorIconsRegular.percent,
                outlined: true,
                onPressed: onEditRates,
              ),
            ),
        ],
      ),
    );
  }

  static String _pct(double v) => '${v == v.roundToDouble() ? v.round() : v}%';
}
