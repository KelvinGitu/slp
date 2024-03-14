import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/battery_capacity_model.dart';

final batteryCapacityRepositoryProvider = Provider(
  (ref) => BatteryCapacitiesRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class BatteryCapacitiesRepository {
  final FirebaseFirestore _firestore;

  BatteryCapacitiesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // These functions save battery capacites in the application
  // retrieves all battery capacities in the application
  // retrieves selected battery capacities in the application

  Future saveBatteryCapacityToApplication(String applicationId,
      BatteryCapacityModel batteryCapacityModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('capacities')
        .doc('${batteryCapacityModel.capacity}Ah')
        .set(batteryCapacityModel.toMap());
  }

  Future<List<BatteryCapacityModel>> getBatteryCapacity(
      String component) async {
    var event = await _components.doc(component).collection('capacities').get();

    List<BatteryCapacityModel> capacities = [];
    for (var doc in event.docs) {
      capacities.add(BatteryCapacityModel.fromMap(doc.data()));
    }
    return capacities;
  }

  Stream<List<BatteryCapacityModel>> getBatteryCapacityFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('capacities')
        .snapshots()
        .map((event) {
      List<BatteryCapacityModel> capacities = [];
      for (var doc in event.docs) {
        capacities.add(BatteryCapacityModel.fromMap(doc.data()));
      }
      return capacities;
    });
  }

  Future updateBatteryCapacitySelectedStatus(String applicationId,
      bool selected, String component, int capacity) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('capacities')
        .doc('${capacity}Ah')
        .update({'isSelected': selected});
  }

  Future<bool> checkBatteryCapcityExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('capacities')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
