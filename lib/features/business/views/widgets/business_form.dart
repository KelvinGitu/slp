import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/models/business_profile.dart';

/// The business details form, used by first-run setup ([compact]: name and
/// contacts only) and by Settings (everything).
///
/// Read the result with `key.currentState!.value()`, which validates first
/// and returns null if something needs fixing.
class BusinessForm extends StatefulWidget {
  const BusinessForm({super.key, this.initial, this.compact = false, this.logoUrl});

  final BusinessProfile? initial;
  final bool compact;

  /// Carried through unchanged; the logo has its own picker.
  final String? logoUrl;

  @override
  State<BusinessForm> createState() => BusinessFormState();
}

class BusinessFormState extends State<BusinessForm> {
  final _formKey = GlobalKey<FormState>();
  late final _c = <String, TextEditingController>{};

  TextEditingController _field(String key, String? initial) =>
      _c.putIfAbsent(key, () => TextEditingController(text: initial ?? ''));

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(String key) {
    final v = _c[key]?.text.trim() ?? '';
    return v.isEmpty ? null : v;
  }

  /// Validated profile, or null. Keeps the fields the form doesn't show
  /// (payment details during setup, the quote counter) from [initial].
  BusinessProfile? value({String? logoUrl}) {
    if (!(_formKey.currentState?.validate() ?? false)) return null;
    final i = widget.initial ?? const BusinessProfile(name: '');
    double pct(String key, double fallback) => double.tryParse(_text(key) ?? '') ?? fallback;
    return BusinessProfile(
      name: _text('name') ?? '',
      logoUrl: logoUrl ?? widget.logoUrl ?? i.logoUrl,
      phone: _text('phone'),
      email: _text('email'),
      address: _text('address'),
      kraPin: widget.compact ? i.kraPin : _text('kraPin')?.toUpperCase(),
      mpesaPaybill: widget.compact ? i.mpesaPaybill : _text('mpesaPaybill'),
      mpesaAccount: widget.compact ? i.mpesaAccount : _text('mpesaAccount'),
      mpesaTill: widget.compact ? i.mpesaTill : _text('mpesaTill'),
      bankName: widget.compact ? i.bankName : _text('bankName'),
      bankAccountName: widget.compact ? i.bankAccountName : _text('bankAccountName'),
      bankAccountNumber: widget.compact ? i.bankAccountNumber : _text('bankAccountNumber'),
      bankBranch: widget.compact ? i.bankBranch : _text('bankBranch'),
      vatPercent: widget.compact ? i.vatPercent : pct('vat', i.vatPercent),
      markupPercent: widget.compact ? i.markupPercent : pct('markup', i.markupPercent),
      quoteValidityDays: widget.compact ? i.quoteValidityDays : int.tryParse(_text('validity') ?? '') ?? i.quoteValidityDays,
      quotePrefix: widget.compact ? i.quotePrefix : (_text('prefix') ?? i.quotePrefix).toUpperCase(),
      nextQuoteNumber: i.nextQuoteNumber,
      quoteNumberYear: i.quoteNumberYear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.initial;
    const gap = SizedBox(height: AppSpace.lg);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Business name',
            controller: _field('name', i?.name),
            icon: PhosphorIconsRegular.storefront,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the name to print on quotes.' : null,
          ),
          gap,
          AppTextField(
            label: 'Phone',
            controller: _field('phone', i?.phone),
            hint: '0712 345 678',
            icon: PhosphorIconsRegular.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          gap,
          AppTextField(
            label: 'Email',
            controller: _field('email', i?.email),
            icon: PhosphorIconsRegular.envelopeSimple,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) => (v != null && v.trim().isNotEmpty && !v.contains('@')) ? 'That email looks wrong.' : null,
          ),
          gap,
          AppTextField(
            label: 'Address',
            controller: _field('address', i?.address),
            hint: 'Street, town',
            icon: PhosphorIconsRegular.mapPin,
            textCapitalization: TextCapitalization.words,
            maxLines: 2,
          ),
          if (!widget.compact) ...[
            gap,
            AppTextField(
              label: 'KRA PIN',
              controller: _field('kraPin', i?.kraPin),
              hint: 'P051234567X',
              icon: PhosphorIconsRegular.identificationCard,
              textCapitalization: TextCapitalization.characters,
            ),
            const SectionLabel('M-Pesa'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: AppTextField.number(label: 'Paybill', controller: _field('mpesaPaybill', i?.mpesaPaybill))),
                const SizedBox(width: AppSpace.md),
                Expanded(child: AppTextField(label: 'Account', controller: _field('mpesaAccount', i?.mpesaAccount))),
              ],
            ),
            gap,
            AppTextField.number(label: 'Till number', controller: _field('mpesaTill', i?.mpesaTill)),
            const SectionLabel('Bank'),
            AppTextField(
              label: 'Bank',
              controller: _field('bankName', i?.bankName),
              icon: PhosphorIconsRegular.bank,
              textCapitalization: TextCapitalization.words,
            ),
            gap,
            AppTextField(
              label: 'Account name',
              controller: _field('bankAccountName', i?.bankAccountName),
              textCapitalization: TextCapitalization.words,
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField.number(label: 'Account number', controller: _field('bankAccountNumber', i?.bankAccountNumber)),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: AppTextField(
                    label: 'Branch',
                    controller: _field('bankBranch', i?.bankBranch),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SectionLabel('Quote defaults'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _PercentField(label: 'VAT %', controller: _field('vat', _pct(i?.vatPercent)))),
                const SizedBox(width: AppSpace.md),
                Expanded(child: _PercentField(label: 'Markup %', controller: _field('markup', _pct(i?.markupPercent)))),
              ],
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField.number(
                    label: 'Valid for (days)',
                    controller: _field('validity', i?.quoteValidityDays.toString()),
                    validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'At least 1 day.' : null,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: AppTextField(
                    label: 'Quote prefix',
                    controller: _field('prefix', i?.quotePrefix),
                    hint: 'ST',
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// "16" rather than "16.0".
  static String? _pct(double? v) => v == null ? null : (v == v.roundToDouble() ? v.round().toString() : v.toString());
}

class _PercentField extends StatelessWidget {
  const _PercentField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => AppTextField(
        label: label,
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?'))],
        validator: (v) {
          final n = double.tryParse(v ?? '');
          return (n == null || n < 0 || n > 100) ? 'Between 0 and 100.' : null;
        },
      );
}
