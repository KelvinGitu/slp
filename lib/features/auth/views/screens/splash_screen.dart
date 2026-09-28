import 'package:flutter/material.dart';
import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';

/// Shown only while auth resolves. Nothing here navigates: the route map
/// switches underneath it once the session is known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'Loading',
          child: Text(AppConstants.appName, style: AppText.title1.copyWith(color: p.textSecondary)),
        ),
      ),
    );
  }
}
