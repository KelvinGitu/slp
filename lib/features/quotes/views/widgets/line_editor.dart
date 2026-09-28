import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/hero_value.dart';
import 'package:solartide/core/widgets/inline_banner.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/status_chip.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/quotes/controller/quote_controller.dart';
import 'package:solartide/features/quotes/logic/line_summary.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/features/quotes/views/widgets/option_tile.dart';
import 'package:solartide/models/catalogue_item.dart';
import 'package:solartide/models/quote_model.dart';

/// The fields for one quote line, chosen by the item's [ComponentKind]. The
/// total at the top is recomputed with [QuoteCalculator] on every keystroke,
/// so what the installer sees is exactly what gets saved.
class LineEditor extends ConsumerStatefulWidget {
  const LineEditor({super.key, required this.quote, required this.item, required this.line});

  final QuoteModel quote;
  final CatalogueItem item;
  final QuoteLine line;

  @override
  ConsumerState<LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends ConsumerState<LineEditor> {
  final _inputs = <String, TextEditingController>{};
  final _multi = <String, TextEditingController>{};
  late final TextEditingController _choiceQty;
  late final TextEditingController _description;
  late final TextEditingController _amount;
  String? _optionId;

  CatalogueItem get _item => widget.item;
  QuoteLine get _line => widget.line;

  /// Suggested quantity from a linked line (MC4 = panels × 4), if any.
  int? get _linked => QuoteCalculator.linkedQuantity(_item, widget.quote);

  @override
  void initState() {
    super.initState();
    final added = _line.state == LineState.included;
    for (final (index, input) in _item.inputs.indexed) {
      // A fresh linked line starts from the suggestion.
      final initial = added
          ? _line.inputs[input.id]
          : (index == 0 ? _linked : null) ?? input.defaultValue;
      _inputs[input.id] = TextEditingController(text: initial?.toString() ?? '');
    }
    final picked = {for (final s in _line.selections) s.optionId: s};
    for (final o in _item.options) {
      _multi[o.id] = TextEditingController(text: picked[o.id]?.quantity.toString() ?? '');
    }
    _optionId = _line.selections.isEmpty ? null : _line.selections.first.optionId;
    if (_optionId == null && _item.options.length == 1) _optionId = _item.options.first.id;
    _choiceQty = TextEditingController(
      text: (added && _line.selections.isNotEmpty ? _line.selections.first.quantity : _item.defaultQuantity).toString(),
    );
    _description = TextEditingController(text: _line.description ?? '');
    _amount = TextEditingController(text: added && _line.kind == ComponentKind.custom ? '${_line.total}' : '');
  }

  @override
  void dispose() {
    for (final c in [..._inputs.values, ..._multi.values, _choiceQty, _description, _amount]) {
      c.dispose();
    }
    super.dispose();
  }

  int _n(TextEditingController c) => int.tryParse(c.text) ?? 0;

  /// The line as it would be saved right now.
  QuoteLine get _preview => QuoteCalculator.include(
        _item,
        _line,
        inputs: {for (final e in _inputs.entries) e.key: _n(e.value)},
        picks: switch (_item.kind) {
          ComponentKind.multi => [for (final e in _multi.entries) (optionId: e.key, quantity: _n(e.value))],
          _ when _optionId != null => [(optionId: _optionId!, quantity: _n(_choiceQty))],
          _ => const [],
        },
        amount: _n(_amount),
        description: _description.text,
      );

  /// What's missing before the line can be added, or null when it's ready.
  String? _missing(QuoteLine preview) => switch (_item.kind) {
        ComponentKind.fixed => null,
        ComponentKind.quantity => preview.quantity > 0 ? null : 'Fill in every number.',
        ComponentKind.length => _item.hasOptions && _optionId == null
            ? 'Pick a cable size.'
            : (preview.quantity > 0 ? null : 'Enter at least one length.'),
        ComponentKind.choice => _optionId == null
            ? 'Pick one option.'
            : (_item.askQuantity && _n(_choiceQty) < 1 ? 'Enter how many.' : null),
        ComponentKind.multi => preview.selections.isEmpty ? 'Enter a quantity for at least one item.' : null,
        ComponentKind.custom => _description.text.trim().isEmpty
            ? 'Describe what this covers.'
            : (_n(_amount) > 0 ? null : 'Enter the amount.'),
      };

  Future<void> _save(QuoteLine line) async {
    final ok = await ref.read(quoteControllerProvider.notifier).saveLine(widget.quote, line, context);
    if (ok && mounted) await Navigator.of(context).maybePop();
  }

  void _changed(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final preview = _preview;
    final missing = _missing(preview);
    final saving = ref.watch(quoteControllerProvider);
    final linked = _linked;
    final firstInput = _item.inputs.isEmpty ? null : _inputs[_item.inputs.first.id];

    return SubPage(
      title: _item.name,
      bottom: PrimaryButton(
        label: _line.state == LineState.included ? 'Update quote' : 'Add to quote',
        isLoading: saving,
        onPressed: missing == null ? () => _save(preview) : null,
      ),
      children: [
        HeroValue(
          label: 'Line cost',
          value: formatKes(preview.total),
          chip: StatusStyleChip(_line.state),
          note: missing ?? lineSummary(preview),
        ),
        if (_item.notes.isNotEmpty) ...[
          const SizedBox(height: AppSpace.section),
          ContentCard(
            title: 'What to check',
            child: Column(
              children: [for (final n in _item.notes) _Note(text: n)],
            ),
          ),
        ],
        if (linked != null && firstInput != null && _n(firstInput) != linked) ...[
          const SizedBox(height: AppSpace.lg),
          InlineBanner(
            accent: p.sky,
            icon: PhosphorIconsRegular.link,
            message: 'Suggested: $linked, from the panels on this quote.',
            actionLabel: 'Use',
            onAction: () => setState(() => firstInput.text = '$linked'),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        ..._fields(p),
        const SizedBox(height: AppSpace.section),
        Wrap(
          spacing: AppSpace.md,
          runSpacing: AppSpace.md,
          children: [
            if (_line.state != LineState.notRequired)
              PillButton(
                label: 'Not required',
                icon: PhosphorIconsRegular.minusCircle,
                outlined: true,
                onPressed: saving ? null : () => _save(QuoteCalculator.notRequired(_line)),
              ),
            if (_line.state != LineState.pending)
              PillButton(
                label: 'Back to to-do',
                icon: PhosphorIconsRegular.arrowCounterClockwise,
                outlined: true,
                onPressed: saving ? null : () => _save(_line.reset()),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _fields(AppPalette p) {
    Widget price(String text) => Padding(
          padding: const EdgeInsets.only(top: AppSpace.xs),
          child: Text(text, style: AppText.label.copyWith(color: p.textSecondary)),
        );
    Widget options({required bool multi}) => Column(
          children: [
            for (final o in _item.options)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: multi
                    ? OptionTile(
                        option: o,
                        selected: _n(_multi[o.id]!) > 0,
                        onPressed: () => setState(() => _multi[o.id]!.text = _n(_multi[o.id]!) > 0 ? '' : '1'),
                        trailing: SizedBox(
                          width: AppSize.qtyField,
                          child: AppTextField.number(
                            label: o.unit == 'piece' ? 'Qty' : o.unit,
                            controller: _multi[o.id],
                            onChanged: _changed,
                          ),
                        ),
                      )
                    : OptionTile(
                        option: o,
                        selected: _optionId == o.id,
                        onPressed: () => setState(() => _optionId = o.id),
                      ),
              ),
          ],
        );
    Widget inputs() => Column(
          children: [
            for (final i in _item.inputs)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.lg),
                child: AppTextField.number(
                  label: i.factor > 1 ? '${i.label}, counted ×${i.factor}' : i.label,
                  controller: _inputs[i.id],
                  onChanged: _changed,
                ),
              ),
          ],
        );

    switch (_item.kind) {
      case ComponentKind.fixed:
        return [price('Adds ${formatKes(_item.unitPrice)} to the quote.')];
      case ComponentKind.quantity:
        return [inputs(), price('${formatKes(_item.unitPrice)} per ${_item.unit}')];
      case ComponentKind.length:
        return [
          if (_item.hasOptions) ...[const SectionLabel('Cable size'), options(multi: false)],
          const SectionLabel('Runs'),
          inputs(),
          if (!_item.hasOptions) price('${formatKes(_item.unitPrice)} per metre'),
        ];
      case ComponentKind.choice:
        return [
          options(multi: false),
          if (_item.askQuantity) ...[
            const SizedBox(height: AppSpace.sm),
            AppTextField.number(
              label: _item.quantityLabel ?? 'How many',
              controller: _choiceQty,
              onChanged: _changed,
            ),
          ],
        ];
      case ComponentKind.multi:
        return [options(multi: true)];
      case ComponentKind.custom:
        return [
          AppTextField(
            label: 'Description',
            controller: _description,
            hint: 'What this covers',
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            onChanged: _changed,
          ),
          const SizedBox(height: AppSpace.lg),
          AppTextField.number(label: 'Amount (KES)', controller: _amount, onChanged: _changed),
        ];
    }
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsRegular.lightbulb, size: AppSize.iconInline, color: p.textSecondary),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(text, style: AppText.body.copyWith(color: p.textPrimary))),
        ],
      ),
    );
  }
}
