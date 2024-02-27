import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/components_screen.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool newApplication = false;
  final TextEditingController clientNameController = TextEditingController();

  @override
  void dispose() {
    clientNameController.dispose();
    super.dispose();
  }

  void createNewApplication(String applicationId) {
    ref.watch(solarControllerProvider).createApplication(
          applicationId: applicationId,
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
        title: const Text('Company name'),
      ),
      body: (newApplication == false)
          ? Column(
              children: [
                OutlinedButton(
                  onPressed: () {
                    createNewApplication(applicationId);
                    setState(() {
                      newApplication == true;
                    });
                  },
                  child: const Text('Start new application'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Existing application?'),
                ),
              ],
            )
          : Column(
              children: [
                const Text('New application'),
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
                    updateClientName(applicationId);
                    saveComponentsToApplication(applicationId);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => ComponentsScreen(
                              applicationId: applicationId,
                            )),
                      ),
                    );
                  },
                  child: const Text('Start Application'),
                ),
              ],
            ),
    );
  }
}
