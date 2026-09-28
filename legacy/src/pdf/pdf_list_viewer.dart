// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:solar_project/src/pdf/pdf_controller.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';

class PDFListViewer extends ConsumerStatefulWidget {
  final Invoice invoice;
  const PDFListViewer({super.key, 
    required this.invoice,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PDFListViewerState();
}

class _PDFListViewerState extends ConsumerState<PDFListViewer> {


 Future<Uint8List> loadPDF() async {
    return ref.watch(pdfControllerProvider).generateComponentsList(widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Components',
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