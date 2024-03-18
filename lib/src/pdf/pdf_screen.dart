// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'package:solar_project/src/pdf/pdf_controller.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';

class PDFScreen extends ConsumerStatefulWidget {
  final Invoice invoice;
  const PDFScreen({super.key, 
    required this.invoice,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PDFScreenState();
}

class _PDFScreenState extends ConsumerState<PDFScreen> {
  // PDFDocument? _pdfDocument;

  // Future<PDFDocument?> openFile() async {
  //   final pdfFile =
  //       await ref.watch(pdfControllerProvider).generate(widget.invoice);
  //   _pdfDocument = await ref.watch(pdfControllerProvider).openFile(pdfFile);
  //   return _pdfDocument;
  // }

  Future<Uint8List> loadPDF() async {
    return ref.watch(pdfControllerProvider).generate(widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
        build: (context) {
          return loadPDF();
        },
      ),
    );
  }
}
