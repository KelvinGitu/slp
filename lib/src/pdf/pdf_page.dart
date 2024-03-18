import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:solar_project/models/adapter_box_model.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/components_model.dart';
// import 'package:solar_project/src/controller/adapter_boxes_controller.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/home_screen.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';
import 'package:solar_project/src/pdf/pdf_viewer.dart';

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
    // final selectedAdapterBoxes =
    //     ref.watch(getFutureSelectedBoxesStreamProvider(adapterBoxesArguments));

    return application.when(
      data: (application) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: applicationComponents.when(
            data: (components) {
              // List<AdapterBoxModel> boxes = [];
              // selectedAdapterBoxes.whenData((value) {
              //   boxes = value;
              // });
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client name: ${application.clientName}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quotation: ${application.quotation}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 40),
                    showOptions(
                        context: context,
                        application: application,
                        components: components),
                    const SizedBox(height: 40),
                  ],
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

Widget showOptions(
    {required BuildContext context,
    required ApplicationModel application,
    required List<ComponentsModel> components}) {
  final size = MediaQuery.of(context).size;
  return Align(
    alignment: Alignment.topCenter,
    child: SizedBox(
      height: 35,
      width: 100,
      child: OutlinedButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FractionallySizedBox(
                    heightFactor: 0.3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 5,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.withOpacity(0.4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                              onTap: () {},
                              child: SizedBox(
                                  height: 40,
                                  width: size.width,
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                      'Generate components list',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))),
                          const SizedBox(height: 15),
                          InkWell(
                              onTap: () {
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
                                      specificItems:
                                          // (components[index].name ==
                                          //         'Adapter Box Enclosure')
                                          //     ? List.generate(
                                          //         boxes.length,
                                          //         (boxIndex) => SpecificInvoiceItem(
                                          //               description: boxes[boxIndex].name,
                                          //               quantity: 1,
                                          //               unitPrice: boxes[boxIndex].cost,
                                          //               cost: boxes[boxIndex].cost,
                                          //             ))
                                          //     :
                                          [],
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => PDFViewer(
                                          invoice: invoice,
                                        )),
                                  ),
                                );
                              },
                              child: SizedBox(
                                  height: 40,
                                  width: size.width,
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                      'Generate invoice',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))),
                          const SizedBox(height: 15),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => const HomeScreen()),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: SizedBox(
                                  height: 40,
                                  width: size.width,
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                      'Exit',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))),
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2))),
        child: const Icon(Icons.add),
      ),
    ),
  );
}
