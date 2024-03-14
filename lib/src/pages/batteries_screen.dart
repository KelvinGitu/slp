// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_capacity_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/battery_capacities_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class BatteriesScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const BatteriesScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BatteriesScreenState();
}

class _BatteriesScreenState extends ConsumerState<BatteriesScreen> {
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController batteriesController = TextEditingController();

  bool storageDevice = false;

  bool validate = false;

  bool validate2 = false;

  late List<String> arguments;

  bool showCapacity = false;

  bool capacitySelected = false;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];

    super.initState();
  }

  Color yesbackgroundColor = Colors.white;
  Color nobackgroundColor = Colors.white;

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          widget.component,
          required,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          widget.component,
          cost * int.parse(batteriesController.text),
          widget.applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          widget.applicationId,
        );
  }

  void updateComponentCapacity(int capacity) {
    ref.watch(solarControllerProvider).updateApplicationComponentCapacity(
          widget.component,
          capacity,
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
    final batteryCapacity =
        ref.watch(getBatteryCapacityStreamProvider(arguments));
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
          body: (component.isRequired == false && component.isSelected == false)
              ? notRequired(
                  applicationId: widget.applicationId,
                  component: widget.component,
                  ref: ref,
                )
              : (component.isSelected == false)
                  ? ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        yesNo(
                          applicationId: widget.applicationId,
                          component: widget.component,
                          ref: ref,
                          yesbackgroundColor: yesbackgroundColor,
                          nobackgroundColor: nobackgroundColor,
                          onYesPressed: () {
                            setState(() {
                              storageDevice = true;
                              yesbackgroundColor =
                                  Colors.purple.withOpacity(0.4);
                              nobackgroundColor = Colors.white;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        (storageDevice == true)
                            ? const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Measures of determination',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 10),
                        (storageDevice == true)
                            ? Container(
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
                              )
                            : Container(),
                        const SizedBox(height: 15),
                        (storageDevice == true)
                            ? Column(
                                children: [
                                  const SizedBox(height: 15),
                                  const Text(
                                    'How many batteries does the installation require?',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 15),
                                  TextField(
                                    controller: batteriesController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    decoration: InputDecoration(
                                      hintText: 'No. of batteries',
                                      hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withOpacity(0.6)),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.2),
                                      errorText: validate2
                                          ? "Value Can't Be Empty"
                                          : null,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        const SizedBox(height: 20),
                        (storageDevice == true)
                            ? const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'What is the capacity required?',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 10),
                        (storageDevice == true)
                            ? TextField(
                                controller: capacityController,
                                onChanged: (value) {
                                  setState(() {
                                    showCapacity = true;
                                    capacitySelected = false;
                                  });
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                decoration: InputDecoration(
                                  hintText: 'Capacity in Ah',
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.6)),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.2),
                                  errorText:
                                      validate ? "Value Can't Be Empty" : null,
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 15),
                        (showCapacity == true &&
                                storageDevice == true &&
                                capacityController.text.isEmpty == false &&
                                capacitySelected == false)
                            ? batteryCapacity.when(
                                data: (capacities) {
                                  return selectBatteryCapacities(
                                    capacities: capacities,
                                    applicationId: widget.applicationId,
                                    component: widget.component,
                                    ref: ref,
                                    capacityController: capacityController,
                                    validate1: validate,
                                    validate2: validate2,
                                    batteriesController: batteriesController,
                                  );
                                },
                                error: (error, stacktrace) =>
                                    Text(error.toString()),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : (capacitySelected == true)
                                ? Text(
                                    'Preffered capacity: ${component.capacity}Ah',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  )
                                : Container(),
                        (storageDevice == true)
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: ConfirmSelectionButton(
                                  onPressed: () {
                                    setState(() {
                                      validate =
                                          capacityController.text.isEmpty;
                                      validate2 =
                                          batteriesController.text.isEmpty;
                                    });

                                    (validate == true || validate2 == true)
                                        ? null
                                        : updateComponentQuanity(int.parse(
                                            batteriesController.text));
                                    (validate == true || validate2 == true)
                                        ? null
                                        : updateSelectedStatus(true);

                                    (validate == true || validate2 == true)
                                        ? null
                                        : updateApplicationQuotation();
                                  },
                                  message: 'Confirm Selection',
                                ),
                              )
                            : Container(),
                      ],
                    )
                  : selectedTrue(
                      context: context,
                      componentsModel: component,
                      applicationId: widget.applicationId,
                      component: widget.component,
                      ref: ref,
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

Widget yesNo({
  required String applicationId,
  required String component,
  required WidgetRef ref,
  required VoidCallback onYesPressed,
  required Color yesbackgroundColor,
  required Color nobackgroundColor,
}) {
  void updateComponentCost() {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          component,
          0,
          applicationId,
        );
  }

   void updateRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          component,
          required,
          applicationId,
        );
  }

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

  void updateComponentCapacity() {
    ref.watch(solarControllerProvider).updateApplicationComponentCapacity(
          component,
          0,
          applicationId,
        );
  }

  void updateComponentQuanity() {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          component,
          0,
          applicationId,
        );
  }


  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 25,
          width: 120,
          child: OutlinedButton(
            onPressed: onYesPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              backgroundColor: yesbackgroundColor,
            ),
            child: const Text('Yes'),
          ),
        ),
        SizedBox(
          height: 25,
          width: 120,
          child: OutlinedButton(
            onPressed: () {
              updateSelectedStatus(false);
                updateRequiredStatus(false);
                updateComponentCost();
                updateComponentCapacity();
                updateComponentQuanity();
                updateApplicationQuotation();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              backgroundColor: nobackgroundColor,
            ),
            child: const Text('No'),
          ),
        )
      ],
    ),
  );
}

