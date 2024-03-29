// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/adapter_boxes_controller.dart';
import 'package:solar_project/src/controller/battery_breaker_controller.dart';
import 'package:solar_project/src/controller/battery_cables_controller.dart';
import 'package:solar_project/src/controller/battery_capacities_controller.dart';
import 'package:solar_project/src/controller/cable_lugs_controller.dart';
import 'package:solar_project/src/controller/communication_components_controller.dart';
import 'package:solar_project/src/controller/core_cables_controller.dart';
import 'package:solar_project/src/controller/dc_breaker_controller.dart';
import 'package:solar_project/src/controller/dc_breaker_enclosures_controller.dart';
import 'package:solar_project/src/controller/inverter_module_controller.dart';
import 'package:solar_project/src/controller/line_fuse_controller.dart';
import 'package:solar_project/src/controller/piping_components_controller.dart';
import 'package:solar_project/src/controller/pv_cables_controller.dart';
import 'package:solar_project/src/controller/single_core_cables_controller.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/controller/surge_protector_controller.dart';
import 'package:solar_project/src/controller/voltage_guards_controller.dart';

import 'package:solar_project/src/expandable_widget.dart';
import 'package:solar_project/src/home_screen.dart';
import 'package:solar_project/src/pdf/pdf_page.dart';

