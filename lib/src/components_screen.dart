// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/pages/panel_screen.dart';
import 'package:solar_project/src/widgets/component_widget.dart';

class ComponentsScreen extends ConsumerStatefulWidget {
  final String applicationId;
  const ComponentsScreen({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ComponentsScreenState();
}

class _ComponentsScreenState extends ConsumerState<ComponentsScreen> {
  @override
  Widget build(BuildContext context) {
    final applicationComponents =
        ref.watch(getApplicationComponentStreamProvider(widget.applicationId));

    return Scaffold(
      appBar: AppBar(),
      body: applicationComponents.when(
        data: (applicationComponents) {
          return ListView(
            children: [
              ComponentWidget(
                  component: applicationComponents[0],
                  navigate: PanelScreen(
                      component: applicationComponents[0].name,
                      applicationId: widget.applicationId)),
              ComponentWidget(
                  component: applicationComponents[0],
                  navigate: PanelScreen(
                      component: applicationComponents[0].name,
                      applicationId: widget.applicationId)),
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
