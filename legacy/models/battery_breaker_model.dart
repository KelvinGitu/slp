class DCBatteryBreakerModel {
  final String name;
  final int cost;
  final bool isSelected;
  DCBatteryBreakerModel({
    required this.name,
    required this.cost,
    required this.isSelected,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cost': cost,
      'isSelected': isSelected,
    };
  }

  factory DCBatteryBreakerModel.fromMap(Map<String, dynamic> map) {
    return DCBatteryBreakerModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
