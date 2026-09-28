import 'package:flutter/material.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/features/quotes/logic/line_summary.dart';
import 'package:solartide/models/quote_model.dart';

/// One component on a quote: state avatar, name, "Added - 12 panels ×
/// KES 10,000", and the line cost when it's added.
class LineRow extends StatelessWidget {
  const LineRow({super.key, required this.line, this.onPressed});

  final QuoteLine line;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final state = line.state;
    return ListRow(
      leading: EventAvatar(accent: state.accent(p), icon: state.icon),
      title: line.name,
      subtitle: state == LineState.included ? '${state.label} - ${lineSummary(line)}' : state.label,
      trailing: state == LineState.included
          ? Text(
              formatAmount(line.total),
              maxLines: 1,
              style: AppText.amount.copyWith(color: p.textPrimary),
            )
          : null,
      onPressed: onPressed,
    );
  }
}
