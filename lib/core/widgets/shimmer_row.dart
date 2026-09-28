import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:shimmer/shimmer.dart';

/// Loading placeholder in the shape of a list row (STYLE_GUIDE §5.15). Static
/// when the OS asks for reduced motion.
class ShimmerRows extends StatelessWidget {
  const ShimmerRows({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rows = Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.lg),
          _row(p),
        ],
      ],
    );
    return Semantics(
      label: 'Loading',
      child: MediaQuery.of(context).disableAnimations
          ? rows
          : Shimmer.fromColors(baseColor: p.neutral.bg, highlightColor: p.surface, child: rows),
    );
  }

  Widget _row(AppPalette p) {
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
          widthFactor: widthFactor,
          alignment: Alignment.centerLeft,
          child: Container(
            height: height,
            decoration: BoxDecoration(color: p.neutral.bg, borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        );

    return SizedBox(
      height: AppSize.listRow,
      child: Row(
        children: [
          Container(
            width: AppSize.avatar,
            height: AppSize.avatar,
            decoration: BoxDecoration(color: p.neutral.bg, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bar(0.6, AppSpace.md),
                const SizedBox(height: AppSpace.sm),
                bar(0.4, AppSpace.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
