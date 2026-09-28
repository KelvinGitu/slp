class SingleCoreCableModel {
  final String name;
  final int price;
  final int cost;
  final bool isSelected;
  SingleCoreCableModel({
    required this.name,
    required this.price,
    required this.cost,
    required this.isSelected,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'price': price,
      'cost': cost,
      'isSelected': isSelected,
    };
  }

  factory SingleCoreCableModel.fromMap(Map<String, dynamic> map) {
    return SingleCoreCableModel(
      name: map['name'] as String,
      price: map['price'] as int,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
