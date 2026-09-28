import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/auth/views/widgets/auth_layout.dart';
import 'package:solartide/features/business/controller/business_controller.dart';
import 'package:solartide/features/business/views/widgets/business_form.dart';

/// First run after sign-up. Saving it also loads the starting price
/// catalogue, and the route map moves on to Home by itself.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _form = GlobalKey<BusinessFormState>();

  void _submit() {
    final profile = _form.currentState?.value();
    if (profile == null) return;
    ref.read(businessControllerProvider.notifier).completeSetup(profile, context);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(businessControllerProvider);
    return AuthLayout(
      title: 'Your business',
      subtitle: 'This goes at the top of every quote. Add your logo, KRA PIN and payment details later in Settings.',
      footer: AuthLink(
        label: 'Not you? Sign out',
        alignment: Alignment.center,
        onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
      ),
      children: [
        BusinessForm(key: _form, compact: true),
        const SizedBox(height: AppSpace.section),
        PrimaryButton(label: 'Continue', isLoading: loading, onPressed: _submit),
      ],
    );
  }
}
