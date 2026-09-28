import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/utils/firestore_json.dart';
import 'package:solartide/models/sizing_result.dart';

/// `users/{uid}/quotes/{id}`. A priced list of components for one client.
///
/// Every line carries its own frozen prices and the totals are stored too, so
/// the list, the dashboard and the PDF all read one document and agree.
class QuoteModel {
  const QuoteModel({
    required this.id,
    required this.number,
    required this.client,
    required this.status,
    required this.lines,
    required this.markupPercent,
    required this.vatPercent,
    required this.totals,
    required this.createdAt,
    required this.updatedAt,
    required this.validUntil,
    this.sizing,
    this.notes,
    this.deleted = false,
  });

  final String id;

  /// "ST-2026-0007".
  final String number;
  final ClientSnapshot client;
  final QuoteStatus status;
  final List<QuoteLine> lines;

  /// Copied from the business profile when the quote is created, then
  /// editable per quote.
  final double markupPercent;
  final double vatPercent;
  final QuoteTotals totals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime validUntil;

  /// Set when the quote was started from the sizing calculator.
  final SizingResult? sizing;

  /// Free text printed at the bottom of the PDF.
  final String? notes;
  final bool deleted;

  List<QuoteLine> get includedLines => lines.where((l) => l.state == LineState.included).toList();
  int get pendingCount => lines.where((l) => l.state == LineState.pending).length;

  QuoteLine? lineFor(String itemId) {
    for (final l in lines) {
      if (l.itemId == itemId) return l;
    }
    return null;
  }

