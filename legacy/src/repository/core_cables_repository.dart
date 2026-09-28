import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/core_cable_model.dart';

final coreCablesRepositoryProvider = Provider(
  (ref) => CoreCablesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class CoreCablesRepository {
  final FirebaseFirestore _firestore;

  CoreCablesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

   // These functions retrieve core cables from the core cable compoenent and saves them in the application
  // retrieves core cables from the application

  Future<List<CoreCableModel>> getCoreCables(String component) async {
    var event = await _components.doc(component).collection('cables').get();

    List<CoreCableModel> cables = [];
    for (var doc in event.docs) {
      cables.add(CoreCableModel.fromMap(doc.data()));
    }
    return cables;
  }

  Future<bool> checkCoreCableExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(name)
        .get();
    return event.exists;
  }


  Future saveCoreCablesToApplication(String applicationId,
      CoreCableModel coreCableModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(coreCableModel.crossSection)
        .set(coreCableModel.toMap());
  }

  Stream<List<CoreCableModel>> getCoreCablesFromApplication(
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
