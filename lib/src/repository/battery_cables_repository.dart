import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/battery_cable_model.dart';

final batteryCablesRepositoryProvider = Provider(
  (ref) => BatteryCablesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class BatteryCablesRepository {
  final FirebaseFirestore _firestore;

  BatteryCablesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // these functions retrive battery cables from the battery
  // saves them in the application
  // retrives battery cables from the application, updates battery cable selected status
  // fetches selected == true cables from the application

  Future<List<BatteryCableModel>> getBatteryCables(String component) async {
    var event = await _components.doc(component).collection('cables').get();

    List<BatteryCableModel> cables = [];
    for (var doc in event.docs) {
      cables.add(BatteryCableModel.fromMap(doc.data()));
    }
    return cables;
  }

  Future saveBatteryCablesToApplication(String applicationId,
      BatteryCableModel coreCableModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(coreCableModel.crossSection)
        .set(coreCableModel.toMap());
  }

  Stream<List<BatteryCableModel>> getBatteryCablesFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .orderBy('price')
        .snapshots()
        .map((event) {
      List<BatteryCableModel> cables = [];
      for (var doc in event.docs) {
        cables.add(BatteryCableModel.fromMap(doc.data()));
      }
      return cables;
    });
  }

  Future updateBatteryCableSelectedStatus(String applicationId, bool selected,
      String component, String cable) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(cable)
        .update({'isSelected': selected});
  }

  Future updateBatteryCableLength(
      String applicationId, int length, String component, String cable) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(cable)
        .update({'length': length});
  }

  Future updateBatteryCableCost(
      String applicationId, int cost, String component, String cable) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .doc(cable)
        .update({'cost': cost});
  }

  Future<List<BatteryCableModel>> getFutureSelectedBatteryCables(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .where('isSelected', isEqualTo: true)
        .get();

    List<BatteryCableModel> cables = [];
    for (var doc in event.docs) {
      cables.add(BatteryCableModel.fromMap(doc.data()));
    }
    return cables;
  }

  Stream<List<BatteryCableModel>> getStreamSelectedBatteryCables(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('cables')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<BatteryCableModel> cables = [];
      for (var doc in event.docs) {
        cables.add(BatteryCableModel.fromMap(doc.data()));
      }
      return cables;
    });
  }

  Future<bool> checkBatteryCableExists(
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
