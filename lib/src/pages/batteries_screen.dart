// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  bool storageDevice = false;

  bool validate = false;

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
    ref.watch(solarControllerProvider).updateApplicationSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) {
    ref.watch(solarControllerProvider).updateComponentCost(
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

  void updateComponentCapacity(int capacity) {
    ref.watch(solarControllerProvider).updateComponentCapacity(
          widget.component,
          capacity,
          widget.applicationId,
        );
  }

  void saveBatteryCapacitiesToApplication() {
    ref.watch(solarControllerProvider).saveBatteryCapacityToApplication(
          applicationId: widget.applicationId,
          component: widget.component,
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: (component.isSelected == false)
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 25,
                              width: 120,
                              child: OutlinedButton(
                                onPressed: () {
                                  saveBatteryCapacitiesToApplication();
                                  setState(() {
                                    storageDevice = true;
                                    yesbackgroundColor =
                                        Colors.purple.withOpacity(0.4);
                                    nobackgroundColor = Colors.white;
                                  });
                                },
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
                                  setState(() {
                                    storageDevice = false;
                                    updateSelectedStatus(true);
                                    updateComponentCapacity(0);
                                    updateComponentCost(0);
                                    updateApplicationQuotation();
                                    nobackgroundColor =
                                        Colors.purple.withOpacity(0.4);
                                    yesbackgroundColor = Colors.white;
                                  });
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
                      ),
                      const SizedBox(height: 20),
                      (storageDevice == true)
                          ? const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Measures of determination',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                      const SizedBox(height: 10),
                      (storageDevice == true)
                          ? const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'What is the capacity required?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                              data: (batteryCapacity) {
                                return SizedBox(
                                  height: 200,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Recommended capacities',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 10),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Capacity',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                            Text(
                                              'Cost (KES)',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40),
                                          itemCount: batteryCapacity.length,
                                          itemBuilder: (context, index) {
                                            final battery =
                                                batteryCapacity[index];
                                            final num = int.parse(
                                                capacityController.text);
                                            return (battery.capacity >= num)
                                                ? InkWell(
                                                    onTap: () {
                                                      updateComponentCapacity(
                                                          battery.capacity);
                                                      updateComponentCost(
                                                          battery.cost);
                                                      setState(() {
                                                        capacitySelected = true;
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 30,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${battery.capacity}Ah",
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Text(battery.cost
                                                              .toString()),
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
                      const SizedBox(height: 10),
                      (storageDevice == true)
                          ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: ConfirmSelectionButton(
                                onPressed: () {
                                  setState(() {
                                    validate = capacityController.text.isEmpty;
                                  });
                                  (validate == true)
                                      ? null
                                      : updateSelectedStatus(true);
                            
                                  (validate == true)
                                      ? null
                                      : updateApplicationQuotation();
                                },
                                message: 'Confirm Selection',
                              ),
                          )
                          : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: ConfirmSelectionButton(
                                onPressed: () {
                                  updateApplicationQuotation();
                                  updateSelectedStatus(true);
                                  Navigator.pop(context);
                                },
                                message: 'Exit',
                              ),
                          )
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            'Preferred battery capacity: ${component.capacity}Ah',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Total cost: KES ${component.cost}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ConfirmSelectionButton(
                          onPressed: () {
                            updateSelectedStatus(false);
                          },
                          message: 'Edit selection',
                        ),
                      ],
                    ),
                  ));
      },
      error: (error, stacktrace) => Text(error.toString()),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
