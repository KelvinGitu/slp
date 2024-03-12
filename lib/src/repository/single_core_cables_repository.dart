import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/single_core_cable_model.dart';

final singleCoreCablesRepositoryProvider = Provider(
  (ref) => SingleCoreCablesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class SingleCoreCablesRepository {
  final FirebaseFirestore _firestore;

  SingleCoreCablesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

 // these functions retrieve single core cables from the single core cable component
  // saves them in the application, and retrieves all cables
  // updates selected status, and retrieves selected cables

  
  Future<List<SingleCoreCableModel>> getSingleCoreCables(String component) async {
    var event = await _components.doc(component).collection('cables').get();

    List<SingleCoreCableModel> cables = [];
    for (var doc in event.docs) {
      cables.add(SingleCoreCableModel.fromMap(doc.data()));
    }
    return cables;
  }

  Future saveSingleCoreCablesToApplication(String applicationId,
      SingleCoreCableModel singleCoreCableModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(singleCoreCableModel.name)
        .set(singleCoreCableModel.toMap());
  }

  Stream<List<SingleCoreCableModel>> getSingleCoreCablesFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .snapshots()
        .map((event) {
      List<SingleCoreCableModel> cables = [];
      for (var doc in event.docs) {
        cables.add(SingleCoreCableModel.fromMap(doc.data()));
      }
      return cables;
    });
  }

  Future updateSingleCoreCableSelectedStatus(String applicationId, bool selected,
      String component, String cable) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(cable)
        .update({'isSelected': selected});
  }

  Future<List<SingleCoreCableModel>> getFutureSelectedSingleCoreCables(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .where('isSelected', isEqualTo: true)
        .get();

    List<SingleCoreCableModel> cables = [];
    for (var doc in event.docs) {
      cables.add(SingleCoreCableModel.fromMap(doc.data()));
    }
    return cables;
  }

  Stream<List<SingleCoreCableModel>> getStreamSelectedSingleCoreCables(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<SingleCoreCableModel> cables = [];
      for (var doc in event.docs) {
        cables.add(SingleCoreCableModel.fromMap(doc.data()));
      }
      return cables;
    });
  }

  Future<bool> checkSingleCoreCableExists(
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

 

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
