import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solar_project/src/components_screen.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/pdf/pdf_page.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  void updateApplicationDeleteStatus(
    bool delete,
    WidgetRef ref,
    String applicationId,
  ) async {
    ref.watch(solarControllerProvider).updateApplicationDeleteStatus(
          applicationId,
          delete,
        );
  }

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
          applications.removeWhere((element) => element.isDeleted == true);

          return (applications.isNotEmpty)
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: applications.length,
                  itemBuilder: ((context, index) {
                    final application = applications[index];
                    final appTime = application.createdAt;
                    final formattedDate = DateFormat("yMMMMd").format(appTime);
                    final todayDate =
                        DateFormat("yMMMMd").format(DateTime.now());
                    return GestureDetector(
                      onTap: () {
                        (application.isDone == true)
                            ? Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => PDFPage(
                                        applicationId:
                                            application.applicationId,
                                      )),
                                ),
                                (route) => false,
                              )
                            : Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => ComponentsScreen(
                                        applicationId:
                                            application.applicationId,
                                      )),
                                ),
                                (route) => false,
                              );
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete application?"),
                              content: const Text(
                                  "Are you sure you want to delete this application?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text("Continue"),
                                  onPressed: () {
                                    updateApplicationDeleteStatus(
                                      true,
                                      ref,
                                      application.applicationId,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
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
                              (todayDate == formattedDate)
                                  ? 'Today'
                                  : formattedDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              application.clientName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              application.quotation.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: (application.isDone == true)
                                    ? Colors.deepOrangeAccent
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
