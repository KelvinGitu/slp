// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/models/cable_lugs_model.dart';
import 'package:solar_project/src/controller/cable_lugs_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class CableLugsWidget extends ConsumerStatefulWidget {
  final CableLugsModel lug;
  final String applicationId;
  final String component;
  const CableLugsWidget({
    super.key,
    required this.lug,
    required this.applicationId,
    required this.component,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CableLugsWidgetState();
}

class _CableLugsWidgetState extends ConsumerState<CableLugsWidget> {
  final TextEditingController lugController = TextEditingController();

  @override
  void dispose() {
    lugController.dispose();
    super.dispose();
  }

  bool validate = false;

  void updateLugsSelectedStatus(bool selected, String lug) {
    ref.watch(cableLugsControllerProvider).updateLugsSelectedStatus(
          applicationId: widget.applicationId,
          component: widget.component,
          lug: lug,
          selected: selected,
        );
  }

  void updateLugCost(int cost, String lug) {
    ref.watch(cableLugsControllerProvider).updateLugsCost(
          applicationId: widget.applicationId,
          component: widget.component,
          lug: lug,
          cost: cost,
        );
  }

  void updateLugQuantity(int quantity, String lug) {
    ref.watch(cableLugsControllerProvider).updateLugsQuantity(
          applicationId: widget.applicationId,
          component: widget.component,
          lug: lug,
          quantity: quantity,
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
                widget.lug.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: lugController,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                hintText: 'No. of lugs required',
                hintStyle: TextStyle(
                    fontSize: 14, color: Colors.black.withOpacity(0.6)),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                errorText: validate ? "Value Can't Be Empty" : null,
              ),
            ),
            const SizedBox(height: 20),
            (widget.lug.isSelected == false)
                ? Align(
                    alignment: Alignment.topCenter,
                    child: ConfirmSelectionButton(
                      onPressed: () {
                        setState(() {
                          validate = lugController.text.isEmpty;
                        });
                        (validate == true)
                            ? null
                            : updateLugCost(int.parse(lugController.text) * 15,
                                widget.lug.name);
                        (validate == true)
                            ? null
                            : updateLugQuantity(
                                int.parse(lugController.text), widget.lug.name);
                        (validate == true)
                            ? null
                            : updateLugsSelectedStatus(true, widget.lug.name);
                        Navigator.pop(context);
                      },
                      message: 'Confirm',
                    ),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConfirmSelectionButton(
                      onPressed: () {
                        updateLugCost(0, widget.lug.name);
                        updateLugQuantity(0, widget.lug.name);
                        updateLugsSelectedStatus(false, widget.lug.name);
                      },
                      message: 'Remove',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
