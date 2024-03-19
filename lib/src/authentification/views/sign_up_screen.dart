import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/authentification/controller/auth_controller.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool validate = false;
  bool validate2 = false;
  bool validate3 = false;

  bool passwordVisible = false;

  @override
  void initState() {
    passwordVisible = true;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void emailSignUp() async {
    ref.watch(authControllerProvider.notifier).emailSignUp(
          nameController.text,
          emailController.text,
          passwordController.text,
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'UserName',
                      border: InputBorder.none,
                      filled: true,
                      errorText: validate ? "Name Can't Be Empty" : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: InputBorder.none,
                      filled: true,
                      errorText: validate2 ? "Email Can't Be Empty" : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: passwordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: InputBorder.none,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                            () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        },
                      ),
                      errorText: validate3 ? "Password Can't Be Empty" : null,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConfirmSelectionButton(
                    onPressed: () {
                      setState(() {
                        validate = nameController.text.isEmpty;
                        validate2 = emailController.text.isEmpty;
                        validate3 = passwordController.text.isEmpty;
                      });
                      (validate == true ||
                              validate2 == true ||
                              validate3 == true)
                          ? null
                          : emailSignUp();
                    },
                    message: 'Sign Up',
                  )
                ],
              ),
            ),
    );
  }
}
