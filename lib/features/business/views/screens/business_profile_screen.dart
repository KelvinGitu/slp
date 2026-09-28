import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/detail_panel.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/business/controller/business_controller.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/features/business/views/widgets/business_form.dart';
import 'package:solartide/features/business/views/widgets/logo_picker.dart';

/// Settings > Business details. Everything printed on a quote.
class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _form = GlobalKey<BusinessFormState>();

  /// A logo uploaded on this screen but not saved yet.
  String? _logoUrl;
  bool _uploading = false;

  Future<void> _pickLogo() async {
    setState(() => _uploading = true);
    final url = await ref.read(businessControllerProvider.notifier).pickAndUploadLogo(context);
    if (mounted) setState(() => _uploading = false);
    if (url != null && mounted) setState(() => _logoUrl = url);
  }

  Future<void> _save() async {
    final profile = _form.currentState?.value(logoUrl: _logoUrl);
    if (profile == null) return;
    final ok = await ref.read(businessControllerProvider.notifier).save(profile, context);
    if (ok && mounted) await closeSubPage(context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider).valueOrNull;
    final saving = ref.watch(businessControllerProvider) && !_uploading;

    return SubPage(
      title: 'Business details',
      bottom: PrimaryButton(label: 'Save', isLoading: saving, onPressed: profile == null ? null : _save),
      children: [
        if (profile == null)
          const ShimmerRows(count: 4)
        else ...[
          LogoPicker(logoUrl: _logoUrl ?? profile.logoUrl, busy: _uploading, onPick: _pickLogo),
          const SizedBox(height: AppSpace.section),
          BusinessForm(key: _form, initial: profile),
        ],
      ],
    );
  }
}
