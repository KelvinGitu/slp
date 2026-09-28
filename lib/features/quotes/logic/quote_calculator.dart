import 'dart:math' as math;

import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/models/catalogue_item.dart';
import 'package:solartide/models/quote_model.dart';

/// An option the installer picked on a line, and how many.
typedef OptionPick = ({String optionId, int quantity});

/// All quote arithmetic. Pure functions, so every rule the 46 old component
/// pages had is covered by unit tests instead of living in button handlers.
abstract final class QuoteCalculator {
  /// Fresh lines for a new quote: one per active catalogue item, in catalogue
  /// order, all "To do".
  static List<QuoteLine> linesFor(List<CatalogueItem> catalogue) {
    final items = catalogue.where((i) => i.active).toList()..sort(compareItems);
    return [
      for (final i in items)
        QuoteLine(itemId: i.id, name: i.name, category: i.category, order: i.order, kind: i.kind, unit: i.unit),
    ];
  }

  /// Category first, then order inside it.
  static int compareItems(CatalogueItem a, CatalogueItem b) {
    final c = CatalogueCategory.rank(a.category).compareTo(CatalogueCategory.rank(b.category));
    return c != 0 ? c : a.order.compareTo(b.order);
  }

  static int compareLines(QuoteLine a, QuoteLine b) {
    final c = CatalogueCategory.rank(a.category).compareTo(CatalogueCategory.rank(b.category));
    return c != 0 ? c : a.order.compareTo(b.order);
  }

  /// Prices [line] from the installer's answers and marks it included.
  ///
  /// - [inputs]: answers to the item's inputs (counts or runs in metres).
  /// - [picks]: chosen options with quantities. For choice only the first is
  ///   used; for length it's the cross-section (quantity ignored).
  /// - [amount] and [description]: custom lines.
  ///
  /// Negative numbers count as zero.
  static QuoteLine include(
    CatalogueItem item,
    QuoteLine line, {
    Map<String, int> inputs = const {},
    List<OptionPick> picks = const [],
    int? amount,
    String? description,
  }) {
    final clean = {for (final e in inputs.entries) e.key: math.max(0, e.value)};
    final base = line.copyWith(state: LineState.included, inputs: clean, selections: const [], description: '');

    switch (item.kind) {
      case ComponentKind.fixed:
        return base.copyWith(quantity: 1, unitPrice: item.unitPrice, total: item.unitPrice);

      case ComponentKind.quantity:
        final qty = quantityOf(item, clean);
        return base.copyWith(quantity: qty, unitPrice: item.unitPrice, total: qty * item.unitPrice);

      case ComponentKind.length:
        final metres = metresOf(item, clean);
        final option = picks.isEmpty ? null : item.optionById(picks.first.optionId);
        final price = option?.price ?? item.unitPrice;
        return base.copyWith(
          quantity: metres,
          unitPrice: price,
          total: metres * price,
          selections: [
            if (option != null)
              LineSelection(
                  optionId: option.id, label: option.label, unitPrice: price, quantity: metres, unit: option.unit),
          ],
        );

      case ComponentKind.choice:
        final option = picks.isEmpty ? null : item.optionById(picks.first.optionId);
        if (option == null) return base.copyWith(quantity: 0, unitPrice: 0, total: 0);
        final qty = item.askQuantity ? math.max(0, picks.first.quantity) : 1;
        return base.copyWith(
          quantity: qty,
          unitPrice: option.price,
          total: option.price * qty,
          selections: [
            LineSelection(
                optionId: option.id, label: option.label, unitPrice: option.price, quantity: qty, unit: option.unit),
          ],
        );

      case ComponentKind.multi:
        final selections = <LineSelection>[
          for (final p in picks)
            if (item.optionById(p.optionId) case final o? when p.quantity > 0)
              LineSelection(optionId: o.id, label: o.label, unitPrice: o.price, quantity: p.quantity, unit: o.unit),
        ];
        final total = selections.fold<int>(0, (sum, s) => sum + s.total);
        return base.copyWith(quantity: selections.length, unitPrice: 0, total: total, selections: selections);

      case ComponentKind.custom:
        final value = math.max(0, amount ?? 0);
        return base.copyWith(quantity: 1, unitPrice: value, total: value, description: description?.trim() ?? '');
    }
  }

