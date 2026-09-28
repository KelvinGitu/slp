class VoltagGuardModel {
  final String name;
  final int cost;
  final bool isSelected;
  VoltagGuardModel({
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

  factory VoltagGuardModel.fromMap(Map<String, dynamic> map) {
    return VoltagGuardModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
