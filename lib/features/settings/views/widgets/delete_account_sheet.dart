import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/inline_banner.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';

/// Deleting is permanent, so it asks for the password rather than a tap.
Future<void> showDeleteAccountSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
      builder: (_) => const _DeleteAccount(),
    );

class _DeleteAccount extends ConsumerStatefulWidget {
  const _DeleteAccount();

  @override
  ConsumerState<_DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends ConsumerState<_DeleteAccount> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty) return;
    final deleted = await ref.read(authControllerProvider.notifier).deleteAccount(password: _password.text, context: context);
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final busy = ref.watch(authControllerProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Delete your account', style: AppText.title1.copyWith(color: p.textPrimary)),
              const SizedBox(height: AppSpace.lg),
              InlineBanner(
                accent: p.coral,
                icon: PhosphorIconsRegular.warning,
                message: 'Every quote, client and price you saved is removed. This cannot be undone.',
              ),
              const SizedBox(height: AppSpace.lg),
              AppTextField(
                label: 'Your password',
                controller: _password,
                obscureText: true,
                icon: PhosphorIconsRegular.lockSimple,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _delete(),
              ),
              const SizedBox(height: AppSpace.section),
              PrimaryButton(label: 'Delete everything', isLoading: busy, onPressed: _delete),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Keep my account')),
            ],
          ),
        ),
      ),
    );
  }
}
