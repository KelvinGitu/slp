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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginWithEmail() {
    ref.watch(authControllerProvider).emailLogin(
          emailController.text,
          passwordController.text,
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: InputBorder.none,
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: InputBorder.none,
                filled: true,
              ),
            ),
            const SizedBox(height: 40),
            ConfirmSelectionButton(
              onPressed: () {
                loginWithEmail();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const HomeScreen()),
                  ),
                  (route) => false,
                );
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
    );
  }
}
