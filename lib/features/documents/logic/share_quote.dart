import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:printing/printing.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/utils/launch.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/features/documents/logic/pdf_assets.dart';
import 'package:solartide/features/documents/logic/quote_pdf.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/quote_model.dart';

enum _ShareVia { pdf, whatsApp, email }

/// Share a quote: the PDF through the phone's share sheet (a download in the
/// browser), or a short WhatsApp or email message to the client.
Future<void> shareQuote(BuildContext context, WidgetRef ref, QuoteModel quote) async {
  final via = await showOptionSheet<_ShareVia>(
    context,
    title: 'Share ${quote.number}',
    options: [
      const SheetOption(
        value: _ShareVia.pdf,
        title: 'Send the PDF',
        subtitle: 'WhatsApp, email or any app on this device.',
        icon: PhosphorIconsRegular.filePdf,
      ),
      SheetOption(
        value: _ShareVia.whatsApp,
        title: 'WhatsApp message',
        subtitle: quote.client.phone == null ? 'Pick the chat in WhatsApp.' : 'To ${quote.client.phone}.',
        icon: PhosphorIconsRegular.whatsappLogo,
      ),
      SheetOption(
        value: _ShareVia.email,
        title: 'Email',
        subtitle: quote.client.email ?? 'Add the address in your email app.',
        icon: PhosphorIconsRegular.envelopeSimple,
      ),
    ],
  );
  if (via == null || !context.mounted) return;

  final business = ref.read(businessProfileProvider).valueOrNull ?? const BusinessProfile(name: '');
  switch (via) {
    case _ShareVia.pdf:
      await sharePdf(context, quote, business);
    case _ShareVia.whatsApp:
      await openWhatsApp(context, quote.client.phone, text: quoteMessage(quote, business));
    case _ShareVia.email:
      await sendEmail(
        context,
        quote.client.email,
        subject: 'Solar installation quote ${quote.number}',
        body: quoteMessage(quote, business),
      );
  }
}

Future<void> sharePdf(BuildContext context, QuoteModel quote, BusinessProfile business) async {
  try {
    final assets = await PdfAssets.load(logoUrl: business.logoUrl);
    final bytes = await buildQuotePdf(quote, business, assets);
    await Printing.sharePdf(bytes: bytes, filename: quoteFileName(quote));
  } catch (_) {
    if (context.mounted) showSnackBar(context, "Couldn't create the PDF. Try again.");
  }
}

/// "ST-2026-0007 Kamau.pdf".
String quoteFileName(QuoteModel q, {bool componentsList = false}) {
  final client = q.client.name.split(RegExp(r'\s+')).first.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  return '${q.number}${componentsList ? ' components' : ''}${client.isEmpty ? '' : ' $client'}.pdf';
}

/// Short, calm and in the second person (STYLE_GUIDE §10).
String quoteMessage(QuoteModel q, BusinessProfile b) {
  final first = q.client.name.split(RegExp(r'\s+')).first;
  return [
    'Hello $first,',
    '',
    'Here is your solar installation quote ${q.number}.',
    'Total: ${formatKes(q.totals.total)}${q.totals.vat > 0 ? ' including VAT' : ''}.',
    'Valid until ${formatDate(q.validUntil)}.',
    '',
    'Reply here with any questions.',
    if (b.name.isNotEmpty) b.name,
    if (b.phone?.isNotEmpty ?? false) b.phone!,
  ].join('\n');
}
