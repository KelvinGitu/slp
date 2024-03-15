class CableLugsModel {
  final String name;
  final int price;
  final int cost;
  final bool isSelected;
  final int quantity;
  CableLugsModel({
    required this.name,
    required this.price,
    required this.cost,
    required this.isSelected,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'price': price,
      'cost': cost,
      'isSelected': isSelected,
      'quantity': quantity,
    };
  }

  factory CableLugsModel.fromMap(Map<String, dynamic> map) {
    return CableLugsModel(
      name: map['name'] as String,
      price: map['price'] as int,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
      quantity: map['quantity'] as int,
    );
  }
}
