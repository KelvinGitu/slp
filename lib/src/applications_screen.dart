import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/components_screen.dart';
import 'package:solar_project/src/controller/solar_controller.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allApplications = ref.watch(getAllApplicationsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending applications'),
      ),
      body: allApplications.when(
        data: (applications) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: applications.length,
            itemBuilder: ((context, index) {
              final application = applications[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => ComponentsScreen(
                            applicationId: application.applicationId,
                          )),
                    ),
                    (route) => false,
                  );
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(application.clientName),
                      const Spacer(),
                      Text(application.quotation.toString())
                    ],
                  ),
                ),
              );
            }),
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
