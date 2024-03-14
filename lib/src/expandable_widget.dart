// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/pages/ac_breaker_enclosure.dart';
import 'package:solar_project/src/pages/ac_contactor_single_phase.dart';
import 'package:solar_project/src/pages/ac_contactor_triple_phase.dart';
import 'package:solar_project/src/pages/adapter_box_pvc.dart';
import 'package:solar_project/src/pages/battery_cable.dart';
import 'package:solar_project/src/pages/battery_fuse.dart';
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
import 'package:solar_project/src/pages/inverter_manual_isolator.dart';
import 'package:solar_project/src/pages/inverter_module_screen.dart';
import 'package:solar_project/src/pages/lightning_arrestor.dart';
import 'package:solar_project/src/pages/mc4_connectors.dart';
import 'package:solar_project/src/pages/nine_way_combiner_box.dart';
import 'package:solar_project/src/pages/panel_screen.dart';
import 'package:solar_project/src/pages/piping.dart';
import 'package:solar_project/src/pages/pv_cable.dart';
import 'package:solar_project/src/pages/pv_combiner_box.dart';
import 'package:solar_project/src/pages/pv_line_fuse.dart';
import 'package:solar_project/src/pages/pv_surge_protector.dart';
import 'package:solar_project/src/pages/pvc_trunking.dart';
import 'package:solar_project/src/pages/adapter_box.dart';
import 'package:solar_project/src/pages/single_core_cable.dart';
import 'package:solar_project/src/pages/solar_panel_frame.dart';
import 'package:solar_project/src/pages/triple_pole_mccb.dart';
import 'package:solar_project/src/pages/voltage_guard.dart';
import 'package:solar_project/src/widgets/component_widget.dart';

class ExpandableWidget extends ConsumerWidget {
  final String applicationId;
  const ExpandableWidget({
    super.key,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationComponents =
        ref.watch(getApplicationComponentsStreamProvider(applicationId));
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
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                children: [
                  ComponentWidget(
                      component: applicationComponents[0],
                      navigate: PanelScreen(
                          component: applicationComponents[0].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[1],
                      navigate: InverterModuleScreen(
                          component: applicationComponents[1].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[2],
                      navigate: BatteriesScreen(
                          component: applicationComponents[2].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[3],
                      navigate: MC4ConnectorsScreen(
                          component: applicationComponents[3].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[4],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[4].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[5],
                      navigate: InverterManualIsolator(
                          component: applicationComponents[5].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[6],
                      navigate: CoreCable(
                          component: applicationComponents[6].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[7],
                      navigate: PVCombinerBox(
                          component: applicationComponents[7].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[8],
                      navigate: NineWayCombinerBox(
                          component: applicationComponents[8].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[9],
                      navigate: PVCable(
                          component: applicationComponents[9].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[10],
                      navigate: EarthRodAndCable(
                          component: applicationComponents[10].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[11],
                      navigate: BatteryCable(
                          component: applicationComponents[11].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[12],
                      navigate: CableLugs(
                          component: applicationComponents[12].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[13],
                      navigate: CableTies(
                          component: applicationComponents[13].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[14],
                      navigate: PipingScreen(
                          component: applicationComponents[14].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[15],
                      navigate: PVCTrunking(
                          component: applicationComponents[15].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[16],
                      navigate: TriplePoleMCCB(
                          component: applicationComponents[16].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[17],
                      navigate: DoublePoleMCB(
                          component: applicationComponents[17].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[18],
                      navigate: FourPoleMCCB(
                          component: applicationComponents[18].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[19],
                      navigate: ACBreakerEnclosure(
                          component: applicationComponents[19].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[20],
                      navigate: ACContactorSingle(
                          component: applicationComponents[20].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[21],
                      navigate: ACContactorTriple(
                          component: applicationComponents[21].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[22],
                      navigate: AdapterBox(
                          component: applicationComponents[22].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[23],
                      navigate: DINRail(
                          component: applicationComponents[23].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[24],
                      navigate: SingleCoreCable(
                          component: applicationComponents[24].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[25],
                      navigate: VoltageGuard(
                          component: applicationComponents[25].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[26],
                      navigate: DCBreaker(
                          component: applicationComponents[26].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[27],
                      navigate: DCBreakerEnclosure(
                          component: applicationComponents[27].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[28],
                      navigate: SurgeProtector(
                          component: applicationComponents[28].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[29],
                      navigate: LineFuse(
                          component: applicationComponents[29].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[30],
                      navigate: BatteryBreaker(
                          component: applicationComponents[30].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[31],
                      navigate: BatteryFuse(
                          component: applicationComponents[31].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[32],
                      navigate: AdapterBoxPVC(
                          component: applicationComponents[32].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[33],
                      navigate: LightningArrestor(
                          component: applicationComponents[33].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[34],
                      navigate: CommunicationComponents(
                          component: applicationComponents[34].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[35],
                      navigate: SolarPanelFrame(
                          component: applicationComponents[35].name,
                          applicationId: applicationId)),
                ],
              ),
            );
          },
          error: (error, stacktrace) => Text(error.toString()),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
