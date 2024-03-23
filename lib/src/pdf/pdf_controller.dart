import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';
import 'package:solar_project/src/pdf/utils.dart';
import 'package:pdf/widgets.dart' as pw;

final pdfControllerProvider = Provider((ref) => PDFController());

class PDFController {
  Future<Uint8List> generateInvoice(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    return pdf.save();
  }

  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier),
              Container(
                height: 50,
                width: 50,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: invoice.info.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(customer.address),
        ],
      );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      info.number,
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(invoice.info.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice) {
    final headers = [
      'Component',
      // 'Units',
      // 'Unit Price',
      'Total Cost (KES)',
    ];
    final data = invoice.items.map((item) {
      return [
        item.description,
        // '${item.units}',
        // '\$ ${item.unitPrice}',
        '${item.cost}',
      ];
    }).toList();

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Total amount:',
                  value: Utils.formatPrice(invoice.quotation),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Address', value: invoice.supplier.address),
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    bool unite = false,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  Future<Uint8List> generateComponentsList(Invoice invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        Padding(
          padding: const EdgeInsets.only(left: 150),
          child: Text('Components List', style: const TextStyle(fontSize: 24))),
        showComponents(invoice),
        componentsList(invoice),
      ],
      footer: (context) => buildSecondFooter(invoice),
    ));

    return pdf.save();
  }

    static Widget buildSecondFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Client', value: invoice.customer.name),
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  Widget showComponents(Invoice invoice) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Component',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 340),
            Text(
              'Cost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
          ],
        ),
      ],
    );
  }



  Widget componentsList(Invoice invoice) {
    final List<InvoiceItem> components = invoice.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(components.length, (index) {
        final component = components[index].description;
        final value = components[index].cost;
        final specificItems = components[index].specificItems;

        return SizedBox(
            height: (specificItems.length >= 5)
                ? 120
                : (specificItems.length >= 3)
                    ? 80
                    : (specificItems.length >= 2)
                        ? 60
                        : (specificItems.length == 1)
                            ? 50
                            : 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(component,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        )),
                    Text(value.toString()),
                  ],
                ),
                SizedBox(height: 5),
                (specificItems.isNotEmpty)
                    ? subComponentList(invoice, index)
                    : Container(),
              ],
            ));
      }),
    );
  }

  Widget subComponentList(Invoice invoice, int index) {
    final List<SpecificInvoiceItem> specificItems =
        invoice.items[index].specificItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        specificItems.length,
        (index) {
          final component = specificItems[index].description;
          final value = specificItems[index].units;

          return Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Text('$component ($value)'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget paddedText(
    final String text, {
    final TextAlign align = TextAlign.left,
  }) =>
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          textAlign: align,
        ),
      );
}
