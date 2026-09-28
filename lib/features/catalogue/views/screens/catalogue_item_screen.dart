import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/enums/sizing_role.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/empty_state.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/shimmer_row.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/catalogue/controller/catalogue_controller.dart';
import 'package:solartide/features/catalogue/providers/catalogue_providers.dart';
import 'package:solartide/models/catalogue_item.dart';

class CatalogueItemScreen extends ConsumerWidget {
  const CatalogueItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(catalogueProvider).hasValue;
    final item = ref.watch(catalogueByIdProvider)[itemId];
    if (item == null) {
      return SubPage(
        title: 'Component',
        children: [
          if (!loaded)
            const ShimmerRows(count: 3)
          else
            const EmptyState(
              icon: PhosphorIconsRegular.tag,
              title: 'This component is not in your catalogue.',
              message: 'Reset prices to bring back the starting list.',
            ),
        ],
      );
    }
    return _ItemEditor(key: ValueKey(itemId), item: item);
  }
}

/// Name, price(s), panel rating for sizing, notes and whether new quotes
/// include it. The kind and inputs stay as they are: they decide how the
/// quote asks for it.
class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({super.key, required this.item});

  final CatalogueItem item;

  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item.name);
  late final _price = TextEditingController(text: '${widget.item.unitPrice}');
  late final _rating = TextEditingController(text: widget.item.rating?.toString() ?? '');
  late final _notes = TextEditingController(text: widget.item.notes.join('\n'));
  late final _optionLabels = [for (final o in widget.item.options) TextEditingController(text: o.label)];
  late final _optionPrices = [for (final o in widget.item.options) TextEditingController(text: '${o.price}')];
  late bool _active = widget.item.active;

  CatalogueItem get _item => widget.item;

  bool get _usesUnitPrice => _item.kind != ComponentKind.custom && _item.options.isEmpty;

  @override
  void dispose() {
    for (final c in [_name, _price, _rating, _notes, ..._optionLabels, ..._optionPrices]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = _item.copyWith(
      name: _name.text.trim(),
      unitPrice: int.tryParse(_price.text) ?? _item.unitPrice,
      rating: int.tryParse(_rating.text),
      notes: _notes.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      options: [
        for (var i = 0; i < _item.options.length; i++)
          _item.options[i].copyWith(label: _optionLabels[i].text.trim(), price: int.tryParse(_optionPrices[i].text)),
      ],
      active: _active,
    );
    final ok = await ref.read(catalogueControllerProvider.notifier).save(updated, context);
    if (ok && mounted) await Navigator.of(context).maybePop();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required.' : null;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final saving = ref.watch(catalogueControllerProvider);
    const gap = SizedBox(height: AppSpace.lg);

    return SubPage(
      title: _item.name,
      bottom: PrimaryButton(label: 'Save', isLoading: saving, onPressed: _save),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_item.kind.label, style: AppText.label.copyWith(color: p.textSecondary)),
              const SizedBox(height: AppSpace.md),
              AppTextField(label: 'Name', controller: _name, validator: _required),
              if (_usesUnitPrice) ...[
                gap,
                AppTextField.number(
                  label: _item.kind == ComponentKind.fixed ? 'Price (KES)' : 'Price per ${_item.unit} (KES)',
                  controller: _price,
                  validator: _required,
                ),
              ],
              if (_item.sizingRole == SizingRole.panel) ...[
                gap,
                AppTextField.number(
                  label: 'Panel rating (W)',
                  controller: _rating,
                  hint: '450',
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'The sizing calculator needs this.' : null,
                ),
              ],
              if (_item.options.isNotEmpty) ...[
                const SectionLabel('Options'),
                for (var i = 0; i < _item.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(label: 'Option', controller: _optionLabels[i], validator: _required),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          flex: 2,
                          child: AppTextField.number(
                            label: _item.options[i].unit == 'piece' ? 'KES' : 'KES / ${_item.options[i].unit}',
                            controller: _optionPrices[i],
                            validator: _required,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SectionLabel('Notes for the installer'),
              AppTextField(
                label: 'One per line',
                controller: _notes,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
              gap,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: Text('On new quotes', style: AppText.bodyStrong.copyWith(color: p.textPrimary)),
                subtitle: Text(
                  _active ? 'Listed on every new quote.' : 'Hidden from new quotes. Existing quotes keep it.',
                  style: AppText.label.copyWith(color: p.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
