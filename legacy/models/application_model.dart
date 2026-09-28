class ApplicationModel {
  final String applicationId;
  final String clientName;
  final String expertName;
  final String expertId;
  final int quotation;
  final bool isDone;
  final bool isDeleted;
  final DateTime createdAt;
  ApplicationModel({
    required this.applicationId,
    required this.clientName,
    required this.expertName,
    required this.expertId,
    required this.quotation,
    required this.isDone,
    required this.isDeleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'clientName': clientName,
      'expertName': expertName,
      'expertId': expertId,
      'quotation': quotation,
      'isDone': isDone,
      'isDeleted': isDeleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      applicationId: map['applicationId'] as String,
      clientName: map['clientName'] as String,
      expertName: map['expertName'] as String,
      expertId: map['expertId'] as String,
      quotation: map['quotation'] as int,
      isDone: map['isDone'] as bool,
      isDeleted: map['isDeleted'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
