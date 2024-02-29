import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/battery_capacity_model.dart';
import 'package:solar_project/models/components_model.dart';

final solarRepositoryProvider = Provider(
  (ref) => SolarRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class SolarRepository {
  final FirebaseFirestore _firestore;

  SolarRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future saveComponent(
      ComponentsModel componentsModel) async {
    return _components.doc(componentsModel.name).set(componentsModel.toMap());
  }

  Stream<List<ComponentsModel>> getAllComponents() {
    return _components.orderBy('number').snapshots().map((event) {
      List<ComponentsModel> components = [];
      for (var doc in event.docs) {
        components
            .add(ComponentsModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return components;
    });
  }

  Future createApplication(
      String applicationId, ApplicationModel applicationModel) async {
    return _applications.doc(applicationId).set(applicationModel.toMap());
  }

  Stream<ComponentsModel> getComponent(String component) {
    return _components.doc(component).snapshots().map((event) =>
        ComponentsModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Future updateClientName(String applicationId, String clientName) async {
    return _applications.doc(applicationId).update({'clientName': clientName});
  }

  Stream<ApplicationModel> getApplication(String applicationId) {
    return _applications.doc(applicationId).snapshots().map((event) =>
        ApplicationModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Future<ApplicationModel> getFutureApplication(String applicationId) async {
    var event = await _applications.doc(applicationId).get();
    final result =
        ApplicationModel.fromMap(event.data() as Map<String, dynamic>);
    return result;
  }

  Stream<List<ApplicationModel>> getAllApplications() {
    return _applications
        .where('isDone', isEqualTo: false)
        .snapshots()
        .map((event) {
      List<ApplicationModel> applications = [];
      for (var doc in event.docs) {
        applications
            .add(ApplicationModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return applications;
    });
  }

  Future saveComponentsToApplication(
      String applicationId, ComponentsModel componentsModel) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(componentsModel.name)
        .set(componentsModel.toMap());
  }

  Future<List<ComponentsModel>> getAllFutureComponents() async {
    var event = await _components.orderBy('number').get();

    List<ComponentsModel> components = [];
    for (var doc in event.docs) {
      components
          .add(ComponentsModel.fromMap(doc.data() as Map<String, dynamic>));
    }
    return components;
  }

  Stream<ComponentsModel> getApplicationComponent(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .snapshots()
        .map((event) =>
            ComponentsModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Future<ComponentsModel> getFutureApplicationComponent(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .get();
    final result =
        ComponentsModel.fromMap(event.data() as Map<String, dynamic>);
    return result;
  }

  Stream<List<ComponentsModel>> getApplicationComponents(String applicationId) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .orderBy('number')
        .snapshots()
        .map((event) {
      List<ComponentsModel> components = [];
      for (var doc in event.docs) {
        components.add(ComponentsModel.fromMap(doc.data()));
      }
      return components;
    });
  }

  Future<List<ComponentsModel>> getAllFutureApplicationComponents(
      String applicationId) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .where('isSelected', isEqualTo: true)
        .get();

    List<ComponentsModel> components = [];
    for (var doc in event.docs) {
      components.add(ComponentsModel.fromMap(doc.data()));
    }
    return components;
  }

  Future updateComponentSelectedStatus(
      String applicationId, bool selected, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .update({'isSelected': selected});
  }

  Future updateComponentCost(
      String applicationId, int cost, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .update({'cost': cost});
  }

  Future updateComponentQuantity(
      String applicationId, int quantity, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .update({'quantity': quantity});
  }

  Future updateComponentCapacity(
      String applicationId, int capacity, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .update({'capacity': capacity});
  }

  Future updateApplicationComponentsCostListAdd(
      String applicationId, int componentCost) async {
    return _applications.doc(applicationId).update({
      'components': FieldValue.arrayUnion([componentCost])
    });
  }

  Future updateApplicationComponentsCostListRemove(
      String applicationId, int componentCost) async {
    return _applications.doc(applicationId).update({
      'components': FieldValue.arrayRemove([componentCost])
    });
  }

  Future updateApplicationQuotation(String applicationId, int quotation) async {
    return _applications.doc(applicationId).update({'quotation': quotation});
  }

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

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
