// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/pv_cables_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class PVCable extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const PVCable({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PVCableSixMMState();
}

class _PVCableSixMMState extends ConsumerState<PVCable> {
  final TextEditingController cableLengthController = TextEditingController();
  final TextEditingController cable2LengthController = TextEditingController();
  final TextEditingController cable3LengthController = TextEditingController();

  late List<String> arguments;

  late List<String> inverterArguments;

  bool validate = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      savePVCablesToApplication();
    });

    arguments = [widget.applicationId, widget.component];
    inverterArguments = [widget.applicationId, 'Inverter Module'];

    super.initState();
  }

  @override
  void dispose() {
    cableLengthController.dispose();
    cable2LengthController.dispose();
    cable3LengthController.dispose();
    super.dispose();
  }

  void savePVCablesToApplication() {
    ref.watch(pvCablesControllerProvider).savePVCablesToApplication(
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
    int cost = ((int.parse(cableLengthController.text) * 2) +
            int.parse(cable2LengthController.text) +
            (int.parse(cable3LengthController.text) * 2)) *
        40;
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
    int length = (int.parse(cableLengthController.text) * 2) +
        int.parse(cable2LengthController.text) +
        (int.parse(cable3LengthController.text) * 2);
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

  void checkLength(String crossSection) {
    final cableLength = (int.parse(cableLengthController.text) * 2) +
        int.parse(cable2LengthController.text) +
        (int.parse(cable3LengthController.text) * 2);
    if (cableLength <= 20) {
      updateCompoenentCrossSection(crossSection);
    }
    if (cableLength > 20) {
      updateCompoenentCrossSection('16mm');
    }
    updateComponentLength();
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    final inverterComponent =
        ref.watch(getApplicationComponentStreamProvider(inverterArguments));
    final pvCables = ref.watch(getPVCablesStreamProvider(arguments));

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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: (component.isSelected == false)
                ? ListView(
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
                      inverterComponent.when(
                        data: (inverter) {
                          return pvCables.when(
                            data: (cables) {
                              String finalCrossSection = '';
                              final crossSection1 = cables[0].crossSection;
                              final crossSection2 = cables[1].crossSection;
                              if (inverter.capacity <= 200) {
                                finalCrossSection = crossSection1;
                              }
                              if (inverter.capacity >= 200) {
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
                                  const Text(
                                    '*Cross section increases to 16mm\u00b2 if total distance is more than 20m',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.red),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    'What is the distance between roof and inverter?',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: cableLengthController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(
                                      hintText: 'Length in metres',
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
                                  const SizedBox(height: 15),
                                  const Text(
                                    'What is the distance between arrestor and earth rod?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: cable2LengthController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(
                                      hintText: 'Length in metres',
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
                                  const SizedBox(height: 15),
                                  const Text(
                                    'What is the distance between inverter and distribution box?',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: cable3LengthController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(
                                      hintText: 'Length in metres',
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
                                    '*Cable cost per metre = KES40',
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
                                            : checkLength(finalCrossSection);
                                        // (validate == true)
                                        //     ? null
                                        //     : updateCompoenentCrossSection(
                                        //         finalCrossSection);
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
                      const SizedBox(height: 15),
                      Text(
                        'Total cost: ${component.cost}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
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
