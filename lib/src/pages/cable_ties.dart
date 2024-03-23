// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class CableTies extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const CableTies({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CableTiesState();
}

class _CableTiesState extends ConsumerState<CableTies> {
  late List<String> arguments;

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: (component.isSelected == false)
                ? Column(
                    children: [
                      const Text(
                        'Cable ties will be added automatically as part of the installation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Total cost: KES ${component.cost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          updateSelectedStatus(true);
                          updateApplicationQuotation();
                        },
                        message: 'Confirm Selection',
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(),
                      const Text(
                        'The cable ties have been included in the installation',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total cost: KES ${component.cost}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
