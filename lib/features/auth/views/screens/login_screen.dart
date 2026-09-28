import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/auth/views/widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authControllerProvider.notifier).signIn(email: _email.text, password: _password.text, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider);

    return AuthLayout(
      title: 'Sign in',
      subtitle: 'Quotes, clients and prices, on your phone and in the browser.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Email',
                  controller: _email,
                  hint: 'you@example.co.ke',
                  icon: PhosphorIconsRegular.envelopeSimple,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter your email address.' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  icon: PhosphorIconsRegular.lockSimple,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter your password.' : null,
                  suffix: PasswordToggle(
                    visible: _showPassword,
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ],
            ),
          ),
        ),
        AuthLink(
          label: 'Forgot password?',
          onPressed: () =>
              ref.read(authControllerProvider.notifier).sendPasswordReset(email: _email.text, context: context),
        ),
        const SizedBox(height: AppSpace.sm),
        PrimaryButton(label: 'Sign in', isLoading: loading, onPressed: _submit),
        const SizedBox(height: AppSpace.md),
        AuthLink(
          label: 'New to SolarTide? Create an account',
          alignment: Alignment.center,
          onPressed: () => Routemaster.of(context).replace('/sign-up'),
        ),
      ],
    );
  }
}
