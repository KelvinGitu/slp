// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/battery_breaker_controller.dart';
import 'package:solar_project/src/controller/dc_breaker_controller.dart';
import 'package:solar_project/src/controller/dc_breaker_enclosures_controller.dart';
import 'package:solar_project/src/controller/line_fuse_controller.dart';
import 'package:solar_project/src/controller/single_core_cables_controller.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/controller/surge_protector_controller.dart';
import 'package:solar_project/src/controller/voltage_guards_controller.dart';
import 'package:solar_project/src/home_screen.dart';

import 'package:solar_project/src/expandable_widget.dart';

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
      saveSingleCoreCablesToApplication();
      saveVoltageGuardsToApplication();
      saveDCBreakersToApplication();
      saveDCBreakerEnclosuresToApplication();
      saveSurgeProtectorsToApplication();
      saveLineFuseToApplication();
      saveBatteryBreakerToApplication();
    });
    super.initState();
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          widget.applicationId,
        );
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

  @override
  Widget build(BuildContext context) {
    final application =
        ref.watch(getApplicationStreamProvider(widget.applicationId));

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
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
                  (route) => false);
            },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text('Continue later?'),
          ),
        ),
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
                          fontSize: 16, fontWeight: FontWeight.w500),
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
        ],
      ),
    );
  }
}
