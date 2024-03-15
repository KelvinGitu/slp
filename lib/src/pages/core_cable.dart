// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/prices.dart';
import 'package:solar_project/src/controller/core_cables_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class CoreCable extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const CoreCable({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TenMMCoreCableState();
}

class _TenMMCoreCableState extends ConsumerState<CoreCable> {
  final TextEditingController cableLengthController = TextEditingController();

  late List<String> arguments;

  late List<String> inverterArguments;

  bool validate = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      saveCoreCablesToApplication();
    });

    arguments = [widget.applicationId, widget.component];
    inverterArguments = [widget.applicationId, 'Inverter Module'];

    super.initState();
  }

  @override
  void dispose() {
    cableLengthController.dispose();
    super.dispose();
  }

  void saveCoreCablesToApplication() {
    ref.watch(coreCablesControllerProvider).saveCoreCablesToApplication(
          applicationId: widget.applicationId,
          component: widget.component,
        );
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost() {
    int cost = int.parse(cableLengthController.text) * 2 * Prices.coreCable;
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

  void updateComponentLength() {
    int length = int.parse(cableLengthController.text) * 2;
    ref.watch(solarControllerProvider).updateApplicationComponentLength(
          widget.component,
          length,
          widget.applicationId,
        );
  }

  void updateCompoenentCrossSection(String crossSection) {
    ref.watch(solarControllerProvider).updateApplicationComponentCrossSection(
          widget.component,
          crossSection,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    final inverterComponent =
        ref.watch(getApplicationComponentStreamProvider(inverterArguments));
    final coreCables = ref.watch(getCoreCablesStreamProvider(arguments));
    return component.when(
      data: (component) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              component.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                            fontSize: 16, fontWeight: FontWeight.w600),
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
                      inverterComponent.when(
                        data: (inverter) {
                          return coreCables.when(
                            data: (cables) {
                              String finalCrossSection = '';
                              final crossSection1 = cables[0].crossSection;
                              final crossSection2 = cables[1].crossSection;
                              if (inverter.capacity <= 200) {
                                finalCrossSection = crossSection1;
                              } else {
                                finalCrossSection = crossSection2;
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Inverter Power: ${inverter.capacity}W/m\u00b2',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Based on inverter power, the recommended cable cross section is: $finalCrossSection\u00b2',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'What is the distance between inverter and distribution box?',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: cableLengthController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(
                                      hintText: 'Distance in metres',
                                      hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.6)),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.2),
                                      errorText: validate
                                          ? "Value Can't Be Empty"
                                          : null,
                                    ),
                                  ),
                                  const Text(
                                    '*Cable cost per metre = KES ${Prices.coreCable}',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.red),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: ConfirmSelectionButton(
                                      onPressed: () {
                                        setState(() {
                                          validate = cableLengthController
                                              .text.isEmpty;
                                        });
                                        (validate == true)
                                            ? null
                                            : updateComponentCost();
                                        (validate == true)
                                            ? null
                                            : updateSelectedStatus(true);
                                        (validate == true)
                                            ? null
                                            : updateComponentLength();
                                        (validate == true)
                                            ? null
                                            : updateCompoenentCrossSection(
                                                finalCrossSection);
                                        (validate == true)
                                            ? null
                                            : updateApplicationQuotation();
                                      },
                                      message: 'Confirm selection',
                                    ),
                                  ),
                                ],
                              );
                            },
                            error: (error, stacktrace) =>
                                Text(error.toString()),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        error: (error, stacktrace) => Text(error.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(),
                      Text(
                        'Cable Cross-section: ${component.crossSection}\u00b2',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Cable length: ${component.length}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total cost: ${component.cost}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                          onPressed: () {
                            updateSelectedStatus(false);
                          },
                          message: 'Edit selection')
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
