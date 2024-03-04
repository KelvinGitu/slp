// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/home_screen.dart';

import 'package:solar_project/src/expandable_widget.dart';

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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      updateApplicationQuotation();
    });
    super.initState();
  }

  void updateApplicationQuotation() {
    ref.watch(solarControllerProvider).updateApplicationQuotation(
          widget.applicationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final application =
        ref.watch(getApplicationStreamProvider(widget.applicationId));

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          width: 120,
          child: OutlinedButton(
            onPressed: () {
              // ref.watch(solarControllerProvider).saveComponent();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const HomeScreen()),
                  ),
                  (route) => false);
            },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text('Continue later?'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          application.when(
            data: (application) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${application.clientName}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quotation: KES ${application.quotation.toString()}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
            error: (error, stacktrace) => Text(error.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 20),
          ExpandableWidget(
            applicationId: widget.applicationId,
          ),
        ],
      ),
    );
  }
}
