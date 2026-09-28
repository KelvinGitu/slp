import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Input with its label above the field (STYLE_GUIDE §5.10). Fill, radius and
/// the focus border come from the theme. Errors show as a caption in the coral
/// `on` color with a small warning icon, and a 1.5px coral `strong` border.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofillHints,
    this.onSubmitted,
    this.icon,
    this.suffix,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  /// Leading icon (20px, line style) that identifies the field at a glance.
  final IconData? icon;

  /// Trailing control, such as the password visibility toggle.
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextCapitalization textCapitalization;

  /// A whole-number field: digits only, so a stray "." or "-" can never
  /// reach `int.parse` (the original app crashed on exactly that).
  const AppTextField.number({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.icon,
    this.suffix,
    this.onChanged,
  })  : keyboardType = TextInputType.number,
        obscureText = false,
        autofillHints = null,
        inputFormatters = const [_digitsOnly],
        maxLines = 1,
        textCapitalization = TextCapitalization.none;

  static const _digitsOnly = _DigitsOnlyFormatter();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FormField<String>(
      initialValue: controller?.text,
      validator: (_) => validator?.call(controller?.text),
      builder: (field) {
        final error = field.errorText;
        final errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.coral.strong, width: 1.5),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.label.copyWith(color: p.textSecondary)),
            const SizedBox(height: AppSpace.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSize.input),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                obscureText: obscureText,
                autofillHints: autofillHints,
                onSubmitted: onSubmitted,
                inputFormatters: inputFormatters,
                maxLines: maxLines,
                minLines: 1,
                textCapitalization: textCapitalization,
                onChanged: (v) {
                  field.didChange(v);
                  onChanged?.call(v);
                },
                style: AppText.body.copyWith(color: p.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: icon == null ? null : Icon(icon, size: AppSize.iconInline, color: p.textSecondary),
                  suffixIcon: suffix,
                  enabledBorder: error == null ? null : errorBorder,
                  focusedBorder: error == null ? null : errorBorder,
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: AppSpace.xs),
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.warning, size: AppSize.iconChip, color: p.coral.on),
                    const SizedBox(width: AppSpace.xs),
                    Expanded(child: Text(error, style: AppText.caption.copyWith(color: p.coral.on))),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Same as `FilteringTextInputFormatter.digitsOnly`, but const so the
/// `.number` constructor can stay const.
class _DigitsOnlyFormatter extends TextInputFormatter {
  const _DigitsOnlyFormatter();

  static final _nonDigit = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (!_nonDigit.hasMatch(newValue.text)) return newValue;
    final text = newValue.text.replaceAll(_nonDigit, '');
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
