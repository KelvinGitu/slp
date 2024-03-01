class IsolatorSwitchModel {
  int rating;
  int cost;
  IsolatorSwitchModel({
    required this.rating,
    required this.cost,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rating': rating,
      'cost': cost,
    };
  }

  factory IsolatorSwitchModel.fromMap(Map<String, dynamic> map) {
    return IsolatorSwitchModel(
      rating: map['rating'] as int,
      cost: map['cost'] as int,
    );
  }
}
