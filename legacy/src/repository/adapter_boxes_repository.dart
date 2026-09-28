import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/adapter_box_model.dart';

final adapterBoxesRepositoryProvider = Provider(
  (ref) => AdapterBoxesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class AdapterBoxesRepository {
  final FirebaseFirestore _firestore;

  AdapterBoxesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // these functions retrive adapter box enclosures and saves them in the application
  // updates selected boxes status
  // retrieves selected boxes from application

  Future<List<AdapterBoxModel>> getBoxes(String component) async {
    var event = await _components.doc(component).collection('boxes').get();

    List<AdapterBoxModel> boxes = [];
    for (var doc in event.docs) {
      boxes.add(AdapterBoxModel.fromMap(doc.data()));
    }
    return boxes;
  }

  Future saveBoxesToApplication(String applicationId,
      AdapterBoxModel adapterBoxModel, String component) async {
    final name = adapterBoxModel.name;
    final namesplit = name.split(' ');
    final docName = namesplit.first;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('boxes')
        .doc(docName)
        .set(adapterBoxModel.toMap());
  }

  Stream<List<AdapterBoxModel>> getBoxesFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('boxes')
        .snapshots()
        .map((event) {
      List<AdapterBoxModel> boxes = [];
      for (var doc in event.docs) {
        boxes.add(AdapterBoxModel.fromMap(doc.data()));
      }
      return boxes;
    });
  }

  Future updateBoxesSelectedStatus(
      String applicationId, bool selected, String component, String box) async {
    final splitName = box.split(' ');
    final docName = splitName.first;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('boxes')
        .doc(docName)
        .update({'isSelected': selected});
  }

  Future<List<AdapterBoxModel>> getFutureSelectedBoxes(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('boxes')
        .where('isSelected', isEqualTo: true)
        .get();

    List<AdapterBoxModel> boxes = [];
    for (var doc in event.docs) {
      boxes.add(AdapterBoxModel.fromMap(doc.data()));
    }
    return boxes;
  }

  Stream<List<AdapterBoxModel>> getStreamSelectedBoxes(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('boxes')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<AdapterBoxModel> boxes = [];
      for (var doc in event.docs) {
        boxes.add(AdapterBoxModel.fromMap(doc.data()));
      }
      return boxes;
    });
  }

  Future<bool> checkBoxExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('boxes')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
