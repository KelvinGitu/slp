// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_cable_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/battery_cables_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/battery_cable_widget.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:solar_project/src/widgets/yes_no_button.dart';

class BatteryCable extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const BatteryCable({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BatteryCableState();
}

class _BatteryCableState extends ConsumerState<BatteryCable> {
  late List<String> arguments;

  bool validate = false;

  bool storageDevice = false;

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
    final cables = await ref
        .read(batteryCablesControllerProvider)
        .getFutureSelectedBatteryCables(widget.applicationId, widget.component);
    if (cables.isNotEmpty) {
      for (BatteryCableModel cable in cables) {
        cost = cost + cable.cost;
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
    final batteryCab = ref.watch(getBatteryCablesStreamProvider(arguments));

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
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Is your client interested in a power storage device?',
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
                                      storageDevice = true;
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
                                      storageDevice = false;
                                      nobackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                      yesbackgroundColor = Colors.white;
                                    });
                                    updateRequiredStatus(false);
                                  },
                                  yesNo: 'No',
                                  background: nobackgroundColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          (storageDevice == true)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    batteryCab.when(
                                      data: (cables) {
                                        return batteryCables(
                                          cables: cables,
                                          applicationId: widget.applicationId,
                                          component: widget.component,
                                        );
                                      },
                                      error: (error, stacktrace) =>
                                          Text(error.toString()),
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: ConfirmSelectionButton(
                                        onPressed: () {
                                          updateComponentCost();
                                          updateSelectedStatus(true);
                                          updateApplicationQuotation();
                                        },
                                        message: 'Confirm Selection',
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          const SizedBox(height: 20),
                        ],
                      )
                    : selectedTrue(
                        ref: ref,
                        arguments: arguments,
                        componentsModel: component,
                        component: widget.component,
                        applicationId: widget.applicationId),
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

Widget batteryCables({
  required List<BatteryCableModel> cables,
  required String applicationId,
  required String component,
}) {
  return SizedBox(
    height: 350,
    child: Column(
      children: [
        const Text(
          'Please select all the cables required for the installation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cross Section',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              Text(
                'Cost per m (KES)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cables.length,
            itemBuilder: ((context, index) {
              final cable = cables[index];
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
                            heightFactor: 0.34,
                            child: BatteryCableWidget(
                              cable: cable,
                              applicationId: applicationId,
                              component: component,
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  height: 30,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(10),
                    color: (cable.isSelected == false
                        ? Colors.white
                        : Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cable.crossSection}\u00b2',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        cable.price.toString(),
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
          updateApplicationQuotation();
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

  final selectedCables =
      ref.watch(getSelectedBatteryCablesStreamProvider(arguments));
  return Column(children: [
    const Text(
      'You have selected the following battery cables as part of the installation',
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
            'Cross Section (length)',
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
    selectedCables.when(
      data: (cables) {
        return SizedBox(
          height: 200,
          child: ListView.builder(
              itemCount: cables.length,
              itemBuilder: ((context, index) {
                final cable = cables[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cable.crossSection}\u00b2  (${cable.length}m)',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        cable.cost.toString(),
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
    const SizedBox(height: 40),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ConfirmSelectionButton(
        onPressed: () {
          updateApplicationQuotation();
          updateSelectedStatus(false);
        },
        message: 'Edit Selection',
      ),
    ),
  ]);
}
