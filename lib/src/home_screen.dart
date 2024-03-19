import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/applications_screen.dart';
import 'package:solar_project/src/authentification/controller/auth_controller.dart';
import 'package:solar_project/src/authentification/views/login_screen.dart';
import 'package:solar_project/src/components_screen.dart';
import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late bool newApplication = false;
  late bool validate = false;
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

  void deleteNewApplication(String applicationId) {
    ref
        .watch(solarControllerProvider)
        .deleteApplication(applicationId: applicationId);
  }

  void saveComponentsToApplication(String applicationId) async {
    ref
        .watch(solarControllerProvider)
        .saveComponentsToApplication(applicationId: applicationId);
  }

  void signOutUser() async {
    ref.watch(authControllerProvider.notifier).signUserOut();
  }

  @override
  Widget build(BuildContext context) {
    var applicationId = const Uuid().v1();
    final user = ref.watch(userProvider)!;
    final userName = user.name;
    final splitUserName = userName.split(' ');
    final nameUser = splitUserName.first;
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
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Welcome $nameUser',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Start new application or continue with an existing application?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10)),
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
                                builder: ((context) =>
                                    const ApplicationsScreen()),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10)),
                          child: const Text(
                            'Existing applications',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ConfirmSelectionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Sign out"),
                              content: const Text(
                                  "Are you sure you want to log out?"),
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
                                    signOutUser();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()));
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      message: 'Sign Out',
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
                    decoration: InputDecoration(
                      hintText: 'Client name',
                      border: InputBorder.none,
                      filled: true,
                      errorText: validate ? "Name Can't Be Empty" : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 120,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                validate = clientNameController.text.isEmpty;
                              });
                              createNewApplication(applicationId);
                              saveComponentsToApplication(applicationId);
                              (validate == true)
                                  ? null
                                  : showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("New Application"),
                                          content: const Text(
                                              "Proceed with new application?"),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () {
                                                deleteNewApplication(
                                                    applicationId);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Continue"),
                                              onPressed: () {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        ComponentsScreen(
                                                          applicationId:
                                                              applicationId,
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
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10)),
                            child: const Text(
                              'Start Application',
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
                              setState(() {
                                newApplication = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10)),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
