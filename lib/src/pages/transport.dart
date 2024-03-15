// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/prices.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class Transport extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const Transport({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransportState();
}

class _TransportState extends ConsumerState<Transport> {
  final TextEditingController timeController = TextEditingController();

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  bool validate = false;

  late List<String> arguments;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];

    super.initState();
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) async {
    ref.read(solarControllerProvider).updateApplicationComponentCost(
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

  void updateComponentQuanity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          widget.component,
          quantity,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    return component.when(
      data: (component) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              component.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: (component.isSelected == false)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Measures of determination',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
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
                          itemCount: component.measurement.length,
                          itemBuilder: ((context, index) {
                            return Text(component.measurement[index]);
                          }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'What is the time in minutes?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: timeController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'Time in minutes',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate ? "Value Can't Be Empty" : null,
                        ),
                      ),
                      const Text(
                        '*Price per minute: KES ${Prices.transport}',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                          onPressed: () {
                            setState(() {
                              validate = timeController.text.isEmpty;
                            });
                            (validate == true)
                                ? null
                                : updateComponentCost(
                                    int.parse(timeController.text) * Prices.transport);
                            (validate == true)
                                ? null
                                : updateComponentQuanity(
                                    int.parse(timeController.text));
                            (validate == true)
                                ? null
                                : updateSelectedStatus(true);
                            (validate == true)
                                ? null
                                : updateApplicationQuotation();
                          },
                          message: 'Confirm Selection',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(),
                      Text(
                        'Total transport time: ${component.quantity} minutes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total cost: KES ${component.cost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateComponentCost(0);
                          updateComponentQuanity(0);
                          updateSelectedStatus(false);
                          updateApplicationQuotation();
                        },
                        message: 'Edit Selection',
                      ),
                    ],
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
