import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/features/documents/logic/pdf_assets.dart';
import 'package:solartide/features/documents/logic/pdf_parts.dart';
import 'package:solartide/features/quotes/logic/line_summary.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/quote_model.dart';

/// The parts list for the installation team, grouped by category, with every
/// chosen option on its own line and prices at cost. For the store and the
/// crew; the client gets the quote.
Future<Uint8List> buildComponentsListPdf(QuoteModel q, BusinessProfile b, PdfAssets assets) async {
  final lines = [...q.includedLines]..sort(QuoteCalculator.compareLines);
  final groups = groupBy(lines, (QuoteLine l) => l.category);
  final doc = pw.Document(title: '${q.number} components', author: b.name, theme: assets.theme);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (context) => pdfFooter(context, b),
      build: (context) => [
        pdfHeader(b, q, assets),
        pw.SizedBox(height: 24),
        pdfClientBlock(q, title: 'Components list'),
        for (final entry in groups.entries) ...[
          pw.SizedBox(height: 16),
          pw.Text(entry.key, style: PdfStyle.heading),
          pw.SizedBox(height: 6),
          pdfTable(
            headers: const ['Component', 'What to take', 'Cost (KES)'],
            widths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(5), 2: pw.FixedColumnWidth(72)},
            numeric: const {2},
            rows: [
              for (final l in entry.value)
                [
                  l.name,
                  l.selections.length > 1 ? selectionDetails(l).join('\n') : lineSummary(l),
                  formatAmount(l.total),
                ],
            ],
          ),
        ],
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                '${lines.length} components. Not required: ${q.lines.length - lines.length - q.pendingCount}. '
                'Still to do: ${q.pendingCount}.',
                style: PdfStyle.small,
              ),
            ),
            pw.Text('Total at cost ${formatKes(q.totals.cost)}', style: PdfStyle.heading),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}
