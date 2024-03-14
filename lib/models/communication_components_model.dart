class CommunicationComponentsModel {
  final String name;
  final int price;
  final int cost;
  final int length;
  final int quantity;
  final bool isSelected;
  CommunicationComponentsModel({
    required this.name,
    required this.price,
    required this.cost,
    required this.length,
    required this.quantity,
    required this.isSelected,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'price': price,
      'cost': cost,
      'length': length,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CommunicationComponentsModel.fromMap(Map<String, dynamic> map) {
    return CommunicationComponentsModel(
      name: map['name'] as String,
      price: map['price'] as int,
      cost: map['cost'] as int,
      length: map['length'] as int,
      quantity: map['quantity'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
