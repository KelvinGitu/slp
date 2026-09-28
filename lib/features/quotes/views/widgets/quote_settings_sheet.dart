import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/features/quotes/controller/quote_controller.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/models/quote_model.dart';

/// Markup, VAT and the note printed on this quote. Business defaults are in
/// Settings; these override them for one quote.
Future<void> showQuoteSettingsSheet(BuildContext context, QuoteModel quote) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      sheetAnimationStyle: const AnimationStyle(duration: AppDuration.sheet, curve: Curves.easeOutCubic),
      builder: (_) => _QuoteSettings(quote: quote),
    );

class _QuoteSettings extends ConsumerStatefulWidget {
  const _QuoteSettings({required this.quote});

  final QuoteModel quote;

  @override
  ConsumerState<_QuoteSettings> createState() => _QuoteSettingsState();
}

class _QuoteSettingsState extends ConsumerState<_QuoteSettings> {
  final _formKey = GlobalKey<FormState>();
  late final _markup = TextEditingController(text: _pct(widget.quote.markupPercent));
  late final _vat = TextEditingController(text: _pct(widget.quote.vatPercent));
  late final _notes = TextEditingController(text: widget.quote.notes);

  static String _pct(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void dispose() {
    _markup.dispose();
    _vat.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notes = _notes.text.trim();
    final updated = QuoteCalculator.withRates(
      widget.quote,
      markupPercent: double.parse(_markup.text),
      vatPercent: double.parse(_vat.text),
    ).copyWith(notes: notes);
    final ok = await ref.read(quoteControllerProvider.notifier).save(updated, context);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final saving = ref.watch(quoteControllerProvider);
    String? percent(String? v) {
      final n = double.tryParse(v ?? '');
      return (n == null || n < 0 || n > 100) ? 'Between 0 and 100.' : null;
    }

    final formatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?'))];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screenH, 0, AppSpace.screenH, AppSpace.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Quote settings', style: AppText.title1.copyWith(color: p.textPrimary)),
                const SizedBox(height: AppSpace.xs),
                Text(
                  'For this quote only. Change the defaults in Settings.',
                  style: AppText.label.copyWith(color: p.textSecondary),
                ),
                const SizedBox(height: AppSpace.section),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Markup %',
                        controller: _markup,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: formatters,
                        validator: percent,
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: AppTextField(
                        label: 'VAT %',
                        controller: _vat,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: formatters,
                        validator: percent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.lg),
                AppTextField(
                  label: 'Note on the quote',
                  controller: _notes,
                  hint: 'Warranty, lead time, what is excluded',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpace.section),
                PrimaryButton(label: 'Save', isLoading: saving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
