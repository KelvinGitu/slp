import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/voltage_guard_model.dart';

final voltageGuardRepositoryProvider = Provider(
  (ref) => VoltageGuardRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class VoltageGuardRepository {
  final FirebaseFirestore _firestore;

  VoltageGuardRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<VoltagGuardModel>> getVoltageGuards(String component) async {
    var event = await _components.doc(component).collection('guards').get();

    List<VoltagGuardModel> guards = [];
    for (var doc in event.docs) {
      guards.add(VoltagGuardModel.fromMap(doc.data()));
    }
    return guards;
  }

  Future saveVolatgeGuardsToApplication(String applicationId,
      VoltagGuardModel voltagGuardModel, String component) async {
    String name = voltagGuardModel.name;
    final splitName = name.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('guards')
        .doc(docName)
        .set(voltagGuardModel.toMap());
  }

  Stream<List<VoltagGuardModel>> getVoltageGuardsFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('guards')
        .snapshots()
        .map((event) {
      List<VoltagGuardModel> guards = [];
      for (var doc in event.docs) {
        guards.add(VoltagGuardModel.fromMap(doc.data()));
      }
      return guards;
    });
  }

  Future updateVolatageGuardsSelectedStatus(String applicationId, bool selected,
      String component, String guard) async {
         final splitName = guard.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('guards')
        .doc(docName)
        .update({'isSelected': selected});
  }

  Future<List<VoltagGuardModel>> getFutureSelectedVoltageGuards(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('guards')
        .where('isSelected', isEqualTo: true)
        .get();

    List<VoltagGuardModel> guards = [];
    for (var doc in event.docs) {
      guards.add(VoltagGuardModel.fromMap(doc.data()));
    }
    return guards;
  }

  Stream<List<VoltagGuardModel>> getStreamSelectedVoltageGuards(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('guards')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<VoltagGuardModel> guards = [];
      for (var doc in event.docs) {
        guards.add(VoltagGuardModel.fromMap(doc.data()));
      }
      return guards;
    });
  }

  Future<bool> checkVoltageGuardExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('guards')
        .doc(name)
        .get();
    return event.exists;
  }

  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
