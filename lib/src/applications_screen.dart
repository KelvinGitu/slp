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
        title: const Text(
          'Pending applications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: allApplications.when(
        data: (applications) {
          return (applications.isNotEmpty)
              ? ListView.builder(
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
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              application.clientName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              application.quotation.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.deepOrangeAccent),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(),
                    const Text(
                      'You have no active applications',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 30,
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                        child: const Text('Start new application'),
                      ),
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
