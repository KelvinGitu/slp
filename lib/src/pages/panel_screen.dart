// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/controller/solar_controller.dart';

class PanelScreen extends ConsumerStatefulWidget {
  final String component;
  final String applicationId;
  const PanelScreen({
    super.key,
    required this.component,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanelScreenState();
}

class _PanelScreenState extends ConsumerState<PanelScreen> {
  final TextEditingController panelsController = TextEditingController();

  @override
  void dispose() {
    panelsController.dispose();
    super.dispose();
  }

  void updateSelectedStatus(bool selected) {
    ref.watch(solarControllerProvider).updateApplicationSelectedStatus(
          widget.component,
          selected,
          widget.applicationId,
        );
  }

  void updateApplicationComponentsList() {
    ref
        .watch(solarControllerProvider)
        .updateApplicationComponentsList(widget.applicationId);
  }

  void updateApplicationCost() {
    cost = int.parse(panelsController.text) * 10000;
    ref.watch(solarControllerProvider).updateApplicationCost(
          widget.component,
          cost,
          widget.applicationId,
        );
  }

  int cost = 0;

  Future<int> calculatePanelCost() async {
    cost = int.parse(panelsController.text) * 10000;
    return cost;
  }

  @override
  Widget build(BuildContext context) {
    final panel = ref.watch(getComponentStreamProvider(widget.component));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panels'),
      ),
      body: panel.when(
        data: (panel) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(panel.name),
              const Text('Measures of determination'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(panel.measurement[0]),
                    Text(panel.measurement[1]),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('How many panels does the client prefer?'),
              const SizedBox(height: 10),
              TextField(
                controller: panelsController,
                onSubmitted: (value) {
                  calculatePanelCost();
                },
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                  hintText: 'No. of panels',
                  border: InputBorder.none,
                  filled: true,
                ),
              ),
              const Text(
                '*approximate price: 1 panel = KES 10,000',
                style: TextStyle(fontSize: 10, color: Colors.orange),
              ),
              const SizedBox(height: 20),
              Text('Approximate cost: KES $cost'),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  updateApplicationCost();
                  updateSelectedStatus(true);
                  updateApplicationComponentsList();
                  Navigator.pop(context);
                },
                child: const Text('Confirm selection'),
              ),
            ],
          );
        },
        error: (error, stacktrace) => Text(error.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
