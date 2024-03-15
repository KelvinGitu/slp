// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:solar_project/src/widgets/yes_no_button.dart';

class Miscellaneous extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const Miscellaneous({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MiscellaneousState();
}

class _MiscellaneousState extends ConsumerState<Miscellaneous> {
  final TextEditingController miscellaneousController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  bool validate = false;

  bool validate2 = false;

  bool isRequired = false;

  late List<String> arguments;

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

  void updateComponentCost(int cost) async {
    ref.read(solarControllerProvider).updateApplicationComponentCost(
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

  void updateComponentQuantity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          widget.component,
          quantity,
          widget.applicationId,
        );
  }

  void updateComponentMeasurement(String measurement) {
    ref.watch(solarControllerProvider).updateApplicationComponentMeasurement(
          widget.component,
          measurement,
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final component =
        ref.watch(getApplicationComponentStreamProvider(arguments));
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
                    ? ListView(
                        children: [
                          const Text(
                            'Are there any miscellaneous costs that should be included in the application?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                YesNoButton(
                                  onPressed: () {
                                    setState(() {
                                      isRequired = true;
                                      yesbackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                      nobackgroundColor = Colors.white;
                                    });
                                    // updateSelectedStatus(true);
                                    // updateApplicationQuotation();
                                  },
                                  yesNo: 'Yes',
                                  background: yesbackgroundColor,
                                ),
                                YesNoButton(
                                  onPressed: () {
                                    setState(() {
                                      isRequired = false;
                                      yesbackgroundColor = Colors.white;
                                      nobackgroundColor =
                                          Colors.purple.withOpacity(0.4);
                                    });
                                    // component.measurement.clear();
                                    // print(component.measurement.length);
                                    updateSelectedStatus(false);
                                    updateRequiredStatus(false);
                                    updateApplicationQuotation();
                                  },
                                  yesNo: 'No',
                                  background: nobackgroundColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          (isRequired == true)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Include the description below',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextField(
                                      controller: miscellaneousController,
                                      minLines: 1,
                                      maxLines: 5,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        hintText: 'Description',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                        border: InputBorder.none,
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.2),
                                        errorText: validate
                                            ? "Value Can't Be Empty"
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'What is the total cost?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextField(
                                      controller: costController,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(),
                                      decoration: InputDecoration(
                                        hintText: 'Cost in KES',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                        border: InputBorder.none,
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.2),
                                        errorText: validate2
                                            ? "Value Can't Be Empty"
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: ConfirmSelectionButton(
                                        onPressed: () {
                                          setState(() {
                                            validate = miscellaneousController
                                                .text.isEmpty;
                                            validate2 =
                                                costController.text.isEmpty;
                                          });
                                          (validate == true ||
                                                  validate2 == true)
                                              ? null
                                              : updateComponentCost(int.parse(
                                                  costController.text));
                                          (validate == true ||
                                                  validate2 == true)
                                              ? null
                                              : updateComponentMeasurement(
                                                  miscellaneousController.text);
                                          (validate == true ||
                                                  validate2 == true)
                                              ? null
                                              : updateSelectedStatus(true);
                                          (validate == true ||
                                                  validate2 == true)
                                              ? null
                                              : updateApplicationQuotation();
                                        },
                                        message: 'Confirm Selection',
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      )
                    : Column(
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Description',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
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
                          const SizedBox(height: 20),
                          Text(
                            'Total cost: KES ${component.cost}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ConfirmSelectionButton(
                            onPressed: () {
                              // component.measurement.clear();

                              updateSelectedStatus(false);
                            },
                            message: 'Edit selection',
                          ),
                        ],
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
      Container(),
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
