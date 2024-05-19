// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:expandable/expandable.dart';
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
import 'package:solar_project/src/pages/ac_breaker_enclosure.dart';
import 'package:solar_project/src/pages/ac_contactor_single_phase.dart';
import 'package:solar_project/src/pages/ac_contactor_triple_phase.dart';
import 'package:solar_project/src/pages/adapter_box_pvc.dart';
import 'package:solar_project/src/pages/battery_cable.dart';
import 'package:solar_project/src/pages/battery_fuse.dart';
import 'package:solar_project/src/pages/busbar_complete.dart';
import 'package:solar_project/src/pages/cable_lugs.dart';
import 'package:solar_project/src/pages/cable_ties.dart';
import 'package:solar_project/src/pages/communication_components.dart';
import 'package:solar_project/src/pages/core_cable.dart';
import 'package:solar_project/src/pages/automatic_changeover_switch.dart';
import 'package:solar_project/src/pages/batteries_screen.dart';
import 'package:solar_project/src/pages/dc_battery_breaker.dart';
import 'package:solar_project/src/pages/dc_breaker.dart';
import 'package:solar_project/src/pages/dc_breaker_enlosure.dart';
import 'package:solar_project/src/pages/din_rail.dart';
import 'package:solar_project/src/pages/double_pole_mcb.dart';
import 'package:solar_project/src/pages/earth_rod_and_cable.dart';
import 'package:solar_project/src/pages/four_pole_mccb.dart';
import 'package:solar_project/src/pages/heat_shrink_tube.dart';
import 'package:solar_project/src/pages/insulation_tape.dart';
import 'package:solar_project/src/pages/inverter_manual_isolator.dart';
import 'package:solar_project/src/pages/inverter_module_screen.dart';
import 'package:solar_project/src/pages/labour.dart';
import 'package:solar_project/src/pages/lightning_arrestor.dart';
import 'package:solar_project/src/pages/marine_board.dart';
import 'package:solar_project/src/pages/mc4_connectors.dart';
import 'package:solar_project/src/pages/miscellaneous.dart';
import 'package:solar_project/src/pages/nine_way_combiner_box.dart';
import 'package:solar_project/src/pages/panel_screen.dart';
import 'package:solar_project/src/pages/piping.dart';
import 'package:solar_project/src/pages/pv_cable.dart';
import 'package:solar_project/src/pages/pv_combiner_box.dart';
import 'package:solar_project/src/pages/pv_line_fuse.dart';
import 'package:solar_project/src/pages/pv_surge_protector.dart';
import 'package:solar_project/src/pages/pvc_glue.dart';
import 'package:solar_project/src/pages/pvc_trunking.dart';
import 'package:solar_project/src/pages/adapter_box.dart';
import 'package:solar_project/src/pages/single_core_cable.dart';
import 'package:solar_project/src/pages/solar_panel_frame.dart';
import 'package:solar_project/src/pages/transport.dart';
import 'package:solar_project/src/pages/triple_pole_mccb.dart';
import 'package:solar_project/src/pages/voltage_guard.dart';
import 'package:solar_project/src/pages/wall_mounting_materials.dart';
import 'package:solar_project/src/pages/waterproof_scotch_tape.dart';
import 'package:solar_project/src/widgets/component_widget.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class ExpandableWidget extends ConsumerStatefulWidget {
  final String applicationId;
  const ExpandableWidget({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpandableWidgetState();
}

class _ExpandableWidgetState extends ConsumerState<ExpandableWidget> {
  bool isLoading = false;

  void saveComponentsToApplication() async {
    ref
        .watch(solarControllerProvider)
        .saveComponentsToApplication(applicationId: widget.applicationId);
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

  void saveSpecificComponents() {
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
  }

  @override
  Widget build(BuildContext context) {
    final applicationComponents =
        ref.watch(getApplicationComponentsStreamProvider(widget.applicationId));
    return SizedBox(
      child: ExpandablePanel(
        header: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Components checklist',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        collapsed: Container(),
        expanded: applicationComponents.when(
          data: (applicationComponents) {
            return (applicationComponents.isEmpty ||
                    applicationComponents.length < 46)
                ? errorWidget(
                    ref: ref,
                    applicationId: widget.applicationId,
                    isLoading: isLoading,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await Future.delayed(const Duration(seconds: 30), () {
                        saveComponentsToApplication();
                        saveSpecificComponents();
                      });
                      isLoading = false;
                    },
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.72,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      children: [
                        ComponentWidget(
                            component: applicationComponents[0],
                            navigate: PanelScreen(
                                component: applicationComponents[0].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[1],
                            navigate: InverterModuleScreen(
                                component: applicationComponents[1].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[2],
                            navigate: BatteriesScreen(
                                component: applicationComponents[2].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[3],
                            navigate: MC4ConnectorsScreen(
                                component: applicationComponents[3].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[4],
                            navigate: AutomaticChangeOverSwitch(
                                component: applicationComponents[4].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[5],
                            navigate: InverterManualIsolator(
                                component: applicationComponents[5].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[6],
                            navigate: CoreCable(
                                component: applicationComponents[6].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[7],
                            navigate: PVCombinerBox(
                                component: applicationComponents[7].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[8],
                            navigate: NineWayCombinerBox(
                                component: applicationComponents[8].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[9],
                            navigate: PVCable(
                                component: applicationComponents[9].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[10],
                            navigate: EarthRodAndCable(
                                component: applicationComponents[10].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[11],
                            navigate: BatteryCable(
                                component: applicationComponents[11].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[12],
                            navigate: CableLugs(
                                component: applicationComponents[12].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[13],
                            navigate: CableTies(
                                component: applicationComponents[13].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[14],
                            navigate: PipingScreen(
                                component: applicationComponents[14].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[15],
                            navigate: PVCTrunking(
                                component: applicationComponents[15].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[16],
                            navigate: TriplePoleMCCB(
                                component: applicationComponents[16].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[17],
                            navigate: DoublePoleMCB(
                                component: applicationComponents[17].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[18],
                            navigate: FourPoleMCCB(
                                component: applicationComponents[18].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[19],
                            navigate: ACBreakerEnclosure(
                                component: applicationComponents[19].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[20],
                            navigate: ACContactorSingle(
                                component: applicationComponents[20].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[21],
                            navigate: ACContactorTriple(
                                component: applicationComponents[21].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[22],
                            navigate: AdapterBox(
                                component: applicationComponents[22].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[23],
                            navigate: DINRail(
                                component: applicationComponents[23].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[24],
                            navigate: SingleCoreCable(
                                component: applicationComponents[24].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[25],
                            navigate: VoltageGuard(
                                component: applicationComponents[25].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[26],
                            navigate: DCBreaker(
                                component: applicationComponents[26].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[27],
                            navigate: DCBreakerEnclosure(
                                component: applicationComponents[27].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[28],
                            navigate: SurgeProtector(
                                component: applicationComponents[28].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[29],
                            navigate: LineFuse(
                                component: applicationComponents[29].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[30],
                            navigate: BatteryBreaker(
                                component: applicationComponents[30].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[31],
                            navigate: BatteryFuse(
                                component: applicationComponents[31].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[32],
                            navigate: AdapterBoxPVC(
                                component: applicationComponents[32].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[33],
                            navigate: LightningArrestor(
                                component: applicationComponents[33].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[34],
                            navigate: CommunicationComponents(
                                component: applicationComponents[34].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[35],
                            navigate: SolarPanelFrame(
                                component: applicationComponents[35].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[36],
                            navigate: PVCGlue(
                                component: applicationComponents[36].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[37],
                            navigate: WaterProofScotchTape(
                                component: applicationComponents[37].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[38],
                            navigate: InsulationTape(
                                component: applicationComponents[38].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[39],
                            navigate: HeatShrinkTube(
                                component: applicationComponents[39].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[40],
                            navigate: WallMountingMaterials(
                                component: applicationComponents[40].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[41],
                            navigate: MarineBoard(
                                component: applicationComponents[41].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[42],
                            navigate: BusbarComplete(
                                component: applicationComponents[42].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[43],
                            navigate: Transport(
                                component: applicationComponents[43].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[44],
                            navigate: Labour(
                                component: applicationComponents[44].name,
                                applicationId: widget.applicationId)),
                        ComponentWidget(
                            component: applicationComponents[45],
                            navigate: Miscellaneous(
                                component: applicationComponents[45].name,
                                applicationId: widget.applicationId)),
                      ],
                    ),
                  );
          },
          error: (error, stacktrace) => errorWidget(
            ref: ref,
            applicationId: widget.applicationId,
            isLoading: isLoading,
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await Future.delayed(const Duration(seconds: 30), () {
                saveComponentsToApplication();
                saveSpecificComponents();
              });
              isLoading = false;
            },
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget errorWidget({
    required WidgetRef ref,
    required String applicationId,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(),
        const SizedBox(
          height: 50,
        ),
        const Text(
          'Failed to fetch components',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ConfirmSelectionButton(
          onPressed: onPressed,
          message: (isLoading == true) ? 'Fetching components...' : 'Try again',
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }
}
