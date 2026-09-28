import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/widgets/detail_panel.dart';
import 'package:solartide/core/widgets/responsive_scaffold.dart';
import 'package:solartide/features/business/views/screens/business_profile_screen.dart';
import 'package:solartide/features/catalogue/views/screens/catalogue_screen.dart';
import 'package:solartide/features/clients/views/screens/client_detail_screen.dart';
import 'package:solartide/features/clients/views/screens/clients_screen.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/home/views/screens/home_screen.dart';
import 'package:solartide/features/quotes/views/screens/quote_screen.dart';
import 'package:solartide/features/quotes/views/screens/quotes_screen.dart';
import 'package:solartide/features/settings/views/screens/settings_screen.dart';

/// Home, Quotes, Clients, Settings (STYLE_GUIDE §5.9). The tab lives in
/// [appTabProvider] so detail panels and deep links can switch it. On a wide
/// layout each list tab shows its selection in a panel beside it (§6.3).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(appTabProvider);
    final selection = ref.watch(detailSelectionProvider);
    void close() => AppNav.closeDetail(context);

    Widget withDetail(Widget master, Widget? detail) => MasterDetail(master: master, detail: detail, onClose: close);

    return ResponsiveScaffold(
      selectedIndex: tab.index,
      onSelected: (i) => AppNav.openTab(context, AppTab.values[i]),
      items: const [
        NavItem(label: 'Home', icon: PhosphorIconsRegular.house, selectedIcon: PhosphorIconsFill.house),
        NavItem(label: 'Quotes', icon: PhosphorIconsRegular.fileText, selectedIcon: PhosphorIconsFill.fileText),
        NavItem(label: 'Clients', icon: PhosphorIconsRegular.usersThree, selectedIcon: PhosphorIconsFill.usersThree),
        NavItem(label: 'Settings', icon: PhosphorIconsRegular.gearSix, selectedIcon: PhosphorIconsFill.gearSix),
      ],
      body: IndexedStack(
        index: tab.index,
        children: [
          const HomeScreen(),
          withDetail(
            const QuotesScreen(),
            switch (selection) {
              QuoteSelection(:final quoteId) => QuoteScreen(key: ValueKey(quoteId), quoteId: quoteId),
              _ => null,
            },
          ),
          withDetail(
            const ClientsScreen(),
            switch (selection) {
              ClientSelection(:final clientId) => ClientDetailScreen(key: ValueKey(clientId), clientId: clientId),
              _ => null,
            },
          ),
          withDetail(
            const SettingsScreen(),
            switch (selection) {
              BusinessSelection() => const BusinessProfileScreen(),
              CatalogueSelection() => const CatalogueScreen(),
              _ => null,
            },
          ),
        ],
      ),
    );
  }
}
