import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_text.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/app_text_field.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/hero_value.dart';
import 'package:solartide/core/widgets/inline_banner.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/core/widgets/option_sheet.dart';
import 'package:solartide/core/widgets/pill_button.dart';
import 'package:solartide/core/widgets/primary_button.dart';
import 'package:solartide/core/widgets/sub_page.dart';
import 'package:solartide/features/catalogue/providers/catalogue_providers.dart';
import 'package:solartide/features/clients/providers/client_providers.dart';
import 'package:solartide/features/home/controller/app_nav.dart';
import 'package:solartide/features/quotes/controller/quote_controller.dart';
import 'package:solartide/features/quotes/views/widgets/new_quote_sheet.dart';
import 'package:solartide/features/sizing/data/kenya_counties.dart';
import 'package:solartide/features/sizing/logic/sizing_calculator.dart';
import 'package:solartide/features/sizing/providers/sizing_providers.dart';
import 'package:solartide/features/sizing/views/widgets/appliance_sheet.dart';
import 'package:solartide/features/sizing/views/widgets/sizing_result_card.dart';
import 'package:solartide/models/client_model.dart';
import 'package:solartide/models/sizing_result.dart';

enum _LoadMode { appliances, monthly }

/// Load, location and storage in; panels, inverter and batteries out, priced
/// from the installer's own catalogue. "Start quote" fills those lines.
class SizingScreen extends ConsumerStatefulWidget {
  const SizingScreen({super.key, this.clientId});

  /// Set when started from a client or from the new-quote sheet.
  final String? clientId;

  @override
  ConsumerState<SizingScreen> createState() => _SizingScreenState();
}

class _SizingScreenState extends ConsumerState<SizingScreen> {
  _LoadMode _mode = _LoadMode.appliances;
  final _appliances = <Appliance>[...appliancePresets.take(4)];
  final _monthlyKwh = TextEditingController();
  final _peakWatts = TextEditingController();
  late SiteLocation _place = _initialPlace();
  bool _batteries = true;
  int _autonomy = 1;
  int _voltage = 24;

  static const _voltages = [12, 24, 48];
  static const _autonomyDays = [1, 2, 3];
  static const _daysPerMonth = 30;

  /// The client's county when their location names one, else Nairobi.
  SiteLocation _initialPlace() {
    final id = widget.clientId;
    final location = id == null ? null : ref.read(clientProvider(id))?.location?.toLowerCase();
    if (location != null) {
      for (final c in kenyaCounties) {
        if (location.contains(c.name.split(' ').first.toLowerCase())) return c;
      }
    }
    return kenyaCounties.firstWhere((c) => c.name == 'Nairobi');
  }

  @override
  void dispose() {
    _monthlyKwh.dispose();
    _peakWatts.dispose();
    super.dispose();
  }

  SizingInput _input(double psh, SunHoursSource source) {
    if (_mode == _LoadMode.appliances) {
      return SizingInput.fromAppliances(
        _appliances,
        peakSunHours: psh,
        sunHoursSource: source,
        withBatteries: _batteries,
        autonomyDays: _autonomy,
        systemVoltage: _voltage,
        locationLabel: _place.name,
      );
    }
    return SizingInput(
      dailyWh: (int.tryParse(_monthlyKwh.text) ?? 0) * 1000 / _daysPerMonth,
      peakWatts: int.tryParse(_peakWatts.text) ?? 0,
      peakSunHours: psh,
      sunHoursSource: source,
      withBatteries: _batteries,
      autonomyDays: _autonomy,
      systemVoltage: _voltage,
      locationLabel: _place.name,
    );
  }

  Future<void> _pickPlace() async {
    final place = await showOptionSheet<SiteLocation>(
      context,
      title: 'Where is the installation?',
      selected: _place,
      options: [for (final c in kenyaCounties) SheetOption(value: c, title: c.name, icon: PhosphorIconsRegular.mapPin)],
    );
    if (place != null) setState(() => _place = place);
  }

  Future<void> _editAppliance([int? index]) async {
    final result = await showApplianceSheet(context, appliance: index == null ? null : _appliances[index]);
    if (result == null) return;
    setState(() => index == null ? _appliances.add(result) : _appliances[index] = result);
  }

