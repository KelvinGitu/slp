import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/theme_preference.dart';
import 'package:solartide/core/providers/theme_provider.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/tab_page.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/settings/views/widgets/delete_account_sheet.dart';

final _versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final theme = await showOptionSheet<ThemePreference>(
      context,
      title: 'Theme',
      selected: ref.read(themeNotifierProvider),
      options: const [
        SheetOption(value: ThemePreference.system, title: 'System', subtitle: 'Follow the phone or computer.', icon: PhosphorIconsRegular.deviceMobile),
        SheetOption(value: ThemePreference.light, title: 'Light', icon: PhosphorIconsRegular.sun),
        SheetOption(value: ThemePreference.dark, title: 'Dark', icon: PhosphorIconsRegular.moon),
      ],
    );
    if (theme != null) await ref.read(themeNotifierProvider.notifier).setTheme(theme);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmSheet(
      context,
      title: 'Sign out?',
      message: 'Your quotes stay saved. Sign in again to see them.',
      confirmLabel: 'Sign out',
    );
    if (ok) await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final business = ref.watch(businessProfileProvider).valueOrNull;
    final theme = ref.watch(themeNotifierProvider);
    final version = ref.watch(_versionProvider).valueOrNull;

    Widget gapped(List<Widget> rows) => Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: AppSpace.lg), rows[i]],
          ],
        );

    return TabPage(
      title: 'Settings',
      children: [
        ContentCard(
          title: 'Business',
          child: gapped([
            ListRow(
              leading: EventAvatar(accent: p.sky, icon: PhosphorIconsRegular.storefront),
              title: 'Business details',
              subtitle: business?.name ?? 'Name, logo, KRA PIN, payment',
              onPressed: () => AppNav.openBusinessProfile(context),
            ),
            ListRow(
              leading: EventAvatar(accent: p.lavender, icon: PhosphorIconsRegular.tag),
              title: 'Price catalogue',
              subtitle: 'Component prices and options',
              onPressed: () => AppNav.openCatalogue(context),
            ),
          ]),
        ),
        const SizedBox(height: AppSpace.section),
        ContentCard(
          title: 'App',
          child: gapped([
            ListRow(
              leading: EventAvatar(accent: p.neutral, icon: PhosphorIconsRegular.circleHalf),
              title: 'Theme',
              subtitle: theme.label,
              onPressed: () => _pickTheme(context, ref),
            ),
          ]),
        ),
        const SizedBox(height: AppSpace.section),
        ContentCard(
          title: 'Account',
          child: gapped([
            ListRow(
              leading: PersonAvatar(name: user?.name ?? ''),
              title: user?.name ?? '',
              subtitle: user?.email,
            ),
            ListRow(
              leading: EventAvatar(accent: p.neutral, icon: PhosphorIconsRegular.key),
              title: 'Change password',
              subtitle: "We'll email you a link.",
              onPressed: user == null
                  ? null
                  : () => ref.read(authControllerProvider.notifier).sendPasswordReset(email: user.email, context: context),
            ),
            ListRow(
              leading: EventAvatar(accent: p.neutral, icon: PhosphorIconsRegular.signOut),
              title: 'Sign out',
              onPressed: () => _signOut(context, ref),
            ),
            ListRow(
              leading: EventAvatar(accent: p.coral, icon: PhosphorIconsRegular.trash),
              title: 'Delete account',
              subtitle: 'Removes your quotes, clients and prices.',
              onPressed: () => showDeleteAccountSheet(context),
            ),
          ]),
        ),
        if (version != null) ...[
          const SizedBox(height: AppSpace.section),
          Center(child: Text('SolarTide $version', style: AppText.caption.copyWith(color: p.textSecondary))),
        ],
      ],
    );
  }
}
