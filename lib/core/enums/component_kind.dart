/// How a catalogue item is priced on a quote, and so which editor the quote
/// line opens. Six kinds cover all 46 components the original app had a
/// hand-written page for.
enum ComponentKind {
  /// Included once at [CatalogueItem.unitPrice], or not at all. Busbar,
  /// contactors, cable ties.
  fixed,

  /// The product of the item's inputs × unit price. Panels (count), labour
  /// (technicians × days), transport (minutes).
  quantity,

  /// Metres: the sum of each run × its factor, × the per-metre price. The
  /// price comes from the chosen option (cable cross-section) when the item
  /// has options, else from the unit price. Core cable, PV cable, trunking.
  length,

  /// Exactly one option, optionally × a count. Inverter, batteries (capacity ×
  /// number of batteries), DC breaker.
  choice,

  /// Any number of options, each with its own quantity. Cable lugs, piping,
  /// earth rod and cable.
  multi,

  /// A description and an amount typed by the installer. Miscellaneous.
  custom;

  String get label => switch (this) {
        ComponentKind.fixed => 'Fixed price',
        ComponentKind.quantity => 'Quantity',
        ComponentKind.length => 'Length',
        ComponentKind.choice => 'Choose one',
        ComponentKind.multi => 'Choose several',
        ComponentKind.custom => 'Custom amount',
      };

  static ComponentKind fromName(String? name) =>
      ComponentKind.values.firstWhere((k) => k.name == name, orElse: () => ComponentKind.fixed);
}