  factory QuoteModel.fromMap(String id, Map<String, dynamic> map) {
    final created = dateFrom(map['createdAt']) ?? DateTime.now();
    return QuoteModel(
      id: id,
      number: map['number'] as String? ?? '',
      client: ClientSnapshot.fromMap((map['client'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ?? const {}),
      status: QuoteStatus.fromName(map['status'] as String?),
      lines: mapListFrom(map['lines']).map(QuoteLine.fromMap).toList(),
      markupPercent: doubleFrom(map['markupPercent']) ?? 0,
      vatPercent: doubleFrom(map['vatPercent']) ?? 0,
      totals: QuoteTotals.fromMap((map['totals'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ?? const {}),
      createdAt: created,
      updatedAt: dateFrom(map['updatedAt']) ?? created,
      validUntil: dateFrom(map['validUntil']) ?? created,
      sizing: map['sizing'] is Map
          ? SizingResult.fromMap((map['sizing'] as Map<Object?, Object?>).cast<String, dynamic>())
          : null,
      notes: map['notes'] as String?,
      deleted: map['deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'number': number,
        'client': client.toMap(),
        // Top-level copies so Firestore can filter and order without reading
        // the nested snapshot.
        'clientId': client.id,
        'status': status.name,
        'lines': lines.map((l) => l.toMap()).toList(),
        'markupPercent': markupPercent,
        'vatPercent': vatPercent,
        'totals': totals.toMap(),
        'createdAt': timestampFrom(createdAt),
        'updatedAt': timestampFrom(updatedAt),
        'validUntil': timestampFrom(validUntil),
        'sizing': sizing?.toMap(),
        'notes': notes,
        'deleted': deleted,
      };

  QuoteModel copyWith({
    String? id,
    String? number,
    ClientSnapshot? client,
    QuoteStatus? status,
    List<QuoteLine>? lines,
    double? markupPercent,
    double? vatPercent,
    QuoteTotals? totals,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? validUntil,
    SizingResult? sizing,
    String? notes,
    bool? deleted,
  }) =>
      QuoteModel(
        id: id ?? this.id,
        number: number ?? this.number,
        client: client ?? this.client,
        status: status ?? this.status,
        lines: lines ?? this.lines,
        markupPercent: markupPercent ?? this.markupPercent,
        vatPercent: vatPercent ?? this.vatPercent,
        totals: totals ?? this.totals,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        validUntil: validUntil ?? this.validUntil,
        sizing: sizing ?? this.sizing,
        notes: notes ?? this.notes,
        deleted: deleted ?? this.deleted,
      );
}

/// The client as they were when the quote was made. Editing the client later
/// doesn't change a quote that has already been sent.
class ClientSnapshot {
  const ClientSnapshot({required this.id, required this.name, this.phone, this.email, this.location});

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? location;

  factory ClientSnapshot.fromMap(Map<String, dynamic> map) => ClientSnapshot(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        location: map['location'] as String?,
      );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'phone': phone, 'email': email, 'location': location};
}

/// Money on a quote, whole shillings.
///
/// [cost] is the sum of the lines at catalogue prices. [markup] is added on
/// top and spread across the lines on the PDF, so the client sees selling
/// prices only. VAT is charged on cost + markup.
class QuoteTotals {
  const QuoteTotals({this.cost = 0, this.markup = 0, this.vat = 0});

  final int cost;
  final int markup;
  final int vat;

  int get subtotal => cost + markup;
  int get total => subtotal + vat;

  static const zero = QuoteTotals();

  factory QuoteTotals.fromMap(Map<String, dynamic> map) => QuoteTotals(
        cost: intFrom(map['cost']) ?? 0,
        markup: intFrom(map['markup']) ?? 0,
        vat: intFrom(map['vat']) ?? 0,
      );

  // total is stored as well so lists and the dashboard can sum it directly.
  Map<String, dynamic> toMap() => {'cost': cost, 'markup': markup, 'vat': vat, 'total': total};

  @override
  bool operator ==(Object other) =>
      other is QuoteTotals && other.cost == cost && other.markup == markup && other.vat == vat;

  @override
  int get hashCode => Object.hash(cost, markup, vat);

  @override
  String toString() => 'QuoteTotals(cost: $cost, markup: $markup, vat: $vat)';
}

/// One catalogue item on a quote, with the installer's answers and the price
/// at the time they were given.
class QuoteLine {
  const QuoteLine({
    required this.itemId,
    required this.name,
    required this.category,
    required this.order,
    required this.kind,
    required this.unit,
    this.state = LineState.pending,
    this.inputs = const {},
    this.selections = const [],
    this.quantity = 0,
    this.unitPrice = 0,
    this.total = 0,
    this.description,
  });

  final String itemId;
  final String name;
  final String category;
  final int order;
  final ComponentKind kind;
  final String unit;
  final LineState state;

  /// Answers to the item's [LineInput]s, by input id.
  final Map<String, int> inputs;

  /// Chosen options (choice and multi, and the cross-section for length).
  final List<LineSelection> selections;

  /// Count, or metres for length.
  final int quantity;

  /// Per unit, frozen when the line was saved. Zero for multi, where each
  /// selection has its own price.
  final int unitPrice;

  /// Cost of the line in shillings, before markup and VAT.
  final int total;

  /// For custom lines.
  final String? description;

  factory QuoteLine.fromMap(Map<String, dynamic> map) => QuoteLine(
        itemId: map['itemId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        category: map['category'] as String? ?? 'Other',
        order: intFrom(map['order']) ?? 0,
        kind: ComponentKind.fromName(map['kind'] as String?),
        unit: map['unit'] as String? ?? 'piece',
        state: LineState.fromName(map['state'] as String?),
        inputs: {
          for (final e in ((map['inputs'] as Map<Object?, Object?>?) ?? const {}).entries)
            if (e.key is String && e.value is num) e.key! as String: (e.value! as num).round(),
        },
        selections: mapListFrom(map['selections']).map(LineSelection.fromMap).toList(),
        quantity: intFrom(map['quantity']) ?? 0,
        unitPrice: intFrom(map['unitPrice']) ?? 0,
        total: intFrom(map['total']) ?? 0,
        description: map['description'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'name': name,
        'category': category,
        'order': order,
        'kind': kind.name,
        'unit': unit,
        'state': state.name,
        'inputs': inputs,
        'selections': selections.map((s) => s.toMap()).toList(),
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': total,
        'description': description,
      };

  /// Back to "To do", keeping the identity fields.
  QuoteLine reset() => QuoteLine(itemId: itemId, name: name, category: category, order: order, kind: kind, unit: unit);

  QuoteLine copyWith({
    LineState? state,
    Map<String, int>? inputs,
    List<LineSelection>? selections,
    int? quantity,
    int? unitPrice,
    int? total,
    String? description,
  }) =>
      QuoteLine(
        itemId: itemId,
        name: name,
        category: category,
        order: order,
        kind: kind,
        unit: unit,
        state: state ?? this.state,
        inputs: inputs ?? this.inputs,
        selections: selections ?? this.selections,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        total: total ?? this.total,
        description: description ?? this.description,
      );
}

/// A chosen option on a line, with its price frozen.
class LineSelection {
  const LineSelection({
    required this.optionId,
    required this.label,
    required this.unitPrice,
    this.quantity = 1,
    this.unit = 'piece',
  });

  final String optionId;
  final String label;
  final int unitPrice;
  final int quantity;
  final String unit;

  int get total => unitPrice * quantity;

  factory LineSelection.fromMap(Map<String, dynamic> map) => LineSelection(
        optionId: map['optionId'] as String? ?? '',
        label: map['label'] as String? ?? '',
        unitPrice: intFrom(map['unitPrice']) ?? 0,
        quantity: intFrom(map['quantity']) ?? 1,
        unit: map['unit'] as String? ?? 'piece',
      );

  Map<String, dynamic> toMap() =>
      {'optionId': optionId, 'label': label, 'unitPrice': unitPrice, 'quantity': quantity, 'unit': unit};
}
