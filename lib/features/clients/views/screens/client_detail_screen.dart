import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/utils/launch.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/detail_panel.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/hero_value.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/clients/controller/client_controller.dart';
import 'package:solartide/features/clients/providers/client_providers.dart';
import 'package:solartide/features/clients/views/widgets/client_form_sheet.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/providers/quote_providers.dart';
import 'package:solartide/features/quotes/views/widgets/new_quote_sheet.dart';
import 'package:solartide/features/quotes/views/widgets/quote_row.dart';
import 'package:solartide/models/client_model.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  Future<void> _delete(BuildContext context, WidgetRef ref, ClientModel client) async {
    final ok = await showConfirmSheet(
      context,
      title: 'Delete ${client.name}?',
      message: 'Their quotes are kept, with the client details they were sent with.',
      confirmLabel: 'Delete client',
    );
    if (!ok || !context.mounted) return;
    final deleted = await ref.read(clientControllerProvider.notifier).delete(client, context);
    if (deleted && context.mounted) await closeSubPage(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final loaded = ref.watch(clientsProvider).hasValue;
    final client = ref.watch(clientProvider(clientId));
    final quotes = ref.watch(clientQuotesProvider(clientId));

    if (client == null) {
      return SubPage(
        title: 'Client',
        children: [
          if (!loaded)
            const ShimmerRows(count: 3)
          else
            const EmptyState(
              icon: PhosphorIconsRegular.userMinus,
              title: 'This client was deleted.',
              message: 'Their quotes are still under Quotes.',
            ),
        ],
      );
    }

    final won = quotes.where((q) => q.status.isWon).fold<int>(0, (sum, q) => sum + q.totals.total);

    return SubPage(
      title: client.name,
      actions: [
        IconButton(
          tooltip: 'Edit client',
          icon: Icon(PhosphorIconsRegular.pencilSimple, size: AppSize.iconInline, color: p.textPrimary),
          onPressed: () => showClientFormSheet(context, client: client),
        ),
        IconButton(
          tooltip: 'Delete client',
          icon: Icon(PhosphorIconsRegular.trash, size: AppSize.iconInline, color: p.textPrimary),
          onPressed: () => _delete(context, ref, client),
        ),
      ],
      bottom: PrimaryButton(label: 'New quote', onPressed: () => showNewQuoteSheet(context, client: client)),
      children: [
        HeroValue(
          label: 'Won from this client',
          value: formatKes(won),
          note: [
            client.location,
            '${quotes.length} ${quotes.length == 1 ? 'quote' : 'quotes'}',
            'client since ${formatShortDate(client.createdAt)}',
          ].whereType<String>().join(' - '),
        ),
        const SizedBox(height: AppSpace.section),
        PillActionRow(
          actions: [
            PillAction(
              label: 'Call',
              icon: PhosphorIconsRegular.phone,
              onPressed: client.phone == null ? null : () => callNumber(context, client.phone),
            ),
            PillAction(
              label: 'WhatsApp',
              icon: PhosphorIconsRegular.whatsappLogo,
              onPressed: client.phone == null
                  ? null
                  : () => openWhatsApp(context, client.phone, text: 'Hello ${client.name.split(' ').first}, '),
            ),
            PillAction(
              label: 'Size',
              icon: PhosphorIconsRegular.lightning,
              onPressed: () => AppNav.openSizing(context, clientId: client.id),
            ),
          ],
        ),
        if (client.notes != null || client.email != null) ...[
          const SizedBox(height: AppSpace.section),
          ContentCard(
            title: 'Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (client.email != null) _Detail(icon: PhosphorIconsRegular.envelopeSimple, text: client.email!),
                if (client.notes != null) _Detail(icon: PhosphorIconsRegular.note, text: client.notes!),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        ContentCard(
          title: 'Quotes',
          child: quotes.isEmpty
              ? const EmptyState(
                  icon: PhosphorIconsRegular.fileText,
                  title: 'No quotes for this client yet.',
                  message: 'Tap New quote to start one.',
                )
              : Column(
                  children: [
                    for (var i = 0; i < quotes.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpace.lg),
                      QuoteRow(quote: quotes[i], showClient: false, onPressed: () => AppNav.openQuote(context, quotes[i].id)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSize.iconInline, color: p.textSecondary),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(text, style: AppText.body.copyWith(color: p.textPrimary))),
        ],
      ),
    );
  }
}
