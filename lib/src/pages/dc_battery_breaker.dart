// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_breaker_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/battery_breaker_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class BatteryBreaker extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const BatteryBreaker({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BatteryBreakerState();
}

class _BatteryBreakerState extends ConsumerState<BatteryBreaker> {
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

  void updateBatteryFuseRequiredStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          'Battery Fuse',
          selected,
          widget.applicationId,
        );
  }

  void updateBatteryFuseSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          'Battery Fuse',
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost() async {
    int cost = 0;
    final breakers = await ref
        .read(batteryBreakerControllerProvider)
        .getFutureSelectedBatteryBreakers(
          widget.applicationId,
          widget.component,
        );
    for (DCBatteryBreakerModel breaker in breakers) {
      cost = cost + breaker.cost;
      ref.read(solarControllerProvider).updateApplicationComponentCost(
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
    final breakers = ref.watch(getBatteryBreakersStreamProvider(arguments));
    final selectedBreakers =
        ref.watch(getSelectedBatteryBreakersStreamProvider(arguments));

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
                          breakers.when(
                            data: (breakers) {
                              return selectBreakers(
                                breakers: breakers,
                                applicationId: widget.applicationId,
                                component: widget.component,
                                context: context,
                                ref: ref,
                              );
                            },
                            error: (error, stacktrace) =>
                                Text(error.toString()),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.topCenter,
                            child: ConfirmSelectionButton(
                              onPressed: () {
                                updateComponentCost();
                                updateSelectedStatus(true);
                                updateBatteryFuseRequiredStatus(false);
                                updateBatteryFuseSelectedStatus(false);
                                updateApplicationQuotation();
                              },
                              message: 'Confirm Selection',
                            ),
                          ),
                        ],
                      )
                    : selectedBreakers.when(
                        data: (breakers) {
                          return selectedTrue(
                            applicationId: widget.applicationId,
                            component: widget.component,
                            ref: ref,
                            arguments: arguments,
                            context: context,
                            componentsModel: component,
                            breakers: breakers,
                          );
                        },
                        error: (error, stacktrace) => Text(error.toString()),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
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

Widget selectBreakers({
  required List<DCBatteryBreakerModel> breakers,
  required String applicationId,
  required String component,
  required BuildContext context,
  required WidgetRef ref,
}) {
  void updateSelectedBatteryBreakersStatus(bool selected, String breaker) {
    ref
        .watch(batteryBreakerControllerProvider)
        .updateBatteryBreakersSelectedStatus(
          applicationId: applicationId,
          component: component,
          breaker: breaker,
          selected: selected,
        );
  }

  final size = MediaQuery.of(context).size;
  return Column(
    children: [
      Text(
        'Based on the client\'s solar panel connection, choose the appropriate $component',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 20),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Breaker',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            Text(
              'Cost (KES)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
      SizedBox(
        height: size.height * 0.15,
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: breakers.length,
            itemBuilder: (context, index) {
              final breaker = breakers[index];
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    updateSelectedBatteryBreakersStatus(true, breakers[0].name);
                    updateSelectedBatteryBreakersStatus(
                        false, breakers[1].name);
                  }
                  if (index == 1) {
                    updateSelectedBatteryBreakersStatus(
                        false, breakers[0].name);
                    updateSelectedBatteryBreakersStatus(true, breakers[1].name);
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (breaker.isSelected == false
                        ? Colors.white
                        : Colors.grey.withOpacity(0.2)),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        breaker.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        breaker.cost.toString(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              );
            }),
      )
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
  required String applicationId,
  required String component,
  required WidgetRef ref,
  required List<String> arguments,
  required BuildContext context,
  required ComponentsModel componentsModel,
  required List<DCBatteryBreakerModel> breakers,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          component,
          selected,
          applicationId,
        );
  }

  void updateBreakerFuseRequiredStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          'Battery Fuse',
          selected,
          applicationId,
        );
  }

  void updateComponentCost(int cost) async {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
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

  final size = MediaQuery.of(context).size;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(children: [
      Text(
        'You have selected the following ${componentsModel.name} as part of the installation',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 20),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Breaker',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            Text(
              'Cost (KES)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
      SizedBox(
        height: size.height * 0.1,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: breakers.length,
          itemBuilder: ((context, index) {
            final breaker = breakers[index];
            return SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      breaker.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      breaker.cost.toString(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        'Total cost: KES ${componentsModel.cost}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 20),
      const SizedBox(height: 30),
      Align(
        alignment: Alignment.topCenter,
        child: ConfirmSelectionButton(
          onPressed: () {
            updateComponentCost(0);
            updateSelectedStatus(false);
            updateBreakerFuseRequiredStatus(true);
            updateApplicationQuotation();
          },
          message: 'Edit Selection',
        ),
      ),
    ]),
  );
}
