import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/cable_lugs_model.dart';

final cableLugsRepositoryProvider = Provider(
  (ref) => CableLugsRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class CableLugsRepository {
  final FirebaseFirestore _firestore;

  CableLugsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<CableLugsModel>> getLugs(String component) async {
    var event = await _components.doc(component).collection('lugs').get();

    List<CableLugsModel> lugs = [];
    for (var doc in event.docs) {
      lugs.add(CableLugsModel.fromMap(doc.data()));
    }
    return lugs;
  }

  Future saveLugsToApplication(String applicationId,
      CableLugsModel cableLugsModel, String component) async {
    final name = cableLugsModel.name;
    final splitName = name.split(' ');
    final docName = splitName.first.toLowerCase();
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .doc(docName)
        .set(cableLugsModel.toMap());
  }

  Stream<List<CableLugsModel>> getLugsFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .snapshots()
        .map((event) {
      List<CableLugsModel> lugs = [];
      for (var doc in event.docs) {
        lugs.add(CableLugsModel.fromMap(doc.data()));
      }
      return lugs;
    });
  }

  Future updateLugsSelectedStatus(
      String applicationId, bool selected, String component, String lug) async {
    final splitName = lug.split(' ');
    final docName = splitName.first.toLowerCase();
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .doc(docName)
        .update({'isSelected': selected});
  }

  Future updateLugsCost(
      String applicationId, int cost, String component, String lug) async {
    final splitName = lug.split(' ');
    final docName = splitName.first.toLowerCase();
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .doc(docName)
        .update({'cost': cost});
  }

  Future updateLugsQuantity(
      String applicationId, int quantity, String component, String lug) async {
    final splitName = lug.split(' ');
    final docName = splitName.first.toLowerCase();
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .doc(docName)
        .update({'quantity': quantity});
  }

  Future<List<CableLugsModel>> getFutureSelectedLugs(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .where('isSelected', isEqualTo: true)
        .get();

    List<CableLugsModel> lugs = [];
    for (var doc in event.docs) {
      lugs.add(CableLugsModel.fromMap(doc.data()));
    }
    return lugs;
  }

  Stream<List<CableLugsModel>> getStreamSelectedLugs(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<CableLugsModel> lugs = [];
      for (var doc in event.docs) {
        lugs.add(CableLugsModel.fromMap(doc.data()));
      }
      return lugs;
    });
  }

  Future<bool> checkLugExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('lugs')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
