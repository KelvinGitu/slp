// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:solar_project/src/widgets/yes_no_button.dart';

class ACContactorTriple extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const ACContactorTriple({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ACContactorTripleState();
}

class _ACContactorTripleState extends ConsumerState<ACContactorTriple> {
  bool validate = false;

  bool isGridConnected = false;

  late List<String> arguments;

  Color yesbackgroundColor = Colors.white;
  Color nobackgroundColor = Colors.white;

  @override
  void initState() {
    arguments = [widget.applicationId, widget.component];
    super.initState();
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationRequiredStatus(
          widget.component,
          required,
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

  void updateComponentLength(int length) {
    ref.watch(solarControllerProvider).updateComponentLength(
          widget.component,
          length * 2,
          widget.applicationId,
        );
  }

  void updateComponentQuanity() {
    ref.watch(solarControllerProvider).updateComponentQuantity(
          widget.component,
          1,
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
                      const Text(
                        'Is the client\'s home connected to the grid?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                                  isGridConnected = true;
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
                                  isGridConnected = false;
                                  nobackgroundColor =
                                      Colors.purple.withOpacity(0.4);
                                  yesbackgroundColor = Colors.white;
                                });
                              },
                              yesNo: 'No',
                              background: nobackgroundColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      (isGridConnected == true)
                          ? Column(
                              children: [
                                Text(
                                  'A ${component.name} will be added to the installation requirements',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                ConfirmSelectionButton(
                                  onPressed: () {
                                    updateRequiredStatus(true);
                                    updateSelectedStatus(true);
                                    updateApplicationQuotation();
                                  },
                                  message: 'Confirm Selection',
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConfirmSelectionButton(
                                  onPressed: () {
                                    updateSelectedStatus(false);
                                    updateRequiredStatus(false);
                                    Navigator.pop(context);
                                  },
                                  message: 'Exit',
                                ),
                              ),
                            )
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        'One ${component.name} was added to the installation requirements',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Total cost: ${component.cost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateSelectedStatus(false);
                          updateApplicationQuotation();
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
