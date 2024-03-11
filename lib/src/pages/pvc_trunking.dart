// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class PVCTrunking extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const PVCTrunking({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PVCTrunkingState();
}

class _PVCTrunkingState extends ConsumerState<PVCTrunking> {
  final TextEditingController lengthController = TextEditingController();

  bool validate = false;

  late List<String> arguments;

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
          length,
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
                        'The recommended length for a standard house is 6m.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                        Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Input the length of PVC required.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: lengthController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  decoration: InputDecoration(
                                    hintText: 'Length in metres',
                                    hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black.withOpacity(0.6)),
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey.withOpacity(0.2),
                                    errorText: validate
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
                                        validate =
                                            lengthController.text.isEmpty;
                                      });
                                      (validate == true)
                                          ? null
                                          : updateComponentLength(
                                              int.parse(lengthController.text));
                                      (validate == true)
                                          ? null
                                          : updateSelectedStatus(true);
                                      (validate == true)
                                          ? null
                                          : updateComponentCost(
                                              int.parse(lengthController.text) *
                                                  40);
                                      (validate == true)
                                          ? null
                                          : updateApplicationQuotation();
                                    },
                                    message: 'Confirm Selection',
                                  ),
                                ),
                              ],
                            ),
                    ],
                  )
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(),
                      Text(
                        'Length of PVC: ${component.length}m',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Total cost: ${component.cost} KES',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 30),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateComponentLength(0);
                          updateSelectedStatus(false);
                          updateComponentCost(0);
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
