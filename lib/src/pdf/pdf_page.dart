import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/adapter_box_model.dart';
import 'package:solar_project/src/controller/adapter_boxes_controller.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';
import 'package:solar_project/src/pdf/pdf_screen.dart';

class PDFPage extends ConsumerStatefulWidget {
  final String applicationId;
  const PDFPage({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PDFPageState();
}

class _PDFPageState extends ConsumerState<PDFPage> {
  late List<String> adapterBoxesArguments;

  @override
  void initState() {
    adapterBoxesArguments = [widget.applicationId, 'Adapter Box Enclosure'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final application =
        ref.watch(getApplicationStreamProvider(widget.applicationId));
    final applicationComponents = ref.watch(
        getFutureSelectedApplicationComponentsFutureProvider(
            widget.applicationId));
    final selectedAdapterBoxes =
        ref.watch(getFutureSelectedBoxesStreamProvider(adapterBoxesArguments));

    return application.when(
      data: (application) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'PDF Page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: applicationComponents.when(
            data: (components) {
              List<AdapterBoxModel> boxes = [];
              selectedAdapterBoxes.whenData((value) {
                boxes = value;
              });
              return Center(
                child: OutlinedButton(
                  onPressed: () {
                    Invoice invoice = Invoice(
                      quotation: application.quotation,
                      info: InvoiceInfo(
                          description: 'description',
                          number: 'number',
                          date: DateTime.now(),
                          dueDate: DateTime.now()),
                      supplier: Supplier(
                        name: application.expertName,
                        address: 'address',
                        paymentInfo: 'paymentInfo',
                      ),
                      customer: Customer(
                        name: application.clientName,
                        address: 'address',
                      ),
                      items: List.generate(
                        components.length,
                        (index) => InvoiceItem(
                          description: components[index].name,
                          cost: components[index].cost,
                          units: components[index].number,
                          unitPrice: components[index].capacity,
                          specificItems: (components[index].name ==
                                  'Adapter Box Enclosure')
                              ? List.generate(
                                  boxes.length,
                                  (boxIndex) => SpecificInvoiceItem(
                                        description: boxes[boxIndex].name,
                                        quantity: 1,
                                        unitPrice: boxes[boxIndex].cost,
                                        cost: boxes[boxIndex].cost,
                                      ))
                              : [],
                        ),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => PDFScreen(
                              invoice: invoice,
                            )),
                      ),
                    );
                  },
                  child: const Text('Generate Invoice'),
                ),
              );
            },
            error: (error, stacktrace) => Text(error.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, stacktrace) => Text(error.toString()),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
