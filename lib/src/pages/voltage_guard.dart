// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/models/voltage_guard_model.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/controller/voltage_guards_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class VoltageGuard extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const VoltageGuard({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VoltageGuardState();
}

class _VoltageGuardState extends ConsumerState<VoltageGuard> {
  late List<String> arguments;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // saveBoxesToApplication();
    });
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

  void updateComponentCost() async {
    int cost = 0;
    final guards = await ref
        .read(voltageGuardsControllerProvider)
        .getFutureSelectedVoltageGuards(
          widget.applicationId,
          widget.component,
        );
    for (VoltagGuardModel guard in guards) {
      cost = cost + guard.cost;
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
    final guards = ref.watch(getVoltageGuardsStreamProvider(arguments));
    final selectedGuards =
        ref.watch(getSelectedVoltageGuardsStreamProvider(arguments));
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
                      const SizedBox(height: 15),
                      guards.when(
                        data: (guards) {
                          return selectGuards(
                            guards: guards,
                            applicationId: widget.applicationId,
                            component: widget.component,
                            context: context,
                            ref: ref,
                          );
                        },
                        error: (error, stacktrace) => Text(error.toString()),
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
                            updateApplicationQuotation();
                          },
                          message: 'Confirm Selection',
                        ),
                      ),
                    ],
                  )
                : selectedGuards.when(
                    data: (guards) {
                      return selectedTrue(
                        applicationId: widget.applicationId,
                        component: widget.component,
                        ref: ref,
                        arguments: arguments,
                        context: context,
                        componentsModel: component,
                        guards: guards,
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

Widget selectGuards({
  required List<VoltagGuardModel> guards,
  required String applicationId,
  required String component,
  required BuildContext context,
  required WidgetRef ref,
}) {
  void updateSelectedVoltageGuardStatus(bool selected, String guard) {
    ref.watch(voltageGuardsControllerProvider).updateVoltageGuardSelectedStatus(
          applicationId: applicationId,
          component: component,
          guard: guard,
          selected: selected,
        );
  }

  final size = MediaQuery.of(context).size;
  return Column(
    children: [
      const Text(
        'Based on the client\'s grid connection, choose the appropriate voltage guard',
        style: TextStyle(
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
              'Guard',
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
            itemCount: guards.length,
            itemBuilder: (context, index) {
              final guard = guards[index];
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    updateSelectedVoltageGuardStatus(true, guards[0].name);
                    updateSelectedVoltageGuardStatus(false, guards[1].name);
                  }
                  if (index == 1) {
                    updateSelectedVoltageGuardStatus(false, guards[0].name);
                    updateSelectedVoltageGuardStatus(true, guards[1].name);
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (guard.isSelected == false
                        ? Colors.white
                        : Colors.grey.withOpacity(0.2)),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          guard.name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        guard.cost.toString(),
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

Widget selectedTrue({
  required String applicationId,
  required String component,
  required WidgetRef ref,
  required List<String> arguments,
  required BuildContext context,
  required ComponentsModel componentsModel,
  required List<VoltagGuardModel> guards,
}) {
  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          component,
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
      const Text(
        'You have selected the following voltage guard as part of the installation',
        style: TextStyle(
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
              'Guard',
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
          itemCount: guards.length,
          itemBuilder: ((context, index) {
            final guard = guards[index];
            return SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '${guard.name})',
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Text(
                      guard.cost.toString(),
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
      const SizedBox(height: 40),
      Align(
        alignment: Alignment.topCenter,
        child: ConfirmSelectionButton(
          onPressed: () {
            updateComponentCost(0);
            updateSelectedStatus(false);
            updateApplicationQuotation();
          },
          message: 'Edit Selection',
        ),
      ),
    ]),
  );
}
