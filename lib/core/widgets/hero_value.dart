import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// The one big number on a screen (STYLE_GUIDE §5.2): quiet label, display
/// value, optional status chip and a quiet note under it.
class HeroValue extends StatelessWidget {
  const HeroValue({super.key, required this.label, required this.value, this.chip, this.note});

  /// "Kamau Residence, Nakuru".
  final String label;

  /// Quote total "KES 412,500".
  final String value;
  final Widget? chip;

  /// "Arrived 17:56 - 14 min late".
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppText.label.copyWith(color: p.textSecondary)),
        const SizedBox(height: AppSpace.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: AppText.display.copyWith(color: p.textPrimary)),
        ),
        if (chip != null) ...[
          const SizedBox(height: AppSpace.sm),
          chip!,
        ],
        if (note != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(note!, style: AppText.label.copyWith(color: p.textSecondary)),
        ],
      ],
    );
  }
}
