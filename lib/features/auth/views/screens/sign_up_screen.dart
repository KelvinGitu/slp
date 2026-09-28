import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/auth/views/widgets/auth_layout.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  static const _minPasswordLength = 8;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authControllerProvider.notifier).signUp(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider);

    return AuthLayout(
      title: 'Create account',
      subtitle: "You'll add your business details next. They go on every quote.",
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Your name',
                  controller: _name,
                  icon: PhosphorIconsRegular.user,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name.' : null,
                ),
                const SizedBox(height: AppSpace.lg),
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
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                  validator: (v) => (v == null || v.length < _minPasswordLength)
                      ? 'Use at least $_minPasswordLength characters.'
                      : null,
                  suffix: PasswordToggle(
                    visible: _showPassword,
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.section),
        PrimaryButton(label: 'Create account', isLoading: loading, onPressed: _submit),
        const SizedBox(height: AppSpace.md),
        AuthLink(
          label: 'Already have an account? Sign in',
          alignment: Alignment.center,
          onPressed: () => Routemaster.of(context).replace('/login'),
        ),
      ],
    );
  }
}
