import 'package:flutter/material.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';

/// Builds the app theme from the style guide (§11). Built once per brightness
/// in [SolarTideApp] so navigation never triggers a theme cross-fade.
ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.light ? AppPalette.light : AppPalette.dark;

  final scheme = ColorScheme.fromSeed(seedColor: AppColors.mint, brightness: brightness).copyWith(
    primary: AppColors.mint,
    onPrimary: AppColors.onMint,
    surface: p.card,
    onSurface: p.textPrimary,
    error: AppColors.danger,
    onError: AppColors.onDanger,
  );

  final inputRadius = BorderRadius.circular(AppRadius.md);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.scaffold,
    fontFamily: AppText.fontFamily,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    extensions: [p],
    textTheme: const TextTheme(
      displayLarge: AppText.display,
      titleLarge: AppText.title1,
      titleMedium: AppText.title2,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      bodySmall: AppText.label,
      labelLarge: AppText.bodyStrong,
      labelSmall: AppText.caption,
    ).apply(bodyColor: p.textPrimary, displayColor: p.textPrimary, fontFamily: AppText.fontFamily),
    iconTheme: IconThemeData(color: p.textPrimary, size: AppSize.iconNav),
    appBarTheme: AppBarTheme(
      backgroundColor: p.scaffold,
      foregroundColor: p.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.title1.copyWith(color: p.textPrimary, fontFamily: AppText.fontFamily),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: p.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: AppColors.onMint,
        disabledBackgroundColor: p.neutral.bg,
        disabledForegroundColor: p.textSecondary,
        minimumSize: const Size.fromHeight(AppSize.primaryButton),
        elevation: 0,
        // The family must be set here: a button's textStyle replaces the
        // theme default, and without it buttons rendered in Roboto.
        textStyle: AppText.bodyStrong.copyWith(fontFamily: AppText.fontFamily),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.mintBorder),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.textPrimary,
        textStyle: AppText.bodyStrong.copyWith(fontFamily: AppText.fontFamily),
        minimumSize: const Size(AppSize.minTouch, AppSize.minTouch),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.scaffold,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: AppSize.bottomNav,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => AppText.caption.copyWith(color: s.contains(WidgetState.selected) ? p.navActive : p.navInactive),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(size: AppSize.iconNav, color: s.contains(WidgetState.selected) ? p.navActive : p.navInactive),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.lg),
      hintStyle: AppText.body.copyWith(color: p.textSecondary),
      errorStyle: AppText.caption.copyWith(color: p.coral.on),
      border: OutlineInputBorder(borderRadius: inputRadius, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: inputRadius, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: p.textPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: p.coral.strong, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: p.coral.strong, width: 1.5),
      ),
    ),
    // Sheets and dialogs use the scaffold tone, not `surface`: inputs and pill
    // buttons are `surface` (white), and white on white made them vanish.
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.scaffold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      modalBarrierColor: AppColors.scrim.withValues(alpha: AppOpacity.scrim),
      // Every sheet gets a handle: it shows the sheet scrolls and can be
      // dragged down to close. The handle area provides the top spacing.
      showDragHandle: true,
      dragHandleColor: p.navInactive,
      dragHandleSize: AppSize.sheetHandle,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.scaffold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.scrim.withValues(alpha: AppOpacity.scrim),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.textPrimary,
      contentTextStyle: AppText.body.copyWith(color: p.scaffold),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.textPrimary),
    pageTransitionsTheme: const PageTransitionsTheme(),
  );
}
