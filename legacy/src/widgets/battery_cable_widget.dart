// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/models/battery_cable_model.dart';
import 'package:solar_project/src/controller/battery_cables_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class BatteryCableWidget extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  final BatteryCableModel cable;
  const BatteryCableWidget({
    Key? key,
    required this.component,
    required this.applicationId,
    required this.cable,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BatteryCableWidgetState();
}

class _BatteryCableWidgetState extends ConsumerState<BatteryCableWidget> {
  final TextEditingController cableLengthController = TextEditingController();

  bool validate = false;

  @override
  void dispose() {
    cableLengthController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected, String cable) {
    ref.watch(batteryCablesControllerProvider).updateBatteryCableSelectedStatus(
          applicationId: widget.applicationId,
          component: widget.component,
          cable: cable,
          selected: selected,
        );
  }

  void updateSelectedCableCost(int cost, String cable) {
    ref.watch(batteryCablesControllerProvider).updateBatteryCableCost(
          applicationId: widget.applicationId,
          component: widget.component,
          cable: cable,
          cost: cost,
        );
  }

  void updateSelectedCableLength(int length, String cable) {
    ref.watch(batteryCablesControllerProvider).updateBatteryCableLength(
          applicationId: widget.applicationId,
          component: widget.component,
          cable: cable,
          length: length,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                '${widget.cable.crossSection}\u00b2 battery cable',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.cable.purpose,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cableLengthController,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                hintText: 'Length in metres',
                hintStyle: TextStyle(
                    fontSize: 14, color: Colors.black.withOpacity(0.6)),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                errorText: validate ? "Value Can't Be Empty" : null,
              ),
            ),
            const SizedBox(height: 20),
            (widget.cable.isSelected == false)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: ConfirmSelectionButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            validate = cableLengthController.text.isEmpty;
                          });
                        });
                        (validate == true)
                            ? null
                            : updateSelectedStatus(
                                true, widget.cable.crossSection);
                        (validate == true)
                            ? null
                            : updateSelectedCableLength(
                                int.parse(cableLengthController.text),
                                widget.cable.crossSection,
                              );
                        (validate == true)
                            ? null
                            : updateSelectedCableCost(
                                int.parse(cableLengthController.text) *
                                    widget.cable.price,
                                widget.cable.crossSection,
                              );
                        (validate == true) ? null : Navigator.pop(context);
                      },
                      message: 'Confirm',
                    ),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConfirmSelectionButton(
                        onPressed: () {
                          updateSelectedStatus(
                              false, widget.cable.crossSection);
                          updateSelectedCableLength(
                              0, widget.cable.crossSection);
                          updateSelectedCableCost(0, widget.cable.crossSection);
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
