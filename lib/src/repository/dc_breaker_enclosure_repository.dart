import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/dc_breaker_enclosure_model.dart';

final dcBreakerEnclosureRepositoryProvider = Provider(
  (ref) => DCBreakerEnclosureRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class DCBreakerEnclosureRepository {
  final FirebaseFirestore _firestore;

  DCBreakerEnclosureRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<DCBreakerEnclosureModel>> getBreakerEnclosures(
      String component) async {
    var event = await _components.doc(component).collection('enlosures').get();

    List<DCBreakerEnclosureModel> enclosures = [];
    for (var doc in event.docs) {
      enclosures.add(DCBreakerEnclosureModel.fromMap(doc.data()));
    }
    return enclosures;
  }

  Future saveBreakerEnclosuresToApplication(String applicationId,
      DCBreakerEnclosureModel dcBreakerEnclosureModel, String component) async {
    final name = dcBreakerEnclosureModel.name;
    final splitName = name.split(' ');
    final docName = splitName[3] + splitName[4];
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('enclosures')
        .doc(docName)
        .set(dcBreakerEnclosureModel.toMap());
  }

  Stream<List<DCBreakerEnclosureModel>> getBreakerEnclosuresFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('enclosures')
        .snapshots()
        .map((event) {
      List<DCBreakerEnclosureModel> enclosures = [];
      for (var doc in event.docs) {
        enclosures.add(DCBreakerEnclosureModel.fromMap(doc.data()));
      }
      return enclosures;
    });
  }

  Future updateBreakerEnclosuresSelectedStatus(String applicationId,
      bool selected, String component, String enclosure) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('enclosures')
        .doc(enclosure)
        .update({'isSelected': selected});
  }

  Future<List<DCBreakerEnclosureModel>> getFutureSelectedBreakerEnclosures(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('enclosures')
        .where('isSelected', isEqualTo: true)
        .get();

    List<DCBreakerEnclosureModel> enclosures = [];
    for (var doc in event.docs) {
      enclosures.add(DCBreakerEnclosureModel.fromMap(doc.data()));
    }
    return enclosures;
  }

  Stream<List<DCBreakerEnclosureModel>> getStreamSelectedBreakerEnclosures(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('enclosures')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<DCBreakerEnclosureModel> enclosures = [];
      for (var doc in event.docs) {
        enclosures.add(DCBreakerEnclosureModel.fromMap(doc.data()));
      }
      return enclosures;
    });
  }

  Future<bool> checkBreakerEnclosureExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('enclosures')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
