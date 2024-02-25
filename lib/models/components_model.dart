class ComponentsModel {
  final String name;
  final int cost;
  final bool dependents;
  final bool isSelected;
  final List<dynamic> measurement;
  ComponentsModel({
    required this.name,
    required this.cost,
    required this.dependents,
    required this.isSelected,
    required this.measurement,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cost': cost,
      'dependents': dependents,
      'isSelected': isSelected,
      'measurement': measurement,
    };
  }

  factory ComponentsModel.fromMap(Map<String, dynamic> map) {
    return ComponentsModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      dependents: map['dependents'] as bool,
      isSelected: map['isSelected'] as bool,
      measurement: List<dynamic>.from(map['measurement'] as List<dynamic>),
    );
  }

  
}
