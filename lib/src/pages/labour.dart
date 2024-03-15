// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class Labour extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const Labour({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LabourState();
}

class _LabourState extends ConsumerState<Labour> {
  final TextEditingController labourController = TextEditingController();
  final TextEditingController daysController = TextEditingController();

  @override
  void dispose() {
    labourController.dispose();
    daysController.dispose();
    super.dispose();
  }

  bool validate = false;

  bool validate2 = false;

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

  void updateComponentCapacity(int capacity) {
    ref.watch(solarControllerProvider).updateApplicationComponentCapacity(
          widget.component,
          capacity,
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
            child: (component.isSelected == false)
                ? ListView(
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
                        'How many technicians are required for this installation?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: labourController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'No. of techicians',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate ? "Value Can't Be Empty" : null,
                        ),
                      ),
                      const Text(
                        '*Price per day: KES 2300',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'How many days are required to complete the installation?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: daysController,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                          hintText: 'No. of days',
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6)),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          errorText: validate2 ? "Value Can't Be Empty" : null,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                          onPressed: () {
                            setState(() {
                              validate = labourController.text.isEmpty;
                              validate2 = daysController.text.isEmpty;
                            });
                            (validate == true || validate2 == true)
                                ? null
                                : updateComponentCost(
                                    int.parse(labourController.text) *
                                        2300 *
                                        int.parse(daysController.text));
                            (validate == true || validate2 == true)
                                ? null
                                : updateComponentQuantity(
                                    int.parse(daysController.text));
                            (validate == true || validate2 == true)
                                ? null
                                : updateComponentCapacity(
                                    int.parse(labourController.text));
                            (validate == true || validate2 == true)
                                ? null
                                : updateSelectedStatus(true);
                            (validate == true || validate2 == true)
                                ? null
                                : updateApplicationQuotation();
                          },
                          message: 'Confirm Selection',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(),
                      Text(
                        'No. of technicians: ${component.capacity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'No. of days: ${component.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Total cost: KES ${component.cost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateComponentCapacity(0);
                          updateComponentQuantity(0);
                          updateComponentCost(0);
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
