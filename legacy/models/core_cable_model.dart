class CoreCableModel {
  final String crossSection;
  final int cost;
  CoreCableModel({
    required this.crossSection,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'crossSection': crossSection,
      'cost': cost,
    };
  }

  factory CoreCableModel.fromMap(Map<String, dynamic> map) {
    return CoreCableModel(
      crossSection: map['crossSection'] as String,
      cost: map['cost'] as int,
    );
  }
}
