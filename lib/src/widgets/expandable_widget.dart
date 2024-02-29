// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/pages/automatic_changeover_switch.dart';
import 'package:solar_project/src/pages/batteries_screen.dart';
import 'package:solar_project/src/pages/inverter_module_screen.dart';
import 'package:solar_project/src/pages/mc4_connectors.dart';
import 'package:solar_project/src/pages/panel_screen.dart';
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
              height: MediaQuery.of(context).size.height * 0.8,
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
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[5].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[6],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[6].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[7],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[7].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[8],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[8].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[9],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[9].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[10],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[10].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[11],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[11].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[12],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[12].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[13],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[13].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[14],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[14].name,
                          applicationId: applicationId)),
                  ComponentWidget(
                      component: applicationComponents[15],
                      navigate: AutomaticChangeOverSwitch(
                          component: applicationComponents[15].name,
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
