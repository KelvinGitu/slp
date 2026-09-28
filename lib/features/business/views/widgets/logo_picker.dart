import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/pill_button.dart';

/// The business logo as it will sit on the PDF, with an upload button.
class LogoPicker extends StatelessWidget {
  const LogoPicker({super.key, required this.logoUrl, required this.onPick, this.busy = false});

  final String? logoUrl;
  final VoidCallback onPick;
  final bool busy;

  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final url = logoUrl;
    return Row(
      children: [
        Container(
          width: _size,
          height: _size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: p.border),
          ),
          child: url == null
              ? Icon(PhosphorIconsRegular.image, size: AppSize.iconNav, color: p.textSecondary)
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  semanticLabel: 'Business logo',
                  errorBuilder: (_, _, _) =>
                      Icon(PhosphorIconsRegular.imageBroken, size: AppSize.iconNav, color: p.textSecondary),
                ),
        ),
        const SizedBox(width: AppSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Logo', style: AppText.bodyStrong.copyWith(color: p.textPrimary)),
              Text('Printed at the top of your quotes.', style: AppText.label.copyWith(color: p.textSecondary)),
              const SizedBox(height: AppSpace.sm),
              PillButton(
                label: busy ? 'Uploading' : (url == null ? 'Upload logo' : 'Change logo'),
                icon: PhosphorIconsRegular.uploadSimple,
                outlined: true,
                onPressed: busy ? null : onPick,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
