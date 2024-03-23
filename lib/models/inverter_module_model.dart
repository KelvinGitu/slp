class InverterModuleModel {
  String name;
  int rating;
  int cost;
  bool isSelected;
  InverterModuleModel({
    required this.name,
    required this.rating,
    required this.cost,
    required this.isSelected,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'rating': rating,
      'cost': cost,
      'isSelected': isSelected,
    };
  }

  factory InverterModuleModel.fromMap(Map<String, dynamic> map) {
    return InverterModuleModel(
      name: map['name'] as String,
      rating: map['rating'] as int,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
