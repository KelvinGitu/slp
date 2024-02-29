class ApplicationModel {
  final String applicationId;
  final String clientName;
  final String expertName;
  final String expertId;
  final int quotation;
  final bool isDone;
  ApplicationModel({
    required this.applicationId,
    required this.clientName,
    required this.expertName,
    required this.expertId,
    required this.quotation,
    required this.isDone,
  });

  ApplicationModel copyWith({
    String? applicationId,
    String? clientName,
    String? expertName,
    String? expertId,
    int? quotation,
    bool? isDone,
  }) {
    return ApplicationModel(
      applicationId: applicationId ?? this.applicationId,
      clientName: clientName ?? this.clientName,
      expertName: expertName ?? this.expertName,
      expertId: expertId ?? this.expertId,
      quotation: quotation ?? this.quotation,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'clientName': clientName,
      'expertName': expertName,
      'expertId': expertId,
      'quotation': quotation,
      'isDone': isDone,
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
    );
  }

  }
