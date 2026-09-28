import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:solartide/core/utils/log.dart';

/// Fonts and the logo for the PDFs, loaded once per document.
///
/// The PDF's built-in Helvetica has no "²" or "×", which cable sizes and
/// line summaries use, so the app's own GoogleSans is embedded instead.
class PdfAssets {
  const PdfAssets({required this.theme, this.logo});

  final pw.ThemeData theme;
  final pw.MemoryImage? logo;

  static Future<PdfAssets> load({String? logoUrl}) async {
    Future<pw.Font> font(String weight) async =>
        pw.Font.ttf(await rootBundle.load('assets/fonts/GoogleSans/GoogleSans-$weight.ttf'));

    final theme = pw.ThemeData.withFont(base: await font('Regular'), bold: await font('Bold'));
    return PdfAssets(theme: theme, logo: await _logo(logoUrl));
  }

  /// A logo that fails to load (offline, or Storage CORS not set up for the
  /// web app) leaves the header without it rather than failing the PDF.
  static Future<pw.MemoryImage?> _logo(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return pw.MemoryImage(res.bodyBytes);
    } catch (e, st) {
      logError('PdfAssets.logo', e, st);
      return null;
    }
  }
}
