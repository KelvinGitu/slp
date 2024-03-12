// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/pages/adapter_box.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class DINRail extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const DINRail({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DINRailState();
}

class _DINRailState extends ConsumerState<DINRail> {
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

  void updateComponentLength(int length) {
    ref.watch(solarControllerProvider).updateApplicationComponentLength(
          widget.component,
          length * 2,
          widget.applicationId,
        );
  }

  void updateComponentQuanity() {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          widget.component,
          1,
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
            child:
                (component.isSelected == false && component.isRequired == true)
                    ? Column(
                        children: [
                          Text(
                            'A ${component.name} is determined by the choice of adapter box.',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 40),
                          ConfirmSelectionButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) {
                                    return AdapterBox(
                                        component: 'Adapter Box Enclosure',
                                        applicationId: widget.applicationId);
                                  }),
                                ),
                              );
                            },
                            message: 'Select Adapter Box',
                          ),
                        ],
                      )
                    : (component.isSelected == false &&
                            component.isRequired == false)
                        ? Column(
                            children: [
                              Text(
                                'A ${component.name} is not required as the client has chosen to use a plastic adapter box',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 40),
                              ConfirmSelectionButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                message: 'Exit',
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const Text(
                                'The client has selected to use a steel adapter box. A DIN Rail was added automatically to the installation requirements',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Total cost: ${component.cost} KES',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 40),
                              ConfirmSelectionButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                message: 'Exit',
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