import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/sizing/logic/sizing_calculator.dart';

/// Adds or edits one appliance on the load sheet. New ones can start from a
/// preset. Returns null when dismissed.
Future<Appliance?> showApplianceSheet(BuildContext context, {Appliance? appliance}) =>
    showModalBottomSheet<Appliance>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
      builder: (_) => _ApplianceForm(appliance: appliance),
    );

class _ApplianceForm extends StatefulWidget {
  const _ApplianceForm({this.appliance});

  final Appliance? appliance;

  @override
  State<_ApplianceForm> createState() => _ApplianceFormState();
}

class _ApplianceFormState extends State<_ApplianceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.appliance?.name);
  late final _watts = TextEditingController(text: widget.appliance?.watts.toString());
  late final _qty = TextEditingController(text: (widget.appliance?.quantity ?? 1).toString());
  late final _hours = TextEditingController(text: _fmt(widget.appliance?.hoursPerDay));

  static String _fmt(double? h) => h == null ? '' : (h == h.roundToDouble() ? '${h.round()}' : '$h');

  @override
  void dispose() {
    for (final c in [_name, _watts, _qty, _hours]) {
      c.dispose();
    }
    super.dispose();
  }

  void _usePreset(Appliance a) => setState(() {
        _name.text = a.name;
        _watts.text = '${a.watts}';
        _qty.text = '${a.quantity}';
        _hours.text = _fmt(a.hoursPerDay);
      });

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(Appliance(
      name: _name.text.trim(),
      watts: int.parse(_watts.text),
      quantity: int.parse(_qty.text),
      hoursPerDay: double.parse(_hours.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    String? positive(String? v) => (num.tryParse(v ?? '') ?? 0) > 0 ? null : 'More than 0.';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.appliance == null ? 'Add appliance' : 'Edit appliance',
                    style: AppText.title1.copyWith(color: p.textPrimary)),
                if (widget.appliance == null) ...[
                  const SectionLabel('Common'),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final a in appliancePresets)
                        ActionChip(
                          label: Text(a.name),
                          avatar: const Icon(PhosphorIconsRegular.plus, size: AppSize.iconChip),
                          onPressed: () => _usePreset(a),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpace.section),
                AppTextField(
                  label: 'Appliance',
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name it.' : null,
                ),
                const SizedBox(height: AppSpace.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: AppTextField.number(label: 'Watts', controller: _watts, validator: positive)),
                    const SizedBox(width: AppSpace.md),
                    Expanded(child: AppTextField.number(label: 'How many', controller: _qty, validator: positive)),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Hours a day',
                        controller: _hours,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?'))],
                        validator: (v) {
                          final h = double.tryParse(v ?? '') ?? 0;
                          return h <= 0 || h > 24 ? '0 to 24.' : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.section),
                PrimaryButton(label: widget.appliance == null ? 'Add' : 'Save', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
