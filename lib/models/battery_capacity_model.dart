class BatteryCapacityModel {
  final int capacity;
  final int cost;
  final bool isSelected;
  BatteryCapacityModel({
    required this.capacity,
    required this.cost,
    required this.isSelected,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'capacity': capacity,
      'cost': cost,
      'isSelected': isSelected,
    };
  }

  factory BatteryCapacityModel.fromMap(Map<String, dynamic> map) {
    return BatteryCapacityModel(
      capacity: map['capacity'] as int,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
