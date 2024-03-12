import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/core_cable_model.dart';

final pvCablesRepositoryProvider = Provider(
  (ref) => PVCablesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class PVCablesRepository {
  final FirebaseFirestore _firestore;

  PVCablesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // these functions fetch pv cables from the PV Cable component and save them in the application
  // retrives pv cables from application

  Future<List<CoreCableModel>> getPVCables(String component) async {
    var event = await _components.doc(component).collection('cables').get();

    List<CoreCableModel> cables = [];
    for (var doc in event.docs) {
      cables.add(CoreCableModel.fromMap(doc.data()));
    }
    return cables;
  }

  Future savePVCablesToApplication(String applicationId,
      CoreCableModel coreCableModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(coreCableModel.crossSection)
        .set(coreCableModel.toMap());
  }

  Stream<List<CoreCableModel>> getPVCablesFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .snapshots()
        .map((event) {
      List<CoreCableModel> cables = [];
      for (var doc in event.docs) {
        cables.add(CoreCableModel.fromMap(doc.data()));
      }
      return cables;
    });
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
