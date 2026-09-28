import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/piping_components_model.dart';

final pipingComponentsRepositoryProvider = Provider(
  (ref) => PipingComponentsRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class PipingComponentsRepository {
  final FirebaseFirestore _firestore;

  PipingComponentsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<PipingComponentsModel>> getPipingComponents(
      String component) async {
    var event = await _components.doc(component).collection('components').get();

    List<PipingComponentsModel> piping = [];
    for (var doc in event.docs) {
      piping.add(PipingComponentsModel.fromMap(doc.data()));
    }
    return piping;
  }

  Future savePipingComponetsToApplication(String applicationId,
      PipingComponentsModel pipingComponentsModel, String component) async {
    final name = pipingComponentsModel.name;
    final namesplit = name.split(' ');
    final docName = namesplit.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .set(pipingComponentsModel.toMap());
  }

  Stream<List<PipingComponentsModel>> getPipingComponentsFromApplication(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .snapshots()
        .map((event) {
      List<PipingComponentsModel> piping = [];
      for (var doc in event.docs) {
        piping.add(PipingComponentsModel.fromMap(doc.data()));
      }
      return piping;
    });
  }

  Future updatePipingComponentSelectedStatus(String applicationId,
      bool selected, String component, String piping) async {
    final splitName = piping.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'isSelected': selected});
  }

  Future updatePipingComponentLength(
      String applicationId, int length, String component, String piping) async {
    final splitName = piping.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'length': length});
  }

  Future updatePipingComponentQuantity(String applicationId, int quantity,
      String component, String piping) async {
    final splitName = piping.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'quantity': quantity});
  }

  Future updatePipingComponentCost(
      String applicationId, int cost, String component, String piping) async {
    final splitName = piping.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'cost': cost});
  }

  Future<List<PipingComponentsModel>> getFutureSelectedPipingComponents(
      String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .where('isSelected', isEqualTo: true)
        .get();

    List<PipingComponentsModel> piping = [];
    for (var doc in event.docs) {
      piping.add(PipingComponentsModel.fromMap(doc.data()));
    }
    return piping;
  }

  Stream<List<PipingComponentsModel>> getStreamSelectedPipingComponents(
      String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<PipingComponentsModel> piping = [];
      for (var doc in event.docs) {
        piping.add(PipingComponentsModel.fromMap(doc.data()));
      }
      return piping;
    });
  }

  Future<bool> checkPipingComponentExists(
      String applicationId, String component, String name) async {
    final event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(name)
        .get();
    return event.exists;
  }


  CollectionReference get _components => _firestore.collection('components');
  CollectionReference get _applications =>
      _firestore.collection('applications');
}
