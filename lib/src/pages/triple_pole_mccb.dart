import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class TriplePoleMCCB extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const TriplePoleMCCB({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TriplePoleMCCBState();
}

class _TriplePoleMCCBState extends ConsumerState<TriplePoleMCCB> {
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
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          widget.component,
          required,
          widget.applicationId,
        );
  }

  void updateDoublePoleRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          'Double Pole MCB 63A',
          required,
          widget.applicationId,
        );
  }

  void updateDoublePoleSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          'Double Pole MCB 63A',
          selected,
          widget.applicationId,
        );
  }

  void updateFourPoleRequiredStatus(bool required) {
    ref.watch(solarControllerProvider).updateApplicationComponentRequiredStatus(
          'Four Pole MCCB 63A',
          required,
          widget.applicationId,
        );
  }

  void updateFourPoleSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationComponentSelectedStatus(
          'Four Pole MCCB 63A',
          selected,
          widget.applicationId,
        );
  }

  void updateComponentCost(int cost) {
    ref.watch(solarControllerProvider).updateApplicationComponentCost(
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
    ref.watch(solarControllerProvider).updateApplicationComponentLength(
          widget.component,
          length * 2,
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
                        'Is this component required for the installation?',
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
                            SizedBox(
                              height: 25,
                              width: 120,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    isRequired = true;
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
                                    isRequired = false;
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
                      const SizedBox(height: 40),
                      (isRequired == true)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'One ${component.name} circuit breaker will be added automatically as part of the installation',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ConfirmSelectionButton(
                                    onPressed: () {
                                      updateSelectedStatus(true);
                                      updateRequiredStatus(true);
                                      updateDoublePoleRequiredStatus(false);
                                      updateFourPoleRequiredStatus(false);
                                      updateDoublePoleSelectedStatus(false);
                                      updateFourPoleSelectedStatus(false);
                                      updateComponentQuanity(1);
                                      updateApplicationQuotation();
                                    },
                                    message: 'Confirm Selection',
                                  ),
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.topCenter,
                              child: ConfirmSelectionButton(
                                onPressed: () {
                                  updateSelectedStatus(false);
                                  updateRequiredStatus(false);
                                  updateApplicationQuotation();
                                  Navigator.pop(context);
                                },
                                message: 'Exit',
                              ),
                            ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        'One ${component.name} circuit breaker was added as part of the installation',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Total cost: ${component.cost} KES',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                          onPressed: () {
                            updateSelectedStatus(false);
                            updateDoublePoleRequiredStatus(true);
                            updateFourPoleRequiredStatus(true);
                            updateComponentQuanity(0);
                          },
                          message: 'Edit Selection',
                        ),
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
