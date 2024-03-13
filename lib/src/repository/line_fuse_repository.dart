import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/line_fuse_model.dart';

final lineFuseRepositoryPrrovider = Provider(
  (ref) => LineFuseRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class LineFuseRepository {
  final FirebaseFirestore _firestore;

  LineFuseRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<LineFuseModel>> getFuses(String component) async {
    var event = await _components.doc(component).collection('fuses').get();

    List<LineFuseModel> fuses = [];
    for (var doc in event.docs) {
      fuses.add(LineFuseModel.fromMap(doc.data()));
    }
    return fuses;
  }

  Future saveFusesToApplication(String applicationId,
      LineFuseModel lineFuseModel, String component) async {
    final name = lineFuseModel.name;
    final splitName = name.split(' ');
    final docName = splitName[3];
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('fuses')
        .doc(docName)
        .set(lineFuseModel.toMap());
  }

  Stream<List<LineFuseModel>> getFusesFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('fuses')
        .snapshots()
        .map((event) {
      List<LineFuseModel> fuses = [];
      for (var doc in event.docs) {
        fuses.add(LineFuseModel.fromMap(doc.data()));
      }
      return fuses;
    });
  }

  Future updateFusesSelectedStatus(String applicationId, bool selected,
      String component, String fuse) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('fuses')
        .doc(fuse)
        .update({'isSelected': selected});
  }

  Future<List<LineFuseModel>> getFutureSelectedFuses(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('fuses')
        .where('isSelected', isEqualTo: true)
        .get();

    List<LineFuseModel> fuses = [];
    for (var doc in event.docs) {
      fuses.add(LineFuseModel.fromMap(doc.data()));
    }
    return fuses;
  }

  Stream<List<LineFuseModel>> getStreamSelectedFuses(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('fuses')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<LineFuseModel> fuses = [];
      for (var doc in event.docs) {
        fuses.add(LineFuseModel.fromMap(doc.data()));
      }
      return fuses;
    });
  }

  Future<bool> checkFuseExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('fuses')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
