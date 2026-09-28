class AdapterBoxModel {
  final String name;
  final int cost;
  final bool isSelected;
  final String dimensions;
  AdapterBoxModel({
    required this.name,
    required this.cost,
    required this.isSelected,
    required this.dimensions,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cost': cost,
      'isSelected': isSelected,
      'dimensions': dimensions,
    };
  }

  factory AdapterBoxModel.fromMap(Map<String, dynamic> map) {
    return AdapterBoxModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
      dimensions: map['dimensions'] as String,
    );
  }
}
