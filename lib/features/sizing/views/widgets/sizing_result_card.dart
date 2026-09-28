import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:solartide/core/enums/sizing_role.dart';
import 'package:solartide/core/theme/app_palette.dart';
import 'package:solartide/core/theme/app_tokens.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/widgets/content_card.dart';
import 'package:solartide/core/widgets/inline_banner.dart';
import 'package:solartide/core/widgets/list_row.dart';
import 'package:solartide/features/sizing/logic/sizing_calculator.dart';
import 'package:solartide/models/catalogue_item.dart';
import 'package:solartide/models/sizing_result.dart';

/// What the calculator picked, named as the catalogue names it.
class SizingResultCard extends StatelessWidget {
  const SizingResultCard({super.key, required this.result, required this.catalogue});

  final SizingResult result;
  final List<CatalogueItem> catalogue;

  CatalogueOption? _option(SizingRole role, String? id) {
    if (id == null) return null;
    for (final i in catalogue) {
      if (i.sizingRole == role) return i.optionById(id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = result;
    final inverter = _option(SizingRole.inverter, r.inverterOptionId);
    final battery = _option(SizingRole.battery, r.batteryOptionId);

    return ContentCard(
      title: 'Suggested system',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListRow(
            leading: EventAvatar(accent: p.amber, icon: PhosphorIconsRegular.solarPanel),
            title: 'Panels',
            subtitle: r.panelCount == 0
                ? 'Add the load first'
                : '${r.panelCount} × ${r.panelWatts} W = ${formatPower((r.panelCount * r.panelWatts).toDouble())}',
          ),
          const SizedBox(height: AppSpace.lg),
          ListRow(
            leading: EventAvatar(accent: p.sky, icon: PhosphorIconsRegular.lightning),
            title: 'Inverter',
            subtitle: inverter != null
                ? '${inverter.label}, for a peak of ${formatPower(r.inverterWatts)}'
                : 'At least ${formatPower(r.inverterWatts)}',
          ),
          const SizedBox(height: AppSpace.lg),
          ListRow(
            leading: EventAvatar(accent: p.green, icon: PhosphorIconsRegular.batteryFull),
            title: 'Batteries',
            subtitle: r.batteryWh <= 0
                ? 'None'
                : battery != null
                    ? '${r.batteryCount} × ${battery.label} at ${r.systemVoltage} V, ${formatEnergy(r.batteryWh)} usable'
                    : '${formatEnergy(r.batteryWh)} needed',
          ),
          if (!SizingCalculator.inverterFits(r) && r.dailyWh > 0) ...[
            const SizedBox(height: AppSpace.lg),
            InlineBanner(
              accent: p.amber,
              icon: PhosphorIconsRegular.warning,
              message: 'Your catalogue has no inverter this big. Add one in Prices, or pick it on the quote.',
            ),
          ],
        ],
      ),
    );
  }
}
