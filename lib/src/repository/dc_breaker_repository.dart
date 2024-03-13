import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/dc_breaker_model.dart';

final dcBreakerRepositoryProvider = Provider(
  (ref) => DCBreakerRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class DCBreakerRepository {
  final FirebaseFirestore _firestore;

  DCBreakerRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<DCBreakerModel>> getBreakers(String component) async {
    var event = await _components.doc(component).collection('breakers').get();

    List<DCBreakerModel> breakers = [];
    for (var doc in event.docs) {
      breakers.add(DCBreakerModel.fromMap(doc.data()));
    }
    return breakers;
  }

  Future saveBreakersToApplication(String applicationId,
      DCBreakerModel dcBreakerModel, String component) async {
    final name = dcBreakerModel.name;
    final splitName = name.split(' ');
    final docName = splitName[3];
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .doc(docName)
        .set(dcBreakerModel.toMap());
  }

  Stream<List<DCBreakerModel>> getBreakerFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .snapshots()
        .map((event) {
      List<DCBreakerModel> breakers = [];
      for (var doc in event.docs) {
        breakers.add(DCBreakerModel.fromMap(doc.data()));
      }
      return breakers;
    });
  }

  Future updateBreakersSelectedStatus(String applicationId, bool selected,
      String component, String breaker) async {
         final splitName = breaker.split(' ');
    final docName = splitName[3];
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .doc(docName)
        .update({'isSelected': selected});
  }

  Future<List<DCBreakerModel>> getFutureSelectedBreakers(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .where('isSelected', isEqualTo: true)
        .get();

    List<DCBreakerModel> breakers = [];
    for (var doc in event.docs) {
      breakers.add(DCBreakerModel.fromMap(doc.data()));
    }
    return breakers;
  }

  Stream<List<DCBreakerModel>> getStreamSelectedBreakers(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<DCBreakerModel> breakers = [];
      for (var doc in event.docs) {
        breakers.add(DCBreakerModel.fromMap(doc.data()));
      }
      return breakers;
    });
  }

  Future<bool> checkBreakerExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
