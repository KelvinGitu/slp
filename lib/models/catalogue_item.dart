import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/enums/sizing_role.dart';
import 'package:solartide/core/utils/firestore_json.dart';

/// `users/{uid}/catalogue/{id}`. One component an installer can put on a
/// quote, with its price. Each installer has their own copy, seeded from
/// `defaultCatalogue`, so they can set their own prices.
///
/// Prices are whole shillings. A quote copies the price onto its line when
/// the line is edited, so changing a price here never rewrites old quotes.
class CatalogueItem {
  const CatalogueItem({
    required this.id,
    required this.name,
    required this.category,
    required this.order,
    required this.kind,
    this.unit = 'piece',
    this.unitPrice = 0,
    this.options = const [],
    this.inputs = const [],
    this.notes = const [],
    this.linkedItemId,
    this.linkFactor = 1,
    this.askQuantity = false,
    this.quantityLabel,
    this.defaultQuantity = 1,
    this.rating,
    this.nominalVoltage,
    this.sizingRole = SizingRole.none,
    this.active = true,
  });

  final String id;
  final String name;
  final String category;

  /// Position within the whole catalogue; quotes list lines in this order.
  final int order;
  final ComponentKind kind;

  /// What one unit is: "piece", "m", "day", "minute". Shown next to prices.
  final String unit;

  /// For fixed, quantity and length (without options) kinds.
  final int unitPrice;

  /// For choice and multi, and for length when there's a cross-section to pick.
  final List<CatalogueOption> options;

  /// Numbers the installer types. For quantity, their product is the
  /// quantity (technicians × days). For length, each is a run in metres and
  /// the total is Σ run × factor.
  final List<LineInput> inputs;

  /// Guidance for the installer, the old app's "measures of determination".
  final List<String> notes;

  /// Prefills the quantity from another line: MC4 connectors are panels × 4.
  final String? linkedItemId;
  final int linkFactor;

  /// For choice: also ask how many of the chosen option (number of batteries,
  /// metres of single-core cable).
  final bool askQuantity;
  final String? quantityLabel;
  final int defaultQuantity;

  /// Panel watts, for the sizing calculator.
  final int? rating;

  /// Battery voltage, for converting option amp-hours to energy.
  final int? nominalVoltage;
  final SizingRole sizingRole;

  /// Inactive items are hidden from new quotes but kept on old ones.
  final bool active;

  CatalogueOption? optionById(String id) {
    for (final o in options) {
      if (o.id == id) return o;
    }
    return null;
  }

  bool get hasOptions => options.isNotEmpty;

  factory CatalogueItem.fromMap(String id, Map<String, dynamic> map) => CatalogueItem(
        id: id,
        name: map['name'] as String? ?? '',
        category: map['category'] as String? ?? 'Other',
        order: intFrom(map['order']) ?? 0,
        kind: ComponentKind.fromName(map['kind'] as String?),
        unit: map['unit'] as String? ?? 'piece',
        unitPrice: intFrom(map['unitPrice']) ?? 0,
        options: mapListFrom(map['options']).map(CatalogueOption.fromMap).toList(),
        inputs: mapListFrom(map['inputs']).map(LineInput.fromMap).toList(),
        notes: stringListFrom(map['notes']),
        linkedItemId: map['linkedItemId'] as String?,
        linkFactor: intFrom(map['linkFactor']) ?? 1,
        askQuantity: map['askQuantity'] as bool? ?? false,
        quantityLabel: map['quantityLabel'] as String?,
        defaultQuantity: intFrom(map['defaultQuantity']) ?? 1,
        rating: intFrom(map['rating']),
        nominalVoltage: intFrom(map['nominalVoltage']),
        sizingRole: SizingRole.fromName(map['sizingRole'] as String?),
        active: map['active'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'order': order,
        'kind': kind.name,
        'unit': unit,
        'unitPrice': unitPrice,
        'options': options.map((o) => o.toMap()).toList(),
        'inputs': inputs.map((i) => i.toMap()).toList(),
        'notes': notes,
        'linkedItemId': linkedItemId,
        'linkFactor': linkFactor,
        'askQuantity': askQuantity,
        'quantityLabel': quantityLabel,
        'defaultQuantity': defaultQuantity,
        'rating': rating,
        'nominalVoltage': nominalVoltage,
        'sizingRole': sizingRole.name,
        'active': active,
      };

  CatalogueItem copyWith({
    String? name,
    String? category,
    int? order,
    String? unit,
    int? unitPrice,
    List<CatalogueOption>? options,
    List<String>? notes,
    int? rating,
    bool? active,
  }) =>
      CatalogueItem(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        order: order ?? this.order,
        kind: kind,
        unit: unit ?? this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        options: options ?? this.options,
        inputs: inputs,
        notes: notes ?? this.notes,
        linkedItemId: linkedItemId,
        linkFactor: linkFactor,
        askQuantity: askQuantity,
        quantityLabel: quantityLabel,
        defaultQuantity: defaultQuantity,
        rating: rating ?? this.rating,
        nominalVoltage: nominalVoltage,
        sizingRole: sizingRole,
        active: active ?? this.active,
      );
}

/// One pickable variant of an item: a battery capacity, a cable
/// cross-section, a breaker model.
class CatalogueOption {
  const CatalogueOption({
    required this.id,
    required this.label,
    required this.price,
    this.unit = 'piece',
    this.detail,
    this.rating,
  });

  final String id;
  final String label;

  /// Per [unit]: per piece, or per metre for cables.
  final int price;
  final String unit;

  /// Where it's used or how to measure it.
  final String? detail;

  /// Watts (inverter), amp-hours (battery), amps (isolator).
  final int? rating;

  factory CatalogueOption.fromMap(Map<String, dynamic> map) => CatalogueOption(
        id: map['id'] as String? ?? '',
        label: map['label'] as String? ?? '',
        price: intFrom(map['price']) ?? 0,
        unit: map['unit'] as String? ?? 'piece',
        detail: map['detail'] as String?,
        rating: intFrom(map['rating']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'price': price,
        'unit': unit,
        'detail': detail,
        'rating': rating,
      };

  CatalogueOption copyWith({String? label, int? price, String? detail}) => CatalogueOption(
        id: id,
        label: label ?? this.label,
        price: price ?? this.price,
        unit: unit,
        detail: detail ?? this.detail,
        rating: rating,
      );
}

/// A number the installer types for a line: a count or a cable run.
class LineInput {
  const LineInput({required this.id, required this.label, this.factor = 1, this.defaultValue});

  final String id;

  /// The question, "How many technicians?" or "Roof to inverter".
  final String label;

  /// For length runs: cable that goes out and back counts twice.
  final int factor;
  final int? defaultValue;

  factory LineInput.fromMap(Map<String, dynamic> map) => LineInput(
        id: map['id'] as String? ?? '',
        label: map['label'] as String? ?? '',
        factor: intFrom(map['factor']) ?? 1,
        defaultValue: intFrom(map['defaultValue']),
      );

  Map<String, dynamic> toMap() => {'id': id, 'label': label, 'factor': factor, 'defaultValue': defaultValue};
}
