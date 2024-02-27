import 'package:solar_project/models/components_model.dart';

class ApplicationModel {
  final String applicationId;
  final String clientName;
  final String expertName;
  final String expertId;
  final int quotation;
  final bool isDone;

  final List<ComponentsModel> components;
  ApplicationModel({
    required this.applicationId,
    required this.clientName,
    required this.expertName,
    required this.expertId,
    required this.quotation,
    required this.isDone,
    required this.components,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'clientName': clientName,
      'expertName': expertName,
      'expertId': expertId,
      'quotation': quotation,
      'isDone': isDone,
      'components': components.map((x) => x.toMap()).toList(),
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
      components: List<ComponentsModel>.from(
        (map['components'] as List<int>).map<ComponentsModel>(
          (x) => ComponentsModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
