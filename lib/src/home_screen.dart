import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/applications_screen.dart';
import 'package:solar_project/src/components_screen.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late bool newApplication = false;
  final TextEditingController clientNameController = TextEditingController();

  @override
  void dispose() {
    clientNameController.dispose();
    super.dispose();
  }

  void createNewApplication(String applicationId) {
    ref.watch(solarControllerProvider).createApplication(
          applicationId: applicationId,
          clientName: clientNameController.text,
        );
  }

  void updateClientName(String applicationId) async {
    ref.watch(solarControllerProvider).updateClientName(
          clientName: clientNameController.text,
          applicationId: applicationId,
        );
  }

  void saveComponentsToApplication(String applicationId) async {
    ref
        .watch(solarControllerProvider)
        .saveComponentsToApplication(applicationId: applicationId);
  }

  @override
  Widget build(BuildContext context) {
    var applicationId = const Uuid().v1();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Company name',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: (newApplication == false)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 30,
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          newApplication = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10)),
                      child: const Text(
                        'Start new application',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => const ApplicationsScreen()),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10)),
                      child: const Text(
                        'Existing application?',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'New application',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      )),
                  const SizedBox(height: 20),
                  TextField(
                    controller: clientNameController,
                    decoration: const InputDecoration(
                      hintText: 'Client name',
                      border: InputBorder.none,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      createNewApplication(applicationId);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("New Application"),
                            content:
                                const Text("Proceed with new application?"),
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
                                  saveComponentsToApplication(applicationId);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => ComponentsScreen(
                                            applicationId: applicationId,
                                          )),
                                    ),
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Start Application'),
                  ),
                ],
              ),
            ),
    );
  }
}
