import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/features/documents/logic/pdf_assets.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/quote_model.dart';

/// Pieces shared by the quote and the components list.
///
/// PDFs are always light, whatever the app theme: they get printed.
abstract final class PdfStyle {
  static const ink = PdfColor.fromInt(0xFF1C2024);
  static const muted = PdfColor.fromInt(0xFF6C6C6C);
  static const rule = PdfColor.fromInt(0xFFE4E4E6);
  static const band = PdfColor.fromInt(0xFFF9F9F9);

  /// The app's mint, for the one accent on the page.
  static const accent = PdfColor.fromInt(0xFF36E3C5);

  static final title = pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: ink);
  static final heading = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: ink);
  static const body = pw.TextStyle(fontSize: 10, color: ink);
  static const small = pw.TextStyle(fontSize: 8.5, color: muted);
}

/// Business name, contacts and logo on the left; a QR code with the quote
/// number and phone on the right, as the original PDF had.
pw.Widget pdfHeader(BusinessProfile b, QuoteModel q, PdfAssets assets) {
  final contacts = [b.phone, b.email, b.address].whereType<String>().where((s) => s.isNotEmpty);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (assets.logo != null) ...[
        pw.SizedBox(width: 56, height: 56, child: pw.Image(assets.logo!, fit: pw.BoxFit.contain)),
        pw.SizedBox(width: 12),
      ],
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(b.name, style: PdfStyle.heading.copyWith(fontSize: 14)),
            for (final c in contacts) pw.Text(c, style: PdfStyle.small),
            if (b.kraPin != null && b.kraPin!.isNotEmpty) pw.Text('KRA PIN ${b.kraPin}', style: PdfStyle.small),
          ],
        ),
      ),
      pw.SizedBox(
        width: 56,
        height: 56,
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: [q.number, b.name, b.phone].whereType<String>().join('\n'),
          drawText: false,
        ),
      ),
    ],
  );
}

/// "Prepared for" on the left, number and dates on the right.
pw.Widget pdfClientBlock(QuoteModel q, {required String title}) {
  final c = q.client;
  pw.Widget info(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.SizedBox(width: 70, child: pw.Text(label, style: PdfStyle.small)),
            pw.Text(value, style: PdfStyle.body),
          ],
        ),
      );
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: PdfStyle.title),
      pw.SizedBox(height: 12),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Prepared for', style: PdfStyle.small),
                pw.Text(c.name, style: PdfStyle.heading),
                for (final line in [c.location, c.phone, c.email].whereType<String>()) pw.Text(line, style: PdfStyle.body),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              info('Quote no.', q.number),
              info('Date', formatDate(q.createdAt)),
              info('Valid until', formatDate(q.validUntil)),
            ],
          ),
        ],
      ),
    ],
  );
}

/// "Page 1 of 2" with the business name, on every page.
pw.Widget pdfFooter(pw.Context context, BusinessProfile b) => pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfStyle.rule))),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(b.name, style: PdfStyle.small)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: PdfStyle.small),
        ],
      ),
    );

/// A plain table: bold header on a light band, hairlines between rows, no
/// vertical lines (as §6.4 asks of tables in the app).
pw.Widget pdfTable({
  required List<String> headers,
  required List<List<String>> rows,
  required Map<int, pw.TableColumnWidth> widths,
  Set<int> numeric = const {},
}) {
  pw.Widget cell(String text, int col, {bool header = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Text(
          text,
          textAlign: numeric.contains(col) ? pw.TextAlign.right : pw.TextAlign.left,
          style: header ? PdfStyle.heading.copyWith(fontSize: 9) : PdfStyle.body,
        ),
      );
  return pw.Table(
    columnWidths: widths,
    border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfStyle.rule, width: 0.5)),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfStyle.band),
        children: [for (var i = 0; i < headers.length; i++) cell(headers[i], i, header: true)],
      ),
      for (final r in rows) pw.TableRow(children: [for (var i = 0; i < r.length; i++) cell(r[i], i)]),
    ],
  );
}
