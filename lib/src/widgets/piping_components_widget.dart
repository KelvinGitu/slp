// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/models/piping_components_model.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class PipingComponentsWidget extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  final PipingComponentsModel piping;
  const PipingComponentsWidget({
    super.key,
    required this.component,
    required this.applicationId,
    required this.piping,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PipingComponentsWidgetState();
}

class _PipingComponentsWidgetState
    extends ConsumerState<PipingComponentsWidget> {
  final TextEditingController pipingQuantityController =
      TextEditingController();

  bool validate = false;

  @override
  void dispose() {
    pipingQuantityController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected, String piping) {
    ref.watch(solarControllerProvider).updatePipingComponentSelectedStatus(
          applicationId: widget.applicationId,
          component: widget.component,
          piping: piping,
          selected: selected,
        );
  }

  void updateSelectedPipingCost(int cost, String piping) {
    ref.watch(solarControllerProvider).updatePipingComponentCost(
          applicationId: widget.applicationId,
          component: widget.component,
          piping: piping,
          cost: cost,
        );
  }

  void updateSelectedPipingQuantity(int quantity, String piping) {
    ref.watch(solarControllerProvider).updatePipingComponentQuantity(
          applicationId: widget.applicationId,
          component: widget.component,
          piping: piping,
          quantity: quantity,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                widget.piping.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'How many units do you need?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pipingQuantityController,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                hintText: 'Number of units',
                hintStyle: TextStyle(
                    fontSize: 14, color: Colors.black.withOpacity(0.6)),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                errorText: validate ? "Value Can't Be Empty" : null,
              ),
            ),
            const SizedBox(height: 20),
            (widget.piping.isSelected == false)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: ConfirmSelectionButton(
                        onPressed: () {
                          setState(() {
                            setState(() {
                              validate = pipingQuantityController.text.isEmpty;
                            });
                          });
                          (validate == true)
                              ? null
                              : updateSelectedStatus(true, widget.piping.name);
                          (validate == true)
                              ? null
                              : updateSelectedPipingQuantity(
                                  int.parse(pipingQuantityController.text),
                                  widget.piping.name,
                                );
                          (validate == true)
                              ? null
                              : updateSelectedPipingCost(
                                  int.parse(pipingQuantityController.text) *
                                      widget.piping.price,
                                  widget.piping.name,
                                );
                          (validate == true) ? null : Navigator.pop(context);
                        },
                        message: 'Select'),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConfirmSelectionButton(
                        onPressed: () {
                          updateSelectedStatus(false, widget.piping.name);
                          updateSelectedPipingQuantity(0, widget.piping.name);
                          updateSelectedPipingCost(0, widget.piping.name);
                          Navigator.pop(context);
                        },
                        message: 'Remove'),
                  ),
          ],
        ),
      ),
    );
  }
}
