class ComponentsModel {
  final String name;
  final int cost;
  final bool dependents;
  final bool isSelected;
  final List<dynamic> measurement;
  final int number;
  final int quantity;
  final int length;
  final int weight;
  final int capacity;
  ComponentsModel({
    required this.name,
    required this.cost,
    required this.dependents,
    required this.isSelected,
    required this.measurement,
    required this.number,
    required this.quantity,
    required this.length,
    required this.weight,
    required this.capacity,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cost': cost,
      'dependents': dependents,
      'isSelected': isSelected,
      'measurement': measurement,
      'number': number,
      'quantity': quantity,
      'length': length,
      'weight': weight,
      'capacity': capacity,
    };
  }

  factory ComponentsModel.fromMap(Map<String, dynamic> map) {
    return ComponentsModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      dependents: map['dependents'] as bool,
      isSelected: map['isSelected'] as bool,
      measurement: List<dynamic>.from(map['measurement'] as List<dynamic>),
      number: map['number'] as int,
      quantity: map['quantity'] as int,
      length: map['length'] as int,
      weight: map['weight'] as int,
      capacity: map['capacity'] as int,
    );
  }

  ComponentsModel copyWith({
    String? name,
    int? cost,
    bool? dependents,
    bool? isSelected,
    List<dynamic>? measurement,
    int? number,
    int? quantity,
    int? length,
    int? weight,
    int? capacity,
  }) {
    return ComponentsModel(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      dependents: dependents ?? this.dependents,
      isSelected: isSelected ?? this.isSelected,
      measurement: measurement ?? this.measurement,
      number: number ?? this.number,
      quantity: quantity ?? this.quantity,
      length: length ?? this.length,
      weight: weight ?? this.weight,
      capacity: capacity ?? this.capacity,
    );
  }

  }
