// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_cable_model.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/battery_cable_widget.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      saveBatteryCablesToApplication();
    });
    super.initState();
  }

  void saveBatteryCablesToApplication() {
    ref.read(solarControllerProvider).saveBatteryCablesToApplication(
          applicationId: widget.applicationId,
          component: widget.component,
        );
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost() async {
    int cost = 0;
    final cables = await ref
        .read(solarControllerProvider)
        .getFutureSelectedBatteryCables(widget.applicationId, widget.component);
    for (BatteryCableModel cable in cables) {
      cost = cost + cable.cost;
      ref.watch(solarControllerProvider).updateComponentCost(
            widget.component,
            cost,
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
    ref.watch(solarControllerProvider).updateComponentLength(
          widget.component,
          length * 2,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    final batteryCables = ref.watch(getBatteryCablesStreamProvider(arguments));

    final selectedCables = ref.watch(getSelectedBatteryCablesStreamProvider(arguments));

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
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Measures of determination',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 15),
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
                                batteryCables.when(
                                  data: (cables) {
                                    return SizedBox(
                                      height: 350,
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Please select all the cables required for the installation',
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Cross Section',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  'Cost per m (KES)',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40),
                                              itemCount: cables.length,
                                              itemBuilder: ((context, index) {
                                                final cable = cables[index];
                                                return InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                        builder: (context) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom),
                                                            child:
                                                                FractionallySizedBox(
                                                              heightFactor: 0.3,
                                                              child:
                                                                  BatteryCableWidget(
                                                                cable: cable,
                                                                applicationId:
                                                                    widget
                                                                        .applicationId,
                                                                component: widget
                                                                    .component,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          (cable.isSelected ==
                                                                  false
                                                              ? Colors.white
                                                              : Colors.grey
                                                                  .withOpacity(
                                                                      0.4)),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${cable.crossSection}\u00b2',
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                        Text(
                                                          cable.price
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
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
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: ConfirmSelectionButton(
                                onPressed: () {
                                  updateApplicationQuotation();
                                  updateSelectedStatus(true);
                                  Navigator.pop(context);
                                },
                                message: 'Exit',
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Column(children: [
                    const Text(
                      'You have selected the following battery cables as part of the installation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cross Section',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w300),
                          ),
                          Text(
                            'Cost per m (KES)',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w300),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              itemCount: cables.length,
                              itemBuilder: ((context, index) {
                                final cable = cables[index];
                                return SizedBox(
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${cable.crossSection}\u00b2  (${cable.length}m)',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        cable.cost.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
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
                      'Total cost: KES ${component.cost}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ConfirmSelectionButton(
                        onPressed: () {
                          updateApplicationQuotation();
                          updateSelectedStatus(false);
                        },
                        message: 'Edit Selectioon',
                      ),
                    ),
                  ]),
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
