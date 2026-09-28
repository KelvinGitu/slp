import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

class AppTableColumn {
  const AppTableColumn(this.label, {this.numeric = false});

  final String label;
  final bool numeric;
}

class AppTableRow {
  const AppTableRow({required this.cells, this.onTap, this.selected = false});

  final List<Widget> cells;
  final VoidCallback? onTap;

  /// The row whose detail is open beside the table.
  final bool selected;
}

/// A table inside a content card (STYLE_GUIDE §6.4): `label` headers, `body`
/// cells, 56px rows that grow with the text scale, no vertical lines. Scrolls
/// sideways rather than squeezing its columns.
class AppDataTable extends StatelessWidget {
  const AppDataTable({super.key, required this.columns, required this.rows});

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: c.maxWidth),
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: AppSpace.xl,
            horizontalMargin: 0,
            headingRowHeight: AppSize.tableRow,
            dataRowMinHeight: AppSize.tableRow,
            dataRowMaxHeight: double.infinity,
            dividerThickness: 1,
            headingTextStyle: AppText.label.copyWith(color: p.textSecondary),
            dataTextStyle: AppText.body.copyWith(color: p.textPrimary, fontFeatures: AppText.amount.fontFeatures),
            columns: [for (final col in columns) DataColumn(label: Text(col.label), numeric: col.numeric)],
            rows: [
              for (final row in rows)
                DataRow(
                  selected: row.selected,
                  color: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected) ? p.surface : null,
                  ),
                  onSelectChanged: row.onTap == null ? null : (_) => row.onTap!(),
                  cells: [for (final cell in row.cells) DataCell(cell)],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