class ComponentsScreen extends ConsumerStatefulWidget {
  final String applicationId;
  const ComponentsScreen({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ComponentsScreenState();
}

class _ComponentsScreenState extends ConsumerState<ComponentsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      updateApplicationQuotation();
      saveBatteryCapacitiesToApplication();
      saveCoreCablesToApplication();
      savePVCablesToApplication();
      saveBatteryCablesToApplication();
      savePipingComponentsToApplication();
      saveBoxesToApplication();
      saveSingleCoreCablesToApplication();
      saveVoltageGuardsToApplication();
      saveDCBreakersToApplication();
      saveDCBreakerEnclosuresToApplication();
      saveSurgeProtectorsToApplication();
      saveLineFuseToApplication();
      saveBatteryBreakerToApplication();
      saveCommunicationComponentsToApplication();
      saveCableLugsToApplication();
      saveInverterModulesToApplication();
    });
    super.initState();
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          widget.applicationId,
        );
  }

  void saveBatteryCapacitiesToApplication() async {
    bool componentExist = await ref
        .read(batteryCapacitiesControllerProvider)
        .checkBatteryCapacityExists(
          widget.applicationId,
          'Batteries',
          '100Ah',
        );
    if (componentExist == false) {
      ref
          .watch(batteryCapacitiesControllerProvider)
          .saveBatteryCapacityToApplication(
            applicationId: widget.applicationId,
            component: 'Batteries',
          );
    }
  }

  void saveCoreCablesToApplication() async {
    bool componentExist =
        await ref.read(coreCablesControllerProvider).checkCoreCableExists(
              widget.applicationId,
              'Core Cable',
              '10mm',
            );
    if (componentExist == false) {
      ref.watch(coreCablesControllerProvider).saveCoreCablesToApplication(
            applicationId: widget.applicationId,
            component: 'Core Cable',
          );
    }
  }

  void savePVCablesToApplication() async {
    bool componentExist =
        await ref.read(pvCablesControllerProvider).checkPVCableExists(
              widget.applicationId,
              'PV Cable',
              '10mm',
            );
    if (componentExist == false) {
      ref.watch(pvCablesControllerProvider).savePVCablesToApplication(
            applicationId: widget.applicationId,
            component: 'PV Cable',
          );
    }
  }

  void saveBatteryCablesToApplication() async {
    bool cableExists =
        await ref.read(batteryCablesControllerProvider).checkBatteryCableExists(
              widget.applicationId,
              'Battery Cable',
              '4mm',
            );
    if (cableExists == false) {
      ref.read(batteryCablesControllerProvider).saveBatteryCablesToApplication(
            applicationId: widget.applicationId,
            component: 'Battery Cable',
          );
    }
  }

  void savePipingComponentsToApplication() async {
    bool componentExist = await ref
        .read(pipingComponentsControllerProvider)
        .checkPipingComponentExists(
          widget.applicationId,
          'Piping',
          'conduit',
        );
    if (componentExist == false) {
      ref
          .read(pipingComponentsControllerProvider)
          .savePipingComponentsToApplication(
            applicationId: widget.applicationId,
            component: 'Piping',
          );
    }
  }

  void saveBoxesToApplication() async {
    bool componentExist =
        await ref.read(adapterBoxesControllerProvider).checkBoxExists(
              widget.applicationId,
              'Adapter Box Enclosure',
              'Plastic',
            );
    if (componentExist == false) {
      ref.read(adapterBoxesControllerProvider).saveBoxesToApplication(
            applicationId: widget.applicationId,
            component: 'Adapter Box Enclosure',
          );
    }
  }

  void saveSingleCoreCablesToApplication() async {
    bool componentExist = await ref
        .read(singleCoreCablesControllerProvider)
        .checkSingelCoreCableExists(
          widget.applicationId,
          '1.5mm² Single Core Cable',
          'R+Y+B+N',
        );
    if (componentExist == false) {
      ref
          .read(singleCoreCablesControllerProvider)
          .saveSingleCoreCablesToApplication(
            applicationId: widget.applicationId,
            component: '1.5mm² Single Core Cable',
          );
    }
  }

  void saveVoltageGuardsToApplication() async {
    bool componentExist =
        await ref.read(voltageGuardsControllerProvider).checkVoltageGuardExists(
              widget.applicationId,
              'Voltage Guard',
              'single-phase',
            );
    if (componentExist == false) {
      ref.read(voltageGuardsControllerProvider).saveVoltageGuardsToApplication(
            applicationId: widget.applicationId,
            component: 'Voltage Guard',
          );
    }
  }

  void saveDCBreakersToApplication() async {
    bool componentExist =
        await ref.read(dcBreakerControllerProvider).checkBreakerExists(
              widget.applicationId,
              'DC Breaker',
              '1000V',
            );
    if (componentExist == false) {
      ref.read(dcBreakerControllerProvider).saveBreakersToApplication(
            applicationId: widget.applicationId,
            component: 'DC Breaker',
          );
    }
  }

  void saveDCBreakerEnclosuresToApplication() async {
    bool componentExist = await ref
        .read(dcBreakerEnclosureControllerProvider)
        .checkBreakerEnclosureExists(
          widget.applicationId,
          'DC Breaker Enclosure',
          '12way',
        );
    if (componentExist == false) {
      ref
          .read(dcBreakerEnclosureControllerProvider)
          .saveBreakerEnclosuresToApplication(
            applicationId: widget.applicationId,
            component: 'DC Breaker Enclosure',
          );
    }
  }

  void saveSurgeProtectorsToApplication() async {
    bool componentExist = await ref
        .read(surgeProtectorControllerProvider)
        .checkSurgeProtectorExists(
          widget.applicationId,
          'Surge Protector',
          '1000V',
        );
    if (componentExist == false) {
      ref
          .read(surgeProtectorControllerProvider)
          .saveSurgeProtectorsToApplication(
            applicationId: widget.applicationId,
            component: 'Surge Protector',
          );
    }
  }

  void saveLineFuseToApplication() async {
    bool componentExist =
        await ref.read(lineFuseControllerProvider).checkFuseExists(
              widget.applicationId,
              'Line Fuse',
              '20A',
            );
    if (componentExist == false) {
      ref.read(lineFuseControllerProvider).saveFusesToApplication(
            applicationId: widget.applicationId,
            component: 'Line Fuse',
          );
    }
  }

  void saveBatteryBreakerToApplication() async {
    bool componentExist = await ref
        .read(batteryBreakerControllerProvider)
        .checkBatteryBreakerExists(
          widget.applicationId,
          'DC Battery Breaker',
          '150A',
        );
    if (componentExist == false) {
      ref
          .read(batteryBreakerControllerProvider)
          .saveBatteryBreakersToApplication(
            applicationId: widget.applicationId,
            component: 'DC Battery Breaker',
          );
    }
  }

  void saveCommunicationComponentsToApplication() async {
    bool componentExist = await ref
        .read(communicationComponentsControllerProvider)
        .checkCommunicationComponentExists(
          widget.applicationId,
          'Commmunication Components',
          'cable',
        );
    if (componentExist == false) {
      ref
          .read(communicationComponentsControllerProvider)
          .saveCommunicationComponentsToApplication(
            applicationId: widget.applicationId,
            component: 'Communication Components',
          );
    }
  }

  void saveCableLugsToApplication() async {
    bool componentExist =
        await ref.read(cableLugsControllerProvider).checkLugExists(
              widget.applicationId,
              'Cable Lugs',
              'earth',
            );
    if (componentExist == false) {
      ref.read(cableLugsControllerProvider).saveLugsToApplication(
            applicationId: widget.applicationId,
            component: 'Cable Lugs',
          );
    }
  }

  void saveInverterModulesToApplication() async {
    bool componentExist =
        await ref.read(inverterModuleControllerProvider).checkModuleExists(
              widget.applicationId,
              'Inverter Module',
              '1000W',
            );
    if (componentExist == false) {
      ref.read(inverterModuleControllerProvider).saveModulesToApplication(
            applicationId: widget.applicationId,
            component: 'Inverter Module',
          );
    }
  }

  void updateApplicationDoneStatus(bool done) async {
    ref.watch(solarControllerProvider).updateApplicationDoneStatus(
          widget.applicationId,
          done,
        );
  }

  @override
  Widget build(BuildContext context) {
    final application =
        ref.watch(getApplicationStreamProvider(widget.applicationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Application',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          application.when(
            data: (application) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${application.clientName}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quotation: KES ${application.quotation.toString()}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              );
            },
            error: (error, stacktrace) => Text(error.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 20),
          ExpandableWidget(
            applicationId: widget.applicationId,
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 30,
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      // ref.watch(solarControllerProvider).saveComponent();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => const HomeScreen()),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10)),
                    child: const Text(
                      'Continue Later',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 120,
                  child: OutlinedButton(
                    onPressed: () {
                      updateApplicationDoneStatus(true);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Close Application"),
                            content: const Text("Close application?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () {
                                  updateApplicationDoneStatus(false);
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text("Continue"),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => PDFPage(
                                            applicationId: widget.applicationId,
                                          )),
                                    ),
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10)),
                    child: const Text(
                      'Close application',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
