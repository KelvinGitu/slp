class BatteryCapacityModel {
  int capacity;
  int cost;
  BatteryCapacityModel({
    required this.capacity,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'capacity': capacity,
      'cost': cost,
    };
  }

  factory BatteryCapacityModel.fromMap(Map<String, dynamic> map) {
    return BatteryCapacityModel(
      capacity: map['capacity'] as int,
      cost: map['cost'] as int,
    );
  }

  
}
