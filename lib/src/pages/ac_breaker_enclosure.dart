import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:solar_project/src/widgets/yes_no_button.dart';

class ACBreakerEnclosure extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const ACBreakerEnclosure({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ACBreakerConsumerState();
}

class _ACBreakerConsumerState extends ConsumerState<ACBreakerEnclosure> {
  bool validate = false;

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
                    children: [
                      const Text(
                        'Is a breaker enclosure required for this installation?',
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
                                  isRequired = true;
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
                                  isRequired = false;
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
                      (isRequired == true)
                          ? Column(
                              children: [
                                Text(
                                  'An ${component.name} will be added automatically to the installation requirements',
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
                          : ConfirmSelectionButton(
                              onPressed: () {
                                updateSelectedStatus(false);
                                updateRequiredStatus(false);
                                updateApplicationQuotation();
                                Navigator.pop(context);
                              },
                              message: 'Exit',
                            ),
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
                          updateRequiredStatus(true);
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