  /// Marks [line] as not needed on this installation. Clears its answers so
  /// a later "Add" starts clean.
  static QuoteLine notRequired(QuoteLine line) => line.reset().copyWith(state: LineState.notRequired);

  /// Product of the inputs, e.g. technicians × days. Inputs left blank count
  /// as zero, so a half-answered labour line costs nothing rather than
  /// guessing.
  static int quantityOf(CatalogueItem item, Map<String, int> inputs) {
    if (item.inputs.isEmpty) return math.max(0, inputs['count'] ?? 0);
    return item.inputs.fold<int>(1, (product, i) => product * math.max(0, inputs[i.id] ?? 0));
  }

  /// Σ run × factor. PV cable is 2 × roof-to-inverter + arrestor-to-earth +
  /// 2 × inverter-to-board.
  static int metresOf(CatalogueItem item, Map<String, int> inputs) =>
      item.inputs.fold<int>(0, (sum, i) => sum + math.max(0, inputs[i.id] ?? 0) * i.factor);

  /// Suggested quantity for an item that follows another line (MC4
  /// connectors = panels × 4), or null when the source isn't on the quote yet.
  static int? linkedQuantity(CatalogueItem item, QuoteModel quote) {
    final source = item.linkedItemId == null ? null : quote.lineFor(item.linkedItemId!);
    if (source == null || source.state != LineState.included) return null;
    return source.quantity * item.linkFactor;
  }

  /// Money for a set of lines. Markup is on cost; VAT on cost + markup.
  /// Rounded to whole shillings at each step, the way the PDF prints them.
  static QuoteTotals totals(List<QuoteLine> lines, {required double markupPercent, required double vatPercent}) {
    final cost = lines.where((l) => l.state == LineState.included).fold<int>(0, (sum, l) => sum + l.total);
    final markup = (cost * markupPercent / 100).round();
    final vat = ((cost + markup) * vatPercent / 100).round();
    return QuoteTotals(cost: cost, markup: markup, vat: vat);
  }

  /// [quote] with [line] replacing the line for the same item, and totals
  /// recomputed. The one place a quote's money changes, so the stored totals
  /// always match the lines.
  static QuoteModel withLine(QuoteModel quote, QuoteLine line) {
    final lines = [for (final l in quote.lines) l.itemId == line.itemId ? line : l];
    return quote.copyWith(
      lines: lines,
      totals: totals(lines, markupPercent: quote.markupPercent, vatPercent: quote.vatPercent),
    );
  }

  /// [quote] with new markup or VAT rates and totals to match.
  static QuoteModel withRates(QuoteModel quote, {double? markupPercent, double? vatPercent}) {
    final m = markupPercent ?? quote.markupPercent;
    final v = vatPercent ?? quote.vatPercent;
    return quote.copyWith(
      markupPercent: m,
      vatPercent: v,
      totals: totals(quote.lines, markupPercent: m, vatPercent: v),
    );
  }

  /// Selling price of each included line, markup spread in proportion to
  /// cost. The last line absorbs rounding so the column adds up exactly to
  /// [QuoteTotals.subtotal] on the PDF.
  static List<int> sellingTotals(List<QuoteLine> included, QuoteTotals totals) {
    if (included.isEmpty) return const [];
    if (totals.cost == 0) return [for (final _ in included) 0];
    final result = [for (final l in included) (l.total * totals.subtotal / totals.cost).round()];
    final drift = totals.subtotal - result.fold<int>(0, (a, b) => a + b);
    result[result.length - 1] += drift;
    return result;
  }
}
