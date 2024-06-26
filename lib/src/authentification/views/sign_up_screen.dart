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

    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                          image: AssetImage('assets/logos/logo_transparent.png'),
                        ),
                      const Text(
                        'Welcome',
                        style: TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          errorText: validate ? "Name Can't Be Empty" : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(),
                          ),
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
                          hintStyle: const TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(),
                          ),
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
              ),
            ),
    );
  }
}
