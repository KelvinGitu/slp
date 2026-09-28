// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/communication_components_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/communication_components_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/communication_components_widget.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:solar_project/src/widgets/yes_no_button.dart';

class CommunicationComponents extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const CommunicationComponents({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommuniicationComponentsState();
}

class _CommuniicationComponentsState
    extends ConsumerState<CommunicationComponents> {
  late List<String> arguments;

  bool validate = false;

  bool communicationDevice = false;

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

  void updateComponentCost() async {
    int cost = 0;
    final components = await ref
        .read(communicationComponentsControllerProvider)
        .getFutureSelectedCommunicationComponents(
            widget.applicationId, widget.component);
    if (components.isNotEmpty) {
      for (CommunicationComponentsModel component in components) {
        cost = cost + component.cost;
        ref.watch(solarControllerProvider).updateApplicationComponentCost(
              widget.component,
              cost,
              widget.applicationId,
            );
      }
    } else {
      ref.watch(solarControllerProvider).updateApplicationComponentCost(
            widget.component,
            0,
            widget.applicationId,
          );
    }
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

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    final communicationComponents =
        ref.watch(getCommunicationComponentsStreamProvider(arguments));
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
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Is your client interested in communication components?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                YesNoButton(
                                  onPressed: () {
                                    setState(() {
                                      communicationDevice = true;
                                      yesbackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                      nobackgroundColor = Colors.white;
                                    });
                                  },
                                  yesNo: 'Yes',
                                  background: yesbackgroundColor,
                                ),
                                YesNoButton(
                                  onPressed: () {
                                    setState(() {
                                      communicationDevice = false;
                                      nobackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                      yesbackgroundColor = Colors.white;
                                    });
                                    updateRequiredStatus(false);
                                    updateSelectedStatus(false);
                                  },
                                  yesNo: 'No',
                                  background: nobackgroundColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          (communicationDevice == true)
                              ? Column(
                                  children: [
                                    communicationComponents.when(
                                      data: (components) {
                                        return selectCommunicationComponents(
                                          context: context,
                                          applicationId: widget.applicationId,
                                          component: widget.component,
                                          ref: ref,
                                          components: components,
                                        );
                                      },
                                      error: (error, stacktrace) =>
                                          Text(error.toString()),
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: ConfirmSelectionButton(
                                        onPressed: () {
                                          updateSelectedStatus(true);
                                          updateComponentCost();
                                          updateApplicationQuotation();
                                        },
                                        message: 'Confirm Selection',
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      )
                    : selectedTrue(
                        ref: ref,
                        arguments: arguments,
                        componentsModel: component,
                        component: widget.component,
                        applicationId: widget.applicationId,
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

Widget selectCommunicationComponents({
  required BuildContext context,
  required String applicationId,
  required String component,
  required WidgetRef ref,
  required List<CommunicationComponentsModel> components,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Please select all the components required for the installation',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Component',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            Text(
              'Price per unit (KES)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
      SizedBox(
        height: 100,
        child: ListView.builder(
          itemCount: components.length,
          itemBuilder: ((context, index) {
            final comp = components[index];
            return InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: FractionallySizedBox(
                          heightFactor: 0.3,
                          child: CommunicationComponentsWidget(
                            comp: comp,
                            applicationId: applicationId,
                            component: component,
                          ),
                        ),
                      );
                    });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                height: 40,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(10),
                  color: (comp.isSelected == false
                      ? Colors.white
                      : Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comp.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      comp.price.toString(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );
}

Widget componentNotRequired({
  required BuildContext context,
  required String applicationId,
  required String component,
  required WidgetRef ref,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          component,
          selected,
          applicationId,
        );
  }

  void updateRequiredStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
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
        },
        message: 'Edit Selection',
      ),
    ],
  );
}

Widget selectedTrue({
  required WidgetRef ref,
  required List<String> arguments,
  required ComponentsModel componentsModel,
  required String component,
  required String applicationId,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
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

  final selectedComponents =
      ref.watch(getSelectedCommunicationComponentsStreamProvider(arguments));
  return Column(children: [
    const Text(
      'You have selected the following communication components as part of the installation',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 15),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Component (units)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
          Text(
            'Cost (KES)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          )
        ],
      ),
    ),
    const SizedBox(height: 10),
    selectedComponents.when(
      data: (components) {
        return SizedBox(
          height: 100,
          child: ListView.builder(
              itemCount: components.length,
              itemBuilder: ((context, index) {
                final comp = components[index];
                final name = comp.name;
                final splitName = name.split(' ');
                final lastName = splitName.last;

                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (lastName == 'cable')
                          ? Text(
                              '${comp.name} (${comp.length}m)',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          : Text(
                              '${comp.name} (${comp.quantity} units)',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                      Text(
                        comp.cost.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              })),
        );
      },
      error: (error, stacktrace) => Text(error.toString()),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    ),
    const SizedBox(height: 20),
    Text(
      'Total cost: KES ${componentsModel.cost}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    const SizedBox(height: 20),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ConfirmSelectionButton(
        onPressed: () {
          updateSelectedStatus(false);
          updateApplicationQuotation();
        },
        message: 'Edit Selection',
      ),
    ),
  ]);
}
