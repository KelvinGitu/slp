// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/prices.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class InsulationTape extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const InsulationTape({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InsulationTapeState();
}

class _InsulationTapeState extends ConsumerState<InsulationTape> {
  final TextEditingController tapeController = TextEditingController();

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
                        Text(
                          '${component.name} of length ${component.length} is required for this installation. Input the number of tapes that satisfy installation requirements',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: tapeController,
                          keyboardType: const TextInputType.numberWithOptions(),
                          decoration: InputDecoration(
                            hintText: 'No. of tapes',
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
                          '*Price per unit: KES ${Prices.insulationTape}',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConfirmSelectionButton(
                            onPressed: () {
                              setState(() {
                                validate = tapeController.text.isEmpty;
                              });
                              (validate == true)
                                  ? null
                                  : updateComponentQuanity(
                                      int.parse(tapeController.text));
                              (validate == true)
                                  ? null
                                  : updateComponentCost(
                                      int.parse(tapeController.text) * Prices.insulationTape);
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
                          'No. of ${component.name}s (${component.length}m): ${component.quantity}',
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
                            updateSelectedStatus(false);
                            updateComponentCost(0);
                            updateComponentQuanity(0);
                            updateApplicationQuotation();
                          },
                          message: 'Edit Selection',
                        ),
                      ],
                    )),
        );
      },
      error: (error, stacktrace) => Text(error.toString()),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
