// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/communication_components_model.dart';
import 'package:solar_project/src/controller/communication_components_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class CommunicationComponentsWidget extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  final CommunicationComponentsModel comp;
  const CommunicationComponentsWidget({
    super.key,
    required this.component,
    required this.applicationId,
    required this.comp,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunicationComponentsWidgetState();
}

class _CommunicationComponentsWidgetState
    extends ConsumerState<CommunicationComponentsWidget> {
  final TextEditingController cableLengthController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  bool validate = false;

  @override
  void dispose() {
    cableLengthController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected, String componentName) {
    ref
        .watch(communicationComponentsControllerProvider)
        .updateCommunicationComponentSelectedStatus(
          applicationId: widget.applicationId,
          component: widget.component,
          componentName: componentName,
          selected: selected,
        );
  }

  void updateSelectedCommunicationCompoentCost(int cost, String componentName) {
    ref
        .watch(communicationComponentsControllerProvider)
        .updateCommunicationComponentCost(
          applicationId: widget.applicationId,
          component: widget.component,
          componentName: componentName,
          cost: cost,
        );
  }

  void updateSelectedCommunicationComponentLength(
      int length, String componentName) {
    ref
        .watch(communicationComponentsControllerProvider)
        .updateCommunicationComponentLength(
          applicationId: widget.applicationId,
          component: widget.component,
          componentName: componentName,
          length: length,
        );
  }

  void updateSelectedCommunicationComponentQuantity(
      int quantity, String componentName) {
    ref
        .watch(communicationComponentsControllerProvider)
        .updateCommunicationComponentQuantity(
          applicationId: widget.applicationId,
          component: widget.component,
          componentName: componentName,
          quantity: quantity,
        );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.comp.name;
    final splitName = name.split(' ');
    final lastName = splitName.last;
    return Padding(
      padding: const EdgeInsets.all(10),
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
                widget.comp.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            (lastName == 'cable')
                ? TextField(
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
                  )
                : TextField(
                    controller: unitsController,
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
            (widget.comp.isSelected == false)
                ? (lastName == 'cable')
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
                                : updateSelectedStatus(true, widget.comp.name);
                            (validate == true)
                                ? null
                                : updateSelectedCommunicationComponentLength(
                                    int.parse(cableLengthController.text),
                                    widget.comp.name,
                                  );

                            (validate == true)
                                ? null
                                : updateSelectedCommunicationCompoentCost(
                                    int.parse(cableLengthController.text) *
                                        widget.comp.price,
                                    widget.comp.name,
                                  );
                            (validate == true) ? null : Navigator.pop(context);
                          },
                          message: 'Select',
                        ),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                            onPressed: () {
                              setState(() {
                                setState(() {
                                  validate = unitsController.text.isEmpty;
                                });
                              });
                              (validate == true)
                                  ? null
                                  : updateSelectedStatus(
                                      true, widget.comp.name);
                              (validate == true)
                                  ? null
                                  : updateSelectedCommunicationComponentQuantity(
                                      int.parse(unitsController.text),
                                      widget.comp.name);
                              (validate == true)
                                  ? null
                                  : updateSelectedCommunicationCompoentCost(
                                      int.parse(unitsController.text) *
                                          widget.comp.price,
                                      widget.comp.name);
                              (validate == true)
                                  ? null
                                  : Navigator.pop(context);
                            },
                            message: 'Select'),
                      )
                : (lastName == 'cable')
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                            onPressed: () {
                              updateSelectedStatus(false, widget.comp.name);

                              updateSelectedCommunicationComponentLength(
                                  0, widget.comp.name);
                              updateSelectedCommunicationCompoentCost(
                                  0, widget.comp.name);
                              Navigator.pop(context);
                            },
                            message: 'Remove'),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ConfirmSelectionButton(
                            onPressed: () {
                              updateSelectedStatus(false, widget.comp.name);

                              updateSelectedCommunicationComponentQuantity(
                                  0, widget.comp.name);
                              updateSelectedCommunicationCompoentCost(
                                  0, widget.comp.name);
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
