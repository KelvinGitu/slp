class ComponentsModel {
  final String name;
  final int cost;
  final bool isRequired;
  final bool isSelected;
  final List<dynamic> measurement;
  final int number;
  final int quantity;
  final int length;
  final int weight;
  final int capacity;
  final String crossSection;
  ComponentsModel({
    required this.name,
    required this.cost,
    required this.isRequired,
    required this.isSelected,
    required this.measurement,
    required this.number,
    required this.quantity,
    required this.length,
    required this.weight,
    required this.capacity,
    required this.crossSection,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cost': cost,
      'isRequired': isRequired,
      'isSelected': isSelected,
      'measurement': measurement,
      'number': number,
      'quantity': quantity,
      'length': length,
      'weight': weight,
      'capacity': capacity,
      'crossSection': crossSection,
    };
  }

  factory ComponentsModel.fromMap(Map<String, dynamic> map) {
    return ComponentsModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      isRequired: map['isRequired'] as bool,
      isSelected: map['isSelected'] as bool,
      measurement: List<dynamic>.from(map['measurement'] as List<dynamic>),
      number: map['number'] as int,
      quantity: map['quantity'] as int,
      length: map['length'] as int,
      weight: map['weight'] as int,
      capacity: map['capacity'] as int,
      crossSection: map['crossSection'] as String,
    );
  }
}
