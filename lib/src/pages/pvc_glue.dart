import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class PVCGlue extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const PVCGlue({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PVCGlueState();
}

class _PVCGlueState extends ConsumerState<PVCGlue> {
  bool validate = false;

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

  void updateComponentQuanity(int quantity) {
    ref.watch(solarControllerProvider).updateApplicationComponentQuantity(
          widget.component,
          quantity,
          widget.applicationId,
        );
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One ${component.name} ${component.quantity}ml is required for this installation',
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
                            updateComponentQuanity(1);
                            updateApplicationQuotation();
                          },
                          message: 'Confirm Selection',
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        'One ${component.name} ${component.quantity}ml was included as part of the installation requirements',
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
                          Navigator.pop(context);
                        },
                        message: 'Exit',
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
