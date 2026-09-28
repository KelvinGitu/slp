// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/models/inverter_module_model.dart';
import 'package:solar_project/src/controller/inverter_module_controller.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class InverterModuleScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const InverterModuleScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InverterModelScreenState();
}

class _InverterModelScreenState extends ConsumerState<InverterModuleScreen> {
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
    final modules = await ref
        .read(inverterModuleControllerProvider)
        .getFutureSelectedModules(
          widget.applicationId,
          widget.component,
        );
    for (InverterModuleModel module in modules) {
      cost = cost + module.cost;
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
          1,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));

    final modules = ref.watch(getModulesStreamProvider(arguments));
    final selectedModules =
        ref.watch(getSelectedModulesStreamProvider(arguments));
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: (component.isSelected == false)
                ? Column(
                    children: [
                      const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Measures of determination',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )),
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
                            return SizedBox(
                                height: 30,
                                child: Text(component.measurement[index]));
                          }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      modules.when(
                        data: (modules) {
                          return selectModules(
                            modules: modules,
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
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateComponentCost();
                          updateComponentQuanity(1);
                          updateSelectedStatus(true);
                          updateApplicationQuotation();
                        },
                        message: 'Confirm Selection',
                      ),
                    ],
                  )
                : selectedModules.when(
                    data: (modules) {
                      return selectedTrue(
                        applicationId: widget.applicationId,
                        component: widget.component,
                        ref: ref,
                        arguments: arguments,
                        context: context,
                        componentsModel: component,
                        modules: modules,
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

Widget selectModules({
  required List<InverterModuleModel> modules,
  required String applicationId,
  required String component,
  required BuildContext context,
  required WidgetRef ref,
}) {
  void updateModulesSelectedStatus(bool selected, String module) {
    ref.watch(inverterModuleControllerProvider).updateModulesSelectedStatus(
          applicationId: applicationId,
          component: component,
          module: module,
          selected: selected,
        );
  }

  final size = MediaQuery.of(context).size;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Choose the desired $component',
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
              'Inverter',
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
        height: size.height * 0.35,
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    updateModulesSelectedStatus(true, modules[0].name);
                    updateModulesSelectedStatus(false, modules[1].name);
                    updateModulesSelectedStatus(false, modules[2].name);
                    updateModulesSelectedStatus(false, modules[3].name);
                    updateModulesSelectedStatus(false, modules[4].name);
                  }
                  if (index == 1) {
                    updateModulesSelectedStatus(false, modules[0].name);
                    updateModulesSelectedStatus(true, modules[1].name);
                    updateModulesSelectedStatus(false, modules[2].name);
                    updateModulesSelectedStatus(false, modules[3].name);
                    updateModulesSelectedStatus(false, modules[4].name);
                  }
                  if (index == 2) {
                    updateModulesSelectedStatus(false, modules[0].name);
                    updateModulesSelectedStatus(false, modules[1].name);
                    updateModulesSelectedStatus(true, modules[2].name);
                    updateModulesSelectedStatus(false, modules[3].name);
                    updateModulesSelectedStatus(false, modules[4].name);
                  }
                  if (index == 3) {
                    updateModulesSelectedStatus(false, modules[0].name);
                    updateModulesSelectedStatus(false, modules[1].name);
                    updateModulesSelectedStatus(false, modules[2].name);
                    updateModulesSelectedStatus(true, modules[3].name);
                    updateModulesSelectedStatus(false, modules[4].name);
                  }
                  if (index == 4) {
                    updateModulesSelectedStatus(false, modules[0].name);
                    updateModulesSelectedStatus(false, modules[1].name);
                    updateModulesSelectedStatus(false, modules[2].name);
                    updateModulesSelectedStatus(false, modules[3].name);
                    updateModulesSelectedStatus(true, modules[4].name);
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: (module.isSelected == false
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
                        module.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        module.cost.toString(),
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
  required List<InverterModuleModel> modules,
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
  return Column(children: [
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
            'Inverter',
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
        itemCount: modules.length,
        itemBuilder: ((context, index) {
          final module = modules[index];
          return SizedBox(
            height: 45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    module.name,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    module.cost.toString(),
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
  ]);
}
