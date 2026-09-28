import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SheetOption<T> {
  const SheetOption({required this.value, required this.title, this.subtitle, this.icon});

  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
}

/// Pick one of [options] from a bottom sheet. Returns null when dismissed.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetOption<T>> options,
  T? selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
    builder: (sheetContext) {
      final p = sheetContext.palette;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
            children: [
              Text(title, style: AppText.title1.copyWith(color: p.textPrimary)),
              const SizedBox(height: AppSpace.lg),
              for (final o in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Semantics(
                    selected: o.value == selected,
                    child: ListRow(
                      leading: EventAvatar(accent: p.neutral, icon: o.icon ?? PhosphorIconsRegular.circle),
                      title: o.title,
                      subtitle: o.subtitle,
                      trailing: o.value == selected
                          ? Icon(PhosphorIconsRegular.check, size: AppSize.iconInline, color: p.textPrimary)
                          : null,
                      onPressed: () => Navigator.of(sheetContext).pop(o.value),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// A yes/no confirmation. The confirm button is the sheet's one mint action.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
    builder: (sheetContext) {
      final p = sheetContext.palette;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.title1.copyWith(color: p.textPrimary)),
              const SizedBox(height: AppSpace.xs),
              Text(message, style: AppText.label.copyWith(color: p.textSecondary)),
              const SizedBox(height: AppSpace.section),
              PrimaryButton(label: confirmLabel, onPressed: () => Navigator.of(sheetContext).pop(true)),
              const SizedBox(height: AppSpace.sm),
              TextButton(onPressed: () => Navigator.of(sheetContext).pop(false), child: Text(cancelLabel)),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
