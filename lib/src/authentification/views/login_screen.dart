import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/authentification/controller/auth_controller.dart';
import 'package:solar_project/src/authentification/views/sign_up_screen.dart';
import 'package:solar_project/src/home_screen.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool validate = false;
  bool validate2 = false;

  bool passwordVisible = false;

  @override
  void initState() {
    passwordVisible = true;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginWithEmail() async {
    ref.watch(authControllerProvider.notifier).emailLogin(
          emailController.text,
          passwordController.text,
          context,
        );
  }

  void getUser() {
    ref.watch(authControllerProvider.notifier).authStateChange.listen((user) {
      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: ((context) => const HomeScreen()),
          ),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: 
      isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : 
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 150),
                      const Image(
                        image: AssetImage('assets/logos/logo_transparent.png'),
                      ),
                      const Text(
                        'Welcome back',
                        style: TextStyle(fontSize: 30),
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
                          errorText: validate ? "Email Can't Be Empty" : null,
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
                          errorText:
                              validate2 ? "Password Can't Be Empty" : null,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ConfirmSelectionButton(
                        onPressed: () {
                          setState(() {
                            validate = emailController.text.isEmpty;
                            validate2 = passwordController.text.isEmpty;
                          });
                          (validate == true || validate2 == true)
                              ? null
                              : loginWithEmail();
                        },
                        message: 'Login',
                      ),
                      const SizedBox(height: 40),
                      const Text('New User?'),
                      const SizedBox(height: 5),
                      ConfirmSelectionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => const SignUpScreen()),
                            ),
                          );
                        },
                        message: 'Sign up',
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
