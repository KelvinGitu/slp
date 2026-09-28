// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class SolarPanelFrame extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const SolarPanelFrame({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SolarPanelFrameState();
}

class _SolarPanelFrameState extends ConsumerState<SolarPanelFrame> {
  bool validate = false;

  late List<String> arguments;

  late List<String> panelArguments;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    panelArguments = [widget.applicationId, 'Panels'];

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

    final panelComponent =
        ref.watch(getApplicationComponentStreamProvider(panelArguments));

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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topCenter,
                        child: panelComponent.when(
                          data: (panel) {
                            return panelQuantity(
                              context: context,
                              ref: ref,
                              applicationId: widget.applicationId,
                              component: widget.component,
                              panel: panel,
                            );
                          },
                          error: (error, stacktrace) => Text(error.toString()),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
                  )
                : selectedTrue(
                    context: context,
                    applicationId: widget.applicationId,
                    component: widget.component,
                    componentsModel: component,
                    ref: ref,
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

Widget panelQuantity({
  required BuildContext context,
  required WidgetRef ref,
  required String applicationId,
  required String component,
  required ComponentsModel panel,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          component,
          selected,
          applicationId,
        );
  }

  void updateComponentCost(int cost) async {
    ref.read(solarControllerProvider).updateApplicationComponentCost(
          component,
          cost,
          applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          applicationId,
        );
  }

  void updateComponentQuantity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          component,
          quantity,
          applicationId,
        );
  }

  final numberOfFrames = panel.quantity;
  final costOfFrames = numberOfFrames * 1200;
  return Column(
    children: [
      Text(
        'Number of panels: ${panel.quantity}',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 15),
      Text(
        'Number of Solar Frames: $numberOfFrames',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Total cost: KES $costOfFrames',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 40),
      ConfirmSelectionButton(
        onPressed: () {
          updateComponentCost(costOfFrames);
          updateComponentQuantity(numberOfFrames);
          updateSelectedStatus(true);
          updateApplicationQuotation();
        },
        message: 'Confirm Selection',
      ),
    ],
  );
}

Widget selectedTrue({
  required BuildContext context,
  required String applicationId,
  required String component,
  required ComponentsModel componentsModel,
  required WidgetRef ref,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          component,
          selected,
          applicationId,
        );
  }

  void updateComponentCost(int cost) async {
    ref.read(solarControllerProvider).updateApplicationComponentCost(
          component,
          cost,
          applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          applicationId,
        );
  }

  void updateComponentQuantity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          component,
          quantity,
          applicationId,
        );
  }

  return Column(
    children: [
      Container(),
       Text(
        'Number of Solar Frames: ${componentsModel.quantity}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Total cost: ${componentsModel.cost}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 40),
      ConfirmSelectionButton(
        onPressed: () {
          updateSelectedStatus(false);
          updateComponentQuantity(0);
          updateComponentCost(0);
          updateApplicationQuotation();
        },
        message: 'Edit Selection',
      ),
    ],
  );
}
