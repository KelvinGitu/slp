import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/battery_breaker_model.dart';

final batteryBreakerRepositoryProvider = Provider(
  (ref) => BatteryBreakersRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class BatteryBreakersRepository {
  final FirebaseFirestore _firestore;

  BatteryBreakersRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<DCBatteryBreakerModel>> getBatteryBreakers(
      String component) async {
    var event = await _components.doc(component).collection('breakers').get();

    List<DCBatteryBreakerModel> breakers = [];
    for (var doc in event.docs) {
      breakers.add(DCBatteryBreakerModel.fromMap(doc.data()));
    }
    return breakers;
  }

  Future saveBatteryBreakersToApplication(String applicationId,
      DCBatteryBreakerModel batteryBreakerModel, String component) async {
    final name = batteryBreakerModel.name;
    final splitName = name.split(' ');
    final docName = splitName.first;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .doc(docName)
        .set(batteryBreakerModel.toMap());
  }

  Stream<List<DCBatteryBreakerModel>> getBatteryBreakersFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .snapshots()
        .map((event) {
      List<DCBatteryBreakerModel> breakers = [];
      for (var doc in event.docs) {
        breakers.add(DCBatteryBreakerModel.fromMap(doc.data()));
      }
      return breakers;
    });
  }

  Future updateBatteryBreakersSelectedStatus(String applicationId,
      bool selected, String component, String fuse) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .doc(fuse)
        .update({'isSelected': selected});
  }

  Future<List<DCBatteryBreakerModel>> getFutureSelectedBatteryBreakers(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .where('isSelected', isEqualTo: true)
        .get();

    List<DCBatteryBreakerModel> breakers = [];
    for (var doc in event.docs) {
      breakers.add(DCBatteryBreakerModel.fromMap(doc.data()));
    }
    return breakers;
  }

  Stream<List<DCBatteryBreakerModel>> getStreamSelectedBatteryBreakers(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('breakers')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<DCBatteryBreakerModel> breakers = [];
      for (var doc in event.docs) {
        breakers.add(DCBatteryBreakerModel.fromMap(doc.data()));
      }
      return breakers;
    });
  }

  Future<bool> checkBatteryBreakerExists(
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
