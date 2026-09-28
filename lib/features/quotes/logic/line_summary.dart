import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/models/quote_model.dart';

/// One line describing what was chosen, for list rows and the PDF:
/// "12 panels × KES 10,000", "31 m of 10 mm²", "2 × 200 Ah".
String lineSummary(QuoteLine line) {
  switch (line.kind) {
    case ComponentKind.fixed:
      return formatKes(line.unitPrice);
    case ComponentKind.quantity:
      return '${formatUnits(line.quantity, line.unit)} × ${formatKes(line.unitPrice)}';
    case ComponentKind.length:
      final s = line.selections.isEmpty ? null : line.selections.first;
      return s == null
          ? '${formatUnits(line.quantity, 'm')} × ${formatKes(line.unitPrice)}'
          : '${formatUnits(line.quantity, 'm')} of ${s.label}';
    case ComponentKind.choice:
      if (line.selections.isEmpty) return 'Nothing chosen';
      final s = line.selections.first;
      return s.quantity == 1 && s.unit == 'piece' ? s.label : '${_count(s)} ${s.label}';
    case ComponentKind.multi:
      if (line.selections.isEmpty) return 'Nothing chosen';
      return line.selections.map((s) => '${_count(s)} ${s.label}').join(', ');
    case ComponentKind.custom:
      final d = line.description?.trim() ?? '';
      return d.isEmpty ? 'Custom amount' : d;
  }
}

/// Per-selection detail rows for the components list PDF.
List<String> selectionDetails(QuoteLine line) => [
      for (final s in line.selections) '${_count(s)} ${s.label} @ ${formatKes(s.unitPrice)}',
    ];

/// "2 ×" for pieces, "15 m of" for anything measured.
String _count(LineSelection s) =>
    s.unit == 'piece' ? '${s.quantity} ×' : '${formatUnits(s.quantity, s.unit)} of';