  Future<void> _startQuote(SizingResult result) async {
    final id = widget.clientId;
    final ClientModel? client = id != null ? ref.read(clientProvider(id)) : await pickClient(context);
    if (client == null || !mounted) return;
    final quoteId = await ref.read(quoteControllerProvider.notifier).create(client: client, sizing: result, context: context);
    if (quoteId != null && mounted) AppNav.openQuote(context, quoteId, replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sun = ref.watch(sunHoursProvider(_place));
    final catalogue = ref.watch(catalogueProvider).valueOrNull ?? const [];
    final creating = ref.watch(quoteControllerProvider);

    final fetched = sun.valueOrNull;
    final psh = fetched?.annual ?? AppConstants.fallbackPeakSunHours;
    final source = fetched == null ? SunHoursSource.fallback : SunHoursSource.nasaPower;
    final result = SizingCalculator.size(_input(psh, source), catalogue);
    final ready = result.dailyWh > 0 && result.panelCount > 0;

    return SubPage(
      title: 'Size a system',
      bottom: PrimaryButton(
        label: widget.clientId == null ? 'Start a quote with this' : 'Start the quote',
        isLoading: creating,
        onPressed: ready ? () => _startQuote(result) : null,
      ),
      children: [
        HeroValue(
          label: 'Suggested array',
          value: ready ? '${result.panelCount} × ${result.panelWatts} W' : 'Add the load',
          note: ready ? '${formatPower(result.arrayWatts)} for ${formatEnergy(result.dailyWh)} a day' : null,
        ),
        const SectionLabel('Load'),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            PillButton(
              label: 'Appliances',
              selected: _mode == _LoadMode.appliances,
              onPressed: () => setState(() => _mode = _LoadMode.appliances),
            ),
            PillButton(
              label: 'Monthly bill',
              selected: _mode == _LoadMode.monthly,
              onPressed: () => setState(() => _mode = _LoadMode.monthly),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        if (_mode == _LoadMode.appliances)
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _appliances.length; i++) ...[
                  _ApplianceRow(
                    appliance: _appliances[i],
                    onPressed: () => _editAppliance(i),
                    onRemove: () => setState(() => _appliances.removeAt(i)),
                  ),
                  const SizedBox(height: AppSpace.lg),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: PillButton(label: 'Add appliance', icon: PhosphorIconsRegular.plus, onPressed: _editAppliance),
                ),
              ],
            ),
          )
        else ...[
          AppTextField.number(
            label: 'Units per month (kWh), from the KPLC bill',
            controller: _monthlyKwh,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpace.lg),
          AppTextField.number(
            label: 'Biggest load at one time (W)',
            controller: _peakWatts,
            hint: 'Pump, fridge and lights together',
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SectionLabel('Location'),
        ContentCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.sm),
          child: ListRow(
            leading: EventAvatar(accent: p.amber, icon: PhosphorIconsRegular.sun),
            title: _place.name,
            subtitle: sun.isLoading
                ? 'Getting sun hours'
                : fetched == null
                    ? 'Using ${AppConstants.fallbackPeakSunHours} sun hours'
                    : '${fetched.annual.toStringAsFixed(1)} sun hours a day, '
                        '${fetched.lowestMonth.toStringAsFixed(1)} in the dullest month',
            trailing: Icon(PhosphorIconsRegular.caretRight, size: AppSize.iconInline, color: p.textSecondary),
            onPressed: _pickPlace,
          ),
        ),
        if (!sun.isLoading && fetched == null) ...[
          const SizedBox(height: AppSpace.md),
          InlineBanner(
            accent: p.neutral,
            icon: PhosphorIconsRegular.wifiSlash,
            message: "You're offline, so this uses a typical ${AppConstants.fallbackPeakSunHours} sun hours for Kenya.",
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(sunHoursProvider(_place)),
          ),
        ],
        const SectionLabel('Batteries'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _batteries,
          onChanged: (v) => setState(() => _batteries = v),
          title: Text('Include batteries', style: AppText.bodyStrong.copyWith(color: p.textPrimary)),
          subtitle: Text('For power at night and during blackouts.', style: AppText.label.copyWith(color: p.textSecondary)),
        ),
        if (_batteries) ...[
          const SizedBox(height: AppSpace.sm),
          _Choice(
            label: 'Days of backup',
            values: _autonomyDays,
            selected: _autonomy,
            format: (d) => d == 1 ? '1 day' : '$d days',
            onSelected: (d) => setState(() => _autonomy = d),
          ),
          const SizedBox(height: AppSpace.lg),
          _Choice(
            label: 'Battery bank voltage',
            values: _voltages,
            selected: _voltage,
            format: (v) => '$v V',
            onSelected: (v) => setState(() => _voltage = v),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        SizingResultCard(result: result, catalogue: catalogue),
      ],
    );
  }
}

class _ApplianceRow extends StatelessWidget {
  const _ApplianceRow({required this.appliance, required this.onPressed, required this.onRemove});

  final Appliance appliance;
  final VoidCallback onPressed;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = appliance;
    final hours = a.hoursPerDay == a.hoursPerDay.roundToDouble() ? '${a.hoursPerDay.round()}' : '${a.hoursPerDay}';
    return ListRow(
      leading: EventAvatar(accent: p.sky, icon: PhosphorIconsRegular.plug),
      title: a.name,
      subtitle: '${a.quantity} × ${a.watts} W, $hours h a day - ${formatEnergy(a.dailyWh)}',
      trailing: IconButton(
        tooltip: 'Remove ${a.name}',
        icon: Icon(PhosphorIconsRegular.x, size: AppSize.iconInline, color: p.textSecondary),
        onPressed: onRemove,
      ),
      onPressed: onPressed,
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.values,
    required this.selected,
    required this.format,
    required this.onSelected,
  });

  final String label;
  final List<int> values;
  final int selected;
  final String Function(int) format;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: p.textSecondary)),
        const SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            for (final v in values)
              PillButton(label: format(v), selected: v == selected, onPressed: () => onSelected(v)),
          ],
        ),
      ],
    );
  }
}