Widget selectBatteryCapacities({
  required List<BatteryCapacityModel> capacities,
  required String applicationId,
  required String component,
  required WidgetRef ref,
  required TextEditingController capacityController,
  required TextEditingController batteriesController,
  required bool validate1,
  required bool validate2,
}) {
  void updateSelectedBatteryCapacityStatus(bool selected, int capacity) {
    ref
        .watch(batteryCapacitiesControllerProvider)
        .updateBatteryCapacitySelectedStatus(
          applicationId: applicationId,
          component: component,
          capacity: capacity,
          selected: selected,
        );
  }

  void updateComponentCost(int cost) {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          component,
          cost * int.parse(batteriesController.text),
          applicationId,
        );
  }

  void updateComponentCapacity(int capacity) {
    ref.watch(solarControllerProvider).updateApplicationComponentCapacity(
          component,
          capacity,
          applicationId,
        );
  }

  return SizedBox(
    height: 200,
    child: Column(
      children: [
        const Text(
          'Recommended capacities',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capacity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              Text(
                'Cost (KES)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: capacities.length,
            itemBuilder: (context, index) {
              final capacity = capacities[index];
              final num = int.parse(capacityController.text);
              return (capacity.capacity >= num)
                  ? InkWell(
                      onTap: () {
                        (validate2 == true)
                            ? null
                            : updateComponentCost(capacities[index].cost);
                        updateComponentCapacity(capacities[index].capacity);
                        updateSelectedBatteryCapacityStatus(
                            true, capacities[index].capacity);
                        if (index == 0) {
                          updateSelectedBatteryCapacityStatus(
                              true, capacities[0].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[1].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[2].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[3].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[4].capacity);
                        }
                        if (index == 1) {
                          updateSelectedBatteryCapacityStatus(
                              true, capacities[1].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[0].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[2].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[3].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[4].capacity);
                        }
                        if (index == 2) {
                          updateSelectedBatteryCapacityStatus(
                              true, capacities[2].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[0].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[1].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[3].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[4].capacity);
                        }
                        if (index == 3) {
                          updateSelectedBatteryCapacityStatus(
                              true, capacities[3].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[0].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[1].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[2].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[4].capacity);
                        }
                        if (index == 4) {
                          updateSelectedBatteryCapacityStatus(
                              true, capacities[4].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[0].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[1].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[2].capacity);
                          updateSelectedBatteryCapacityStatus(
                              false, capacities[3].capacity);
                        }
                      },
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: (capacity.isSelected == false
                              ? Colors.white
                              : Colors.grey.withOpacity(0.2)),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${capacity.capacity}Ah",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(capacity.cost.toString()),
                          ],
                        ),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    ),
  );
}

Widget notRequired({
  required String applicationId,
  required String component,
  required WidgetRef ref,
}) {
  void updateRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          component,
          required,
          applicationId,
        );
  }

  void updateComponentCost() {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          component,
          0,
          applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          applicationId,
        );
  }

  void updateComponentCapacity() {
    ref.watch(solarControllerProvider).updateApplicationComponentCapacity(
          component,
          0,
          applicationId,
        );
  }

  void updateComponentQuanity() {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          component,
          0,
          applicationId,
        );
  }

  return Column(
    children: [
      Container(),
      const Text(
        'Batteries are not required for this application',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 40),
      ConfirmSelectionButton(
          onPressed: () {
            updateRequiredStatus(true);
            updateComponentCost();
            updateComponentCapacity();
            updateComponentQuanity();
            updateApplicationQuotation();
          },
          message: 'Edit Selection'),
    ],
  );
}

Widget selectedTrue({
  required BuildContext context,
  required ComponentsModel componentsModel,
  required WidgetRef ref,
  required String applicationId,
  required String component,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          component,
          selected,
          applicationId,
        );
  }

  void updateComponentCost() {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
          component,
          0,
          applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          applicationId,
        );
  }

  void updateComponentCapacity() {
    ref.watch(solarControllerProvider).updateApplicationComponentCapacity(
          component,
          0,
          applicationId,
        );
  }

  void updateComponentQuanity() {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          component,
          0,
          applicationId,
        );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        Container(),
        Text(
          'Number of batteries: ${componentsModel.quantity}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Preferred battery capacity: ${componentsModel.capacity}Ah',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Total cost: KES ${componentsModel.cost}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        ConfirmSelectionButton(
          onPressed: () {
            updateSelectedStatus(false);
            updateComponentCost();
            updateComponentCapacity();
            updateComponentQuanity();
            updateApplicationQuotation();
          },
          message: 'Edit selection',
        ),
      ],
    ),
  );
}
