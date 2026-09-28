import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/tab_page.dart';
import 'package:solartide/features/clients/providers/client_providers.dart';
import 'package:solartide/features/clients/views/widgets/client_form_sheet.dart';
import 'package:solartide/features/clients/views/widgets/client_row.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/views/widgets/search_field.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final client = await showClientFormSheet(context);
    if (client != null && context.mounted) AppNav.openClient(context, client.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(filteredClientsProvider);
    final searching = ref.watch(clientSearchProvider).isNotEmpty;

    return TabPage(
      title: 'Clients',
      trailing: PillButton(label: 'Add', icon: PhosphorIconsRegular.plus, onPressed: () => _add(context)),
      children: [
        SearchField(
          hint: 'Search by name, phone or place',
          onChanged: (v) => ref.read(clientSearchProvider.notifier).state = v,
        ),
        const SizedBox(height: AppSpace.lg),
        ContentCard(
          child: clients.when(
            loading: () => const ShimmerRows(count: 4),
            error: (_, _) => const EmptyState(
              icon: PhosphorIconsRegular.wifiSlash,
              title: "Couldn't load your clients.",
              message: 'Check your connection and try again.',
            ),
            data: (list) {
              if (list.isEmpty) {
                return searching
                    ? const EmptyState(
                        icon: PhosphorIconsRegular.magnifyingGlass,
                        title: 'No matching clients.',
                        message: 'Try part of the name or phone number.',
                      )
                    : EmptyState(
                        icon: PhosphorIconsRegular.usersThree,
                        title: 'No clients yet.',
                        message: 'Add the people you quote for, or add them as you start a quote.',
                        action: PillButton(
                          label: 'Add client',
                          icon: PhosphorIconsRegular.userPlus,
                          onPressed: () => _add(context),
                        ),
                      );
              }
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpace.lg),
                    ClientRow(client: list[i], onPressed: () => AppNav.openClient(context, list[i].id)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
