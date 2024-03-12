class LineFuseModel {
  final String name;
  final int cost;
  final bool isSelected;
  LineFuseModel({
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

  factory LineFuseModel.fromMap(Map<String, dynamic> map) {
    return LineFuseModel(
      name: map['name'] as String,
      cost: map['cost'] as int,
      isSelected: map['isSelected'] as bool,
    );
  }
}
