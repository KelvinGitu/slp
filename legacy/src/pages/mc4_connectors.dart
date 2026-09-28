// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/prices.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
// import 'package:solar_project/src/pages/panel_screen.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class MC4ConnectorsScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const MC4ConnectorsScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MC4ConnectorsScreenState();
}

class _MC4ConnectorsScreenState extends ConsumerState<MC4ConnectorsScreen> {
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

  void updateComponentCost(int cost) {
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

  void updateComponentQuantity(int quantity) {
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          data: (panelComponent) {
                            final numberOfConnectors =
                                panelComponent.quantity * 4;
                            final costOfConnectors =
                                numberOfConnectors * Prices.mc4Connectors;
                            return Column(
                              children: [
                                Text(
                                  'Number of panels: ${panelComponent.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Number of connectors: $numberOfConnectors',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Approximate cost: KES $costOfConnectors',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                ConfirmSelectionButton(
                                    onPressed: () {
                                      updateComponentCost(costOfConnectors);
                                      updateComponentQuantity(
                                          numberOfConnectors);
                                      updateSelectedStatus(true);
                                      updateApplicationQuotation();
                                    },
                                    message: 'Confirm Selection'),
                              ],
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
                : Column(
                    children: [
                      const Text(
                        'This component has been included in the installation. Any changes will have to be made in the panels section.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Number of connectors: ${component.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Approximate cost: KES ${component.cost}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: ((context) {
                          //       return PanelScreen(
                          //           component: 'Panels',
                          //           applicationId: widget.applicationId);
                          //     }),
                          //   ),
                          // );
                          updateSelectedStatus(false);
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
