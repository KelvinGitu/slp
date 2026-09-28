// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/models/dc_breaker_enclosure_model.dart';
import 'package:solar_project/src/controller/dc_breaker_enclosures_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class DCBreakerEnclosure extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const DCBreakerEnclosure({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DCBreakerEnclosureState();
}

class _DCBreakerEnclosureState extends ConsumerState<DCBreakerEnclosure> {
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

  void updateComponentCost() async {
    int cost = 0;
    final enclosures = await ref
        .read(dcBreakerEnclosureControllerProvider)
        .getFutureSelectedBreakerEnclosures(
          widget.applicationId,
          widget.component,
        );
    for (DCBreakerEnclosureModel enclosure in enclosures) {
      cost = cost + enclosure.cost;
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
    final enclosures = ref.watch(getBreakerEnclosuresStreamProvider(arguments));
    final selectedEnclosures =
        ref.watch(getSelectedBreakerEnclosuresStreamProvider(arguments));

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
                      enclosures.when(
                        data: (enclosures) {
                          return selectBreakerEnclosures(
                            enclosures: enclosures,
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
                : selectedEnclosures.when(
                    data: (enclosures) {
                      return selectedTrue(
                        applicationId: widget.applicationId,
                        component: widget.component,
                        ref: ref,
                        arguments: arguments,
                        context: context,
                        componentsModel: component,
                        enclosures: enclosures,
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

Widget selectBreakerEnclosures({
  required List<DCBreakerEnclosureModel> enclosures,
  required String applicationId,
  required String component,
  required BuildContext context,
  required WidgetRef ref,
}) {
  void updateSelectedDCBreakerEnlosureStatus(bool selected, String enclosure) {
    ref
        .watch(dcBreakerEnclosureControllerProvider)
        .updateBreakerEnclosureSelectedStatus(
          applicationId: applicationId,
          component: component,
          enclosure: enclosure,
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
              'Enclosure',
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
            itemCount: enclosures.length,
            itemBuilder: (context, index) {
              final enclosure = enclosures[index];
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    updateSelectedDCBreakerEnlosureStatus(
                        true, enclosures[0].name);
                    updateSelectedDCBreakerEnlosureStatus(
                        false, enclosures[1].name);
                  }
                  if (index == 1) {
                    updateSelectedDCBreakerEnlosureStatus(
                        false, enclosures[0].name);
                    updateSelectedDCBreakerEnlosureStatus(
                        true, enclosures[1].name);
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: (enclosure.isSelected == false
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
                          enclosure.name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        enclosure.cost.toString(),
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
  required List<DCBreakerEnclosureModel> enclosures,
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
      Text(
        'You have selected the following ${componentsModel.name} for the installation',
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
              'Enclosure',
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
          itemCount: enclosures.length,
          itemBuilder: ((context, index) {
            final enclosure = enclosures[index];
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
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          enclosure.name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Text(
                      enclosure.cost.toString(),
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
            updateApplicationQuotation();
          },
          message: 'Edit Selection',
        ),
      ),
    ]),
  );
}
