import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:printing/printing.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/features/documents/logic/components_list_pdf.dart';
import 'package:solartide/features/documents/logic/pdf_assets.dart';
import 'package:solartide/features/documents/logic/quote_pdf.dart';
import 'package:solartide/features/documents/logic/share_quote.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';

/// The quote PDF (or the components list) with print and share. The same
/// page on phone and browser; `PdfPreview` handles both.
class DocumentPreviewScreen extends ConsumerWidget {
  const DocumentPreviewScreen({super.key, required this.quoteId, this.componentsList = false});

  final String quoteId;
  final bool componentsList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final quote = ref.watch(quoteProvider(quoteId)).valueOrNull;
    final business = ref.watch(businessProfileProvider).valueOrNull;
    final title = componentsList ? 'Components list' : 'Quote';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(PhosphorIconsRegular.arrowLeft, color: p.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(quote == null ? title : '$title ${quote.number}', style: AppText.title1.copyWith(color: p.textPrimary)),
        actions: [
          if (quote != null && !componentsList)
            IconButton(
              tooltip: 'Share',
              icon: Icon(PhosphorIconsRegular.shareNetwork, size: AppSize.iconInline, color: p.textPrimary),
              onPressed: () => shareQuote(context, ref, quote),
            ),
        ],
      ),
      body: quote == null || business == null
          ? const Padding(padding: EdgeInsets.all(AppSpace.screenH), child: ShimmerRows(count: 5))
          : PdfPreview(
              // Rebuilt whenever the quote changes, e.g. a price updated on
              // another device.
              key: ValueKey('${quote.updatedAt.millisecondsSinceEpoch}-$componentsList'),
              pdfFileName: quoteFileName(quote, componentsList: componentsList),
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              allowSharing: true,
              allowPrinting: true,
              scrollViewDecoration: BoxDecoration(color: p.scaffold),
              pdfPreviewPageDecoration: BoxDecoration(color: Colors.white, border: Border.all(color: p.border)),
              loadingWidget: const Padding(padding: EdgeInsets.all(AppSpace.screenH), child: ShimmerRows(count: 5)),
              onError: (context, _) => const EmptyState(
                icon: PhosphorIconsRegular.filePdf,
                title: "Couldn't create the PDF.",
                message: 'Go back and try again.',
              ),
              build: (_) async {
                final assets = await PdfAssets.load(logoUrl: business.logoUrl);
                return componentsList
                    ? buildComponentsListPdf(quote, business, assets)
                    : buildQuotePdf(quote, business, assets);
              },
            ),
    );
  }
}
