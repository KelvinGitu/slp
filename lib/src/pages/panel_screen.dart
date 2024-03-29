// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/prices.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class PanelScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const PanelScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelScreenState();
}

class _PanelScreenState extends ConsumerState<PanelScreen> {
  final TextEditingController panelsController = TextEditingController();

  late List<String> arguments;

  bool validate = false;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    super.initState();
  }

  @override
  void dispose() {
    panelsController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          widget.component,
          cost,
          widget.applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          widget.applicationId,
        );
  }

  void updateComponentQuantity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          widget.component,
          quantity,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final panelComponent =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panels',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: panelComponent.when(
        data: (panel) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: (panel.isSelected == false)
                ? Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Measures of determination',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                          itemCount: panel.measurement.length,
                          itemBuilder: ((context, index) {
                            return Text(panel.measurement[index]);
                          }),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'How many panels does the client want?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: panelsController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'No. of panels',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate ? "Value Can't Be Empty" : null,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '*approximate price: 1 panel = ${Prices.panels}',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          setState(() {
                            validate = panelsController.text.isEmpty;
                          });
                          (validate == true)
                              ? null
                              : updateComponentCost(
                                  int.parse(panelsController.text) *
                                      Prices.panels);
                          (validate == true)
                              ? null
                              : updateComponentQuantity(
                                  int.parse(panelsController.text));
                          (validate == true)
                              ? null
                              : updateSelectedStatus(true);
                          (validate == true)
                              ? null
                              : updateApplicationQuotation();
                        },
                        message: 'Confirm Selection',
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(),
                      Text(
                        'No of panels: ${panel.quantity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total Cost: KES ${panel.cost}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateSelectedStatus(false);
                          updateComponentCost(0);
                          updateComponentQuantity(0);
                          updateApplicationQuotation();
                        },
                        message: 'Edit Selection',
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '*Any changes made here must also be made for the MC4 connecctors',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      )
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
  }
}
