import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/models/quote_model.dart';

/// A quote in a list (§5.7): status avatar, client, "Draft - ST-2026-0007 -
/// 20 Sep 2026", total on the right. The status word sits in the subtitle so
/// it's never shown by colour alone.
class QuoteRow extends StatelessWidget {
  const QuoteRow({super.key, required this.quote, this.onPressed, this.showClient = true});

  final QuoteModel quote;
  final VoidCallback? onPressed;

  /// Off on a client's own page, where the name would repeat.
  final bool showClient;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final status = quote.status;
    return ListRow(
      leading: EventAvatar(accent: status.accent(p), icon: status.icon),
      title: showClient ? quote.client.name : quote.number,
      subtitle: [
        status.label,
        if (showClient) quote.number,
        formatShortDate(quote.createdAt),
      ].join(' - '),
      trailing: Text(
        formatKes(quote.totals.total),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.amount.copyWith(color: p.textPrimary),
      ),
      onPressed: onPressed,
    );
  }
}
