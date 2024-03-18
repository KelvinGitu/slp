import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'package:solar_project/src/pdf/pdf_controller.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';

class PDFViewer extends ConsumerStatefulWidget {
  final Invoice invoice;
  const PDFViewer({
    super.key,
    required this.invoice,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PDFScreenState();
}

class _PDFScreenState extends ConsumerState<PDFViewer> {
  Future<Uint8List> loadPDF() async {
    return ref.watch(pdfControllerProvider).generate(widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (context) {
          return loadPDF();
        },
      ),
    );
  }
}
