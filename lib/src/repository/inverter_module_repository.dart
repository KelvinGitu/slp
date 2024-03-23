import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/inverter_module_model.dart';

final inverterModuleRepositoryProvider = Provider(
  (ref) => InverterModuleRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class InverterModuleRepository {
  final FirebaseFirestore _firestore;

  InverterModuleRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<InverterModuleModel>> getModules(String component) async {
    var event = await _components.doc(component).collection('modules').get();

    List<InverterModuleModel> modules = [];
    for (var doc in event.docs) {
      modules.add(InverterModuleModel.fromMap(doc.data()));
    }
    return modules;
  }

  Future saveModulesToApplication(String applicationId,
      InverterModuleModel inverterModuleModel, String component) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('modules')
        .doc(inverterModuleModel.name)
        .set(inverterModuleModel.toMap());
  }

  Stream<List<InverterModuleModel>> getModulesFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('modules')
        .snapshots()
        .map((event) {
      List<InverterModuleModel> modules = [];
      for (var doc in event.docs) {
        modules.add(InverterModuleModel.fromMap(doc.data()));
      }
      return modules;
    });
  }

  Future updateModulesSelectedStatus(String applicationId, bool selected,
      String component, String module) async {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('modules')
        .doc(module)
        .update({'isSelected': selected});
  }

  Future<List<InverterModuleModel>> getFutureSelectedModules(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('modules')
        .where('isSelected', isEqualTo: true)
        .get();

    List<InverterModuleModel> modules = [];
    for (var doc in event.docs) {
      modules.add(InverterModuleModel.fromMap(doc.data()));
    }
    return modules;
  }

  Stream<List<InverterModuleModel>> getStreamSelectedModules(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('modules')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<InverterModuleModel> modules = [];
      for (var doc in event.docs) {
        modules.add(InverterModuleModel.fromMap(doc.data()));
      }
      return modules;
    });
  }

  Future<bool> checkModuleExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('modules')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
