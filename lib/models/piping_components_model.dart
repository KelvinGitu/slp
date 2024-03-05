class PipingComponentsModel {
  final String name;
  final int quantity;
  final int length;
  final int price;
  final int cost;
  final bool isSelected;
  PipingComponentsModel({
    required this.name,
    required this.quantity,
    required this.length,
    required this.price,
    required this.cost,
    required this.isSelected,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'length': length,
      'price': price,
      'cost': cost,
      'isSelected': isSelected,
    };
  }

  factory PipingComponentsModel.fromMap(Map<String, dynamic> map) {
    return PipingComponentsModel(
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      length: map['length'] as int,
      price: map['price'] as int,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
