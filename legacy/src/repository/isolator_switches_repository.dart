import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/isolator_switch_model.dart';

final isolatorSwitchesRepositoryProvider = Provider(
  (ref) => IsolatorSwitchesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class IsolatorSwitchesRepository {
  final FirebaseFirestore _firestore;

  IsolatorSwitchesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

      // These functions retrieve isolator switches from the inverter manual isolator component 
  // and saves them in the application
  // retrives all isolator switches from application

  Future<List<IsolatorSwitchModel>> getIsolatorSwitch(String component) async {
    var event = await _components.doc(component).collection('isolators').get();

    List<IsolatorSwitchModel> isolators = [];
    for (var doc in event.docs) {
      isolators.add(IsolatorSwitchModel.fromMap(doc.data()));
    }
    return isolators;
  }

  Future saveManualIsolatorsToApplication(String applicationId,
      IsolatorSwitchModel isolatorSwitchModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('isolators')
        .doc('${isolatorSwitchModel.rating}A')
        .set(isolatorSwitchModel.toMap());
  }

  Stream<List<IsolatorSwitchModel>> getIsolatorSwitchFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('isolators')
        .orderBy('rating')
        .snapshots()
        .map((event) {
      List<IsolatorSwitchModel> isolators = [];
      for (var doc in event.docs) {
        isolators.add(IsolatorSwitchModel.fromMap(doc.data()));
      }
      return isolators;
    });
  }


  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
