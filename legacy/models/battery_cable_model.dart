class BatteryCableModel {
  final String crossSection;
  final bool isSelected;
  final int cost;
  final String purpose;
  final int length;
  final int price;
  BatteryCableModel({
    required this.crossSection,
    required this.isSelected,
    required this.cost,
    required this.purpose,
    required this.length,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'crossSection': crossSection,
      'isSelected': isSelected,
      'cost': cost,
      'purpose': purpose,
      'length': length,
      'price': price,
    };
  }

  factory BatteryCableModel.fromMap(Map<String, dynamic> map) {
    return BatteryCableModel(
      crossSection: map['crossSection'] as String,
      isSelected: map['isSelected'] as bool,
      cost: map['cost'] as int,
      purpose: map['purpose'] as String,
      length: map['length'] as int,
      price: map['price'] as int,
    );
  }
}
