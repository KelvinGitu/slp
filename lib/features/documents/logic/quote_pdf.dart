import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/features/documents/logic/pdf_assets.dart';
import 'package:solartide/features/documents/logic/pdf_parts.dart';
import 'package:solartide/features/quotes/logic/line_summary.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/quote_model.dart';

/// The client's quote: selling prices only (markup is folded into each
/// line), then subtotal, VAT, total, how to pay, and any note.
Future<Uint8List> buildQuotePdf(QuoteModel q, BusinessProfile b, PdfAssets assets) async {
  final lines = [...q.includedLines]..sort(QuoteCalculator.compareLines);
  final selling = QuoteCalculator.sellingTotals(lines, q.totals);
  final t = q.totals;
  final doc = pw.Document(title: '${q.number} ${q.client.name}', author: b.name, theme: assets.theme);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (context) => pdfFooter(context, b),
      build: (context) => [
        pdfHeader(b, q, assets),
        pw.SizedBox(height: 24),
        pdfClientBlock(q, title: 'Quotation'),
        pw.SizedBox(height: 20),
        pdfTable(
          headers: const ['#', 'Item', 'Details', 'Amount (KES)'],
          widths: const {
            0: pw.FixedColumnWidth(22),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(4),
            3: pw.FixedColumnWidth(80),
          },
          numeric: const {3},
          rows: [
            for (var i = 0; i < lines.length; i++)
              ['${i + 1}', lines[i].name, lineSummary(lines[i]), formatAmount(selling[i])],
          ],
        ),
        pw.SizedBox(height: 12),
        _totals(q, t),
        if (q.sizing != null) ...[pw.SizedBox(height: 20), _designBasis(q)],
        if (b.hasMpesa || b.hasBank) ...[pw.SizedBox(height: 20), _payment(b, q)],
        if ((q.notes ?? '').trim().isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Text('Notes', style: PdfStyle.heading),
          pw.SizedBox(height: 4),
          pw.Text(q.notes!.trim(), style: PdfStyle.body),
        ],
        pw.SizedBox(height: 20),
        pw.Text(
          'Prices are valid until ${formatDate(q.validUntil)}.',
          style: PdfStyle.small,
        ),
      ],
    ),
  );
  return doc.save();
}

pw.Widget _totals(QuoteModel q, QuoteTotals t) {
  pw.Widget row(String label, int value, {bool strong = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.Expanded(child: pw.Text(label, style: strong ? PdfStyle.heading : PdfStyle.body)),
            pw.Text(
              formatKes(value),
              style: strong ? PdfStyle.heading.copyWith(fontSize: 13) : PdfStyle.body,
            ),
          ],
        ),
      );
  final vat = q.vatPercent == q.vatPercent.roundToDouble() ? q.vatPercent.round() : q.vatPercent;
  return pw.Row(
    children: [
      pw.Spacer(flex: 5),
      pw.Expanded(
        flex: 4,
        child: pw.Column(
          children: [
            row('Subtotal', t.subtotal),
            if (t.vat > 0) row('VAT $vat%', t.vat),
            pw.Container(height: 1, color: PdfStyle.accent, margin: const pw.EdgeInsets.symmetric(vertical: 4)),
            row('Total', t.total, strong: true),
          ],
        ),
      ),
    ],
  );
}

/// The sizing the quote was built from, so the client sees why these sizes.
pw.Widget _designBasis(QuoteModel q) {
  final s = q.sizing!;
  final facts = [
    'Daily use ${formatEnergy(s.dailyWh)}',
    '${s.peakSunHours.toStringAsFixed(1)} peak sun hours${s.locationLabel == null ? '' : ' (${s.locationLabel})'}',
    'Array ${formatPower(s.arrayWatts)} (${s.panelCount} × ${s.panelWatts} W)',
    if (s.batteryWh > 0) 'Storage ${formatEnergy(s.batteryWh)} for ${s.autonomyDays} day${s.autonomyDays == 1 ? '' : 's'}',
  ];
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: const pw.BoxDecoration(color: PdfStyle.band),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Design basis', style: PdfStyle.heading),
        pw.SizedBox(height: 4),
        pw.Text(facts.join('  -  '), style: PdfStyle.body),
      ],
    ),
  );
}

pw.Widget _payment(BusinessProfile b, QuoteModel q) {
  final rows = <String>[
    if (b.mpesaPaybill?.isNotEmpty ?? false)
      'M-Pesa paybill ${b.mpesaPaybill}, account ${b.mpesaAccount?.isNotEmpty ?? false ? b.mpesaAccount : q.number}',
    if (b.mpesaTill?.isNotEmpty ?? false) 'M-Pesa till ${b.mpesaTill}',
    if (b.hasBank)
      [b.bankName, b.bankBranch, b.bankAccountName, 'A/C ${b.bankAccountNumber}']
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(', '),
  ];
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('How to pay', style: PdfStyle.heading),
      pw.SizedBox(height: 4),
      for (final r in rows) pw.Text(r, style: PdfStyle.body),
      pw.Text('Quote ${q.number} as the reference.', style: PdfStyle.small),
    ],
  );
}
