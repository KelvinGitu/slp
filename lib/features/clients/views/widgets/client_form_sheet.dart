import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/features/clients/controller/client_controller.dart';
import 'package:solartide/models/client_model.dart';

/// Adds a client, or edits [client]. Returns the saved client, or null if
/// the sheet was dismissed.
Future<ClientModel?> showClientFormSheet(BuildContext context, {ClientModel? client}) {
  return showModalBottomSheet<ClientModel>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
    builder: (_) => _ClientForm(client: client),
  );
}

class _ClientForm extends ConsumerStatefulWidget {
  const _ClientForm({this.client});

  final ClientModel? client;

  @override
  ConsumerState<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends ConsumerState<_ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.client?.name);
  late final _phone = TextEditingController(text: widget.client?.phone);
  late final _email = TextEditingController(text: widget.client?.email);
  late final _location = TextEditingController(text: widget.client?.location);
  late final _notes = TextEditingController(text: widget.client?.notes);

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _location, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref.read(clientControllerProvider.notifier).save(
          id: widget.client?.id,
          createdAt: widget.client?.createdAt,
          name: _name.text,
          phone: _phone.text,
          email: _email.text,
          location: _location.text,
          notes: _notes.text,
          context: context,
        );
    if (saved != null && mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final saving = ref.watch(clientControllerProvider);
    const gap = SizedBox(height: AppSpace.lg);

    return Padding(
      // Lift the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoint.mediumMaxContent),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.client == null ? 'New client' : 'Edit client',
                        style: AppText.title1.copyWith(color: p.textPrimary)),
                    const SizedBox(height: AppSpace.section),
                    AppTextField(
                      label: 'Name',
                      controller: _name,
                      icon: PhosphorIconsRegular.user,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the client’s name.' : null,
                    ),
                    gap,
                    AppTextField(
                      label: 'Phone',
                      controller: _phone,
                      hint: '0712 345 678',
                      icon: PhosphorIconsRegular.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    gap,
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      icon: PhosphorIconsRegular.envelopeSimple,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v != null && v.trim().isNotEmpty && !v.contains('@')) ? 'That email looks wrong.' : null,
                    ),
                    gap,
                    AppTextField(
                      label: 'Location',
                      controller: _location,
                      hint: 'Kitengela',
                      icon: PhosphorIconsRegular.mapPin,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    gap,
                    AppTextField(
                      label: 'Notes',
                      controller: _notes,
                      hint: 'Roof type, grid connection, access',
                      icon: PhosphorIconsRegular.note,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpace.section),
                    PrimaryButton(label: 'Save client', isLoading: saving, onPressed: _save),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
