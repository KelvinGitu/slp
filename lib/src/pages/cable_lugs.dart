// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/cable_lugs_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/controller/cable_lugs_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/cable_lugs_widget.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class CableLugs extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const CableLugs({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CableLugsState();
}

class _CableLugsState extends ConsumerState<CableLugs> {

  late List<String> arguments;

  late List<String> batteryArguments;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    batteryArguments = [widget.applicationId, 'Batteries'];

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
    final lugs = await ref
        .read(cableLugsControllerProvider)
        .getFutureSelectedLugs(widget.applicationId, widget.component);
    if (lugs.isNotEmpty) {
      for (CableLugsModel lug in lugs) {
        cost = cost + lug.cost;
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

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
    final cableLugs = ref.watch(getLugsStreamProvider(arguments));
    final selectedLugs = ref.watch(getSelectedLugsStreamProvider(arguments));

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
            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                      cableLugs.when(
                        data: (lugs) {
                          return selectCableLugs(
                            context: context,
                            applicationId: widget.applicationId,
                            component: widget.component,
                            ref: ref,
                            lugs: lugs,
                          );
                        },
                        error: (error, stacktrace) => Text(error.toString()),
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
                : selectedLugs.when(
                    data: (lugs) {
                      return selectedTrue(
                        ref: ref,
                        arguments: arguments,
                        componentsModel: component,
                        component: widget.component,
                        applicationId: widget.applicationId,
                        lugs: lugs,
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

Widget selectCableLugs({
  required BuildContext context,
  required String applicationId,
  required String component,
  required WidgetRef ref,
  required List<CableLugsModel> lugs,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Please select all the cable lugs required for the installation',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 15),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cable Lug',
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
          itemCount: lugs.length,
          itemBuilder: ((context, index) {
            final lug = lugs[index];
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
                          child: CableLugsWidget(
                            lug: lug,
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
                height: 30,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(10),
                  color: (lug.isSelected == false
                      ? Colors.white
                      : Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lug.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      lug.price.toString(),
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

Widget selectedTrue({
  required WidgetRef ref,
  required List<String> arguments,
  required ComponentsModel componentsModel,
  required String component,
  required String applicationId,
  required List<CableLugsModel> lugs,
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

  return Column(children: [
    const Text(
      'You have selected the following cable lugs as part of the installation',
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
    SizedBox(
      height: 100,
      child: ListView.builder(
          itemCount: lugs.length,
          itemBuilder: ((context, index) {
            final lug = lugs[index];

            return Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${lug.name} (${lug.quantity} units)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    lug.cost.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          })),
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
          updateSelectedStatus(false);
          updateApplicationQuotation();
        },
        message: 'Edit Selection',
      ),
    ),
  ]);
}
