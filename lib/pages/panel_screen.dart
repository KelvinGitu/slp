// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/controller/solar_controller.dart';

class PanelScreen extends ConsumerWidget {
  final String component;
  const PanelScreen({
    super.key,
    required this.component,
  });

  void updateSelectedStatus(WidgetRef ref, String component, bool selected) {
    ref
        .watch(solarControllerProvider)
        .updateSelectedStatus(component, selected);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panel = ref.watch(getComponentStreamProvider(component));
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
              OutlinedButton(
                onPressed: () {
                  updateSelectedStatus(ref, panel.name, true);
                },
                child: const Text('Change status'),
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
