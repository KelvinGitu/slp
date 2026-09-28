import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/features/clients/providers/client_providers.dart';
import 'package:solartide/features/clients/views/widgets/client_form_sheet.dart';
import 'package:solartide/features/clients/views/widgets/client_row.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/controller/quote_controller.dart';
import 'package:solartide/features/quotes/views/widgets/search_field.dart';
import 'package:solartide/models/client_model.dart';

enum _Start { blank, sizing }

/// New quote: pick (or add) the client, then start blank or from the sizing
/// calculator. With [client] given, goes straight to the second step.
Future<void> showNewQuoteSheet(BuildContext context, {ClientModel? client}) async {
  final picked = client ?? await pickClient(context);
  if (picked == null || !context.mounted) return;

  final start = await showOptionSheet<_Start>(
    context,
    title: 'Quote for ${picked.name}',
    options: const [
      SheetOption(
        value: _Start.sizing,
        title: 'Size the system first',
        subtitle: 'Enter the load and location; panels, inverter and batteries are filled in.',
        icon: PhosphorIconsRegular.lightning,
      ),
      SheetOption(
        value: _Start.blank,
        title: 'Start blank',
        subtitle: 'Go through the components yourself.',
        icon: PhosphorIconsRegular.listChecks,
      ),
    ],
  );
  if (start == null || !context.mounted) return;

  if (start == _Start.sizing) {
    AppNav.openSizing(context, clientId: picked.id);
    return;
  }
  final container = ProviderScope.containerOf(context, listen: false);
  final id = await container.read(quoteControllerProvider.notifier).create(client: picked, context: context);
  if (id != null && context.mounted) AppNav.openQuote(context, id);
}

/// Choose an existing client or add one. Null if dismissed.
Future<ClientModel?> pickClient(BuildContext context) async {
  final result = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
    builder: (_) => const _ClientPicker(),
  );
  if (result is ClientModel) return result;
  // "New client" closes the picker and opens the form, rather than stacking
  // two sheets.
  if (result == _newClient && context.mounted) return showClientFormSheet(context);
  return null;
}

const _newClient = 'new';

class _ClientPicker extends ConsumerStatefulWidget {
  const _ClientPicker();

  @override
  ConsumerState<_ClientPicker> createState() => _ClientPickerState();
}

class _ClientPickerState extends ConsumerState<_ClientPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final all = ref.watch(clientsProvider).valueOrNull ?? const <ClientModel>[];
    final q = _query.trim().toLowerCase();
    final clients = q.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(q) || (c.phone?.contains(q) ?? false)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoint.mediumMaxContent),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenH),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Who is it for?', style: AppText.title1.copyWith(color: p.textPrimary))),
                      PillButton(
                        label: 'New client',
                        icon: PhosphorIconsRegular.userPlus,
                        onPressed: () => Navigator.of(context).pop(_newClient),
                      ),
                    ],
                  ),
                  if (all.length > 5) ...[
                    const SizedBox(height: AppSpace.lg),
                    SearchField(hint: 'Search clients', onChanged: (v) => setState(() => _query = v)),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  Flexible(
                    child: all.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: AppSpace.xl),
                            child: ListRow(
                              leading: EventAvatar(accent: p.green, icon: PhosphorIconsRegular.userPlus),
                              title: 'Add your first client',
                              subtitle: 'Name and phone are enough to start.',
                              onPressed: () => Navigator.of(context).pop(_newClient),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: AppSpace.xl),
                            itemCount: clients.length,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpace.lg),
                            itemBuilder: (_, i) => ClientRow(
                              client: clients[i],
                              onPressed: () => Navigator.of(context).pop(clients[i]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
