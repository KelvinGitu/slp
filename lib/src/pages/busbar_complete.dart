// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:solar_project/src/widgets/yes_no_button.dart';

class BusbarComplete extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const BusbarComplete({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BusbarCompleteState();
}

class _BusbarCompleteState extends ConsumerState<BusbarComplete> {
  bool validate = false;

  late List<String> arguments;

  Color yesbackgroundColor = Colors.white;
  Color nobackgroundColor = Colors.white;

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

  void updateRequiredStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
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
            child: (component.isRequired == false &&
                    component.isSelected == false)
                ? componentNotRequired(
                    context: context,
                    applicationId: widget.applicationId,
                    component: widget.component,
                    ref: ref,
                  )
                : (component.isSelected == false)
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
                          const SizedBox(height: 15),
                          const Text(
                            'Add this component to the installation?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                YesNoButton(
                                  onPressed: () {
                                    setState(() {
                                      yesbackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                      nobackgroundColor = Colors.white;
                                    });
                                    updateSelectedStatus(true);
                                    updateApplicationQuotation();
                                  },
                                  yesNo: 'Yes',
                                  background: yesbackgroundColor,
                                ),
                                YesNoButton(
                                  onPressed: () {
                                    setState(() {
                                      yesbackgroundColor = Colors.white;
                                      nobackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                    });
                                    updateSelectedStatus(false);
                                    updateRequiredStatus(false);
                                    updateApplicationQuotation();
                                  },
                                  yesNo: 'No',
                                  background: nobackgroundColor,
                                ),
                              ],
                            ),
                          )
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

  Widget componentNotRequired({
    required BuildContext context,
    required String applicationId,
    required String component,
    required WidgetRef ref,
  }) {
    void updateSelectedStatus(bool selected) {
      ref
          .watch(solarControllerProvider)
          .updateApplicationComponentSelectedStatus(
            component,
            selected,
            applicationId,
          );
    }

    void updateApplicationQuotation() {
      ref.watch(solarControllerProvider).updateApplicationQuotation(
            applicationId,
          );
    }

    void updateRequiredStatus(bool selected) {
      ref
          .watch(solarControllerProvider)
          .updateApplicationComponentRequiredStatus(
            component,
            selected,
            applicationId,
          );
    }

    return Column(
      children: [
        const Text(
          'This component is not required for this installation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 40),
        ConfirmSelectionButton(
          onPressed: () {
            updateRequiredStatus(true);
            updateSelectedStatus(false);
            updateApplicationQuotation();
          },
          message: 'Edit Selection',
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
      ref
          .watch(solarControllerProvider)
          .updateApplicationComponentSelectedStatus(
            component,
            selected,
            applicationId,
          );
    }

    void updateApplicationQuotation() {
      ref.watch(solarControllerProvider).updateApplicationQuotation(
            applicationId,
          );
    }

    return Column(
      children: [
        Container(),
        Text(
          'A ${componentsModel.name} will be included in the installation',
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
            updateApplicationQuotation();
          },
          message: 'Edit Selection',
        ),
      ],
    );
  }
}
