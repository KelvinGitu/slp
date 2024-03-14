import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/communication_components_model.dart';
import 'package:solar_project/src/repository/communication_components_repository.dart';

final getCommunicationComponentsStreamProvider =
    StreamProvider.family<List<CommunicationComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(communicationComponentsControllerProvider)
      .getCommunicationComponents(arguments[0], arguments[1]);
});

final getSelectedCommunicationComponentsStreamProvider =
    StreamProvider.family<List<CommunicationComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(communicationComponentsControllerProvider)
      .getStreamSelectedCommunicationComponents(arguments[0], arguments[1]);
});

final communicationComponentsControllerProvider = Provider(
  (ref) => CommunicationComponentsController(
    communicationComponentsRepository:
        ref.watch(communicationComponentsRepositoryProvider),
  ),
);

class CommunicationComponentsController {
  final CommunicationComponentsRepository _communicationComponentsRepository;

  CommunicationComponentsController(
      {required CommunicationComponentsRepository
          communicationComponentsRepository})
      : _communicationComponentsRepository = communicationComponentsRepository;

  void saveCommunicationComponentsToApplication(
      {required String applicationId, required String component}) async {
    final components = await _communicationComponentsRepository
        .getCommunicationComponents(component);
    for (CommunicationComponentsModel oneComponent in components) {
      await _communicationComponentsRepository
          .saveCommunicationComponentsToApplication(
              applicationId, oneComponent, component);
    }
  }

  void updateCommunicationComponentSelectedStatus({
    required String applicationId,
    required String component,
    required String componentName,
    required bool selected,
  }) async {
    await _communicationComponentsRepository
        .updateCommunicationComponentSelectedStatus(
            applicationId, selected, component, componentName);
  }

  void updateCommunicationComponentLength({
    required String applicationId,
    required String component,
    required String componentName,
    required int length,
  }) async {
    await _communicationComponentsRepository.updateCommunicationComponentLength(
        applicationId, length, component, componentName);
  }

  
  void updateCommunicationComponentQuantity({
    required String applicationId,
    required String component,
    required String componentName,
    required int quantity,
  }) async {
    await _communicationComponentsRepository.updateCommunicationComponentQuantity(
        applicationId, quantity, component, componentName);
  }

  void updateCommunicationComponentCost({
    required String applicationId,
    required String component,
    required String componentName,
    required int cost,
  }) async {
    await _communicationComponentsRepository.updateCommunicationComponentCost(
        applicationId, cost, component, componentName);
  }

  Future<bool> checkCommunicationComponentExists(
      String applicationId, String component, String name) {
    return _communicationComponentsRepository
        .checkCommunicationComponentsExists(applicationId, component, name);
  }

  Future<List<CommunicationComponentsModel>>
      getFutureSelectedCommunicationComponents(
          String applicationId, String component) async {
    return await _communicationComponentsRepository
        .getFutureSelectedCommunicationComponents(applicationId, component);
  }

  Stream<List<CommunicationComponentsModel>>
      getStreamSelectedCommunicationComponents(
          String applicationId, String component) {
    return _communicationComponentsRepository
        .getStreamSelectedCommunicationComponents(applicationId, component);
  }

  Stream<List<CommunicationComponentsModel>> getCommunicationComponents(
      String applicationId, String component) {
    return _communicationComponentsRepository
        .getCommunicationComponentsFromApplication(applicationId, component);
  }
}
