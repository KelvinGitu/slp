import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Search box for a list: surface fill, magnifier, no label (the list's
/// title says what it searches).
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.input),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppText.body.copyWith(color: p.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: AppSize.iconInline, color: p.textSecondary),
        ),
      ),
    );
  }
}
