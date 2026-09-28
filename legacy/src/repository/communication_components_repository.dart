import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/models/communication_components_model.dart';

final communicationComponentsRepositoryProvider = Provider(
  (ref) => CommunicationComponentsRepository(
    firestore: ref.watch(firestoreProvider),
  ),
);

class CommunicationComponentsRepository {
  final FirebaseFirestore _firestore;

  CommunicationComponentsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<CommunicationComponentsModel>> getCommunicationComponents(
      String component) async {
    var event = await _components.doc(component).collection('components').get();

    List<CommunicationComponentsModel> components = [];
    for (var doc in event.docs) {
      components.add(CommunicationComponentsModel.fromMap(doc.data()));
    }
    return components;
  }

  Future saveCommunicationComponentsToApplication(
      String applicationId,
      CommunicationComponentsModel communicationComponentsModel,
      String component) async {
    final name = communicationComponentsModel.name;
    final splitName = name.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .set(communicationComponentsModel.toMap());
  }

  Stream<List<CommunicationComponentsModel>>
      getCommunicationComponentsFromApplication(
          String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .snapshots()
        .map((event) {
      List<CommunicationComponentsModel> components = [];
      for (var doc in event.docs) {
        components.add(CommunicationComponentsModel.fromMap(doc.data()));
      }
      return components;
    });
  }

  Future updateCommunicationComponentSelectedStatus(String applicationId,
      bool selected, String component, String componentName) async {
    final splitName = componentName.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'isSelected': selected});
  }

  Future updateCommunicationComponentLength(String applicationId, int length,
      String component, String componentName) async {
    final splitName = componentName.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'length': length});
  }

  Future updateCommunicationComponentQuantity(String applicationId,
      int quantity, String component, String componentName) async {
    final splitName = componentName.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'quantity': quantity});
  }

  Future updateCommunicationComponentCost(String applicationId, int cost,
      String component, String componentName) async {
    final splitName = componentName.split(' ');
    final docName = splitName.last;
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .doc(docName)
        .update({'cost': cost});
  }

  Future<List<CommunicationComponentsModel>>
      getFutureSelectedCommunicationComponents(
          String applicationId, String component) async {
    var event = await _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .where('isSelected', isEqualTo: true)
        .get();

    List<CommunicationComponentsModel> components = [];
    for (var doc in event.docs) {
      components.add(CommunicationComponentsModel.fromMap(doc.data()));
    }
    return components;
  }

  Stream<List<CommunicationComponentsModel>>
      getStreamSelectedCommunicationComponents(
          String applicationId, String component) {
    return _applications
        .doc(applicationId)
        .collection('components')
        .doc(component)
        .collection('components')
        .where('isSelected', isEqualTo: true)
        .snapshots()
        .map((event) {
      List<CommunicationComponentsModel> components = [];
      for (var doc in event.docs) {
        components.add(CommunicationComponentsModel.fromMap(doc.data()));
      }
      return components;
    });
  }

  Future<bool> checkCommunicationComponentsExists(
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
