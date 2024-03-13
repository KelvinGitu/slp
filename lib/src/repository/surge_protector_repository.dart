import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/surge_protector_model.dart';

final surgeProtectorRepositoryProvider = Provider(
  (ref) => SurgeProtectorRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class SurgeProtectorRepository {
  final FirebaseFirestore _firestore;

  SurgeProtectorRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<SurgeProtectorModel>> getSurgeProtectors(String component) async {
    var event = await _components.doc(component).collection('protectors').get();

    List<SurgeProtectorModel> protectors = [];
    for (var doc in event.docs) {
      protectors.add(SurgeProtectorModel.fromMap(doc.data()));
    }
    return protectors;
  }

  Future saveSurgeProtectorsToApplication(String applicationId,
      SurgeProtectorModel surgeProtectorModel, String component) async {
    final name = surgeProtectorModel.name;
    final splitName = name.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('protectors')
        .doc(docName)
        .set(surgeProtectorModel.toMap());
  }

  Stream<List<SurgeProtectorModel>> getSurgeProtectorsFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('protectors')
        .snapshots()
        .map((event) {
      List<SurgeProtectorModel> protectors = [];
      for (var doc in event.docs) {
        protectors.add(SurgeProtectorModel.fromMap(doc.data()));
      }
      return protectors;
    });
  }

  Future updateSurgeProtectorsSelectedStatus(String applicationId,
      bool selected, String component, String protector) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('protectors')
        .doc(protector)
        .update({'isSelected': selected});
  }

  Future<List<SurgeProtectorModel>> getFutureSelectedSurgeProtectors(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('protectors')
        .where('isSelected', isEqualTo: true)
        .get();

    List<SurgeProtectorModel> protectors = [];
    for (var doc in event.docs) {
      protectors.add(SurgeProtectorModel.fromMap(doc.data()));
    }
    return protectors;
  }

  Stream<List<SurgeProtectorModel>> getStreamSelectedSurgeProtectors(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<SurgeProtectorModel> protectors = [];
      for (var doc in event.docs) {
        protectors.add(SurgeProtectorModel.fromMap(doc.data()));
      }
      return protectors;
    });
  }

  Future<bool> checkSurgeProtectorExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('protector')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
