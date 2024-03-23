import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/piping_components_model.dart';
import 'package:solar_project/src/repository/piping_components_repository.dart';

final getPipingComponentsStreamProvider =
    StreamProvider.family<List<PipingComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(pipingComponentsControllerProvider)
      .getPipingComponents(arguments[0], arguments[1]);
});

final getSelectedPipingComponentsStreamProvider =
    StreamProvider.family<List<PipingComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(pipingComponentsControllerProvider)
      .getStreamSelectedPipingComponents(arguments[0], arguments[1]);
});

final getFutureSelectedPipingComponentsProvider =
    FutureProvider.family<List<PipingComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(pipingComponentsControllerProvider)
      .getFutureSelectedPipingComponents(arguments[0], arguments[1]);
});

final pipingComponentsControllerProvider = Provider(
  (ref) => PipingComponentsController(
    pipingComponentsRepository: ref.watch(pipingComponentsRepositoryProvider),
  ),
);

class PipingComponentsController {
  final PipingComponentsRepository _pipingComponentsRepository;

  PipingComponentsController(
      {required PipingComponentsRepository pipingComponentsRepository})
      : _pipingComponentsRepository = pipingComponentsRepository;

       // these functions saves piping components in the application
  // updates piping component selected status, length, quantity, and cost

  void savePipingComponentsToApplication(
      {required String applicationId, required String component}) async {
    final pipings = await _pipingComponentsRepository.getPipingComponents(component);
    for (PipingComponentsModel piping in pipings) {
      await _pipingComponentsRepository.savePipingComponetsToApplication(
          applicationId, piping, component);
    }
  }

  void updatePipingComponentSelectedStatus({
    required String applicationId,
    required String component,
    required String piping,
    required bool selected,
  }) async {
    await _pipingComponentsRepository.updatePipingComponentSelectedStatus(
        applicationId, selected, component, piping);
  }

  void updatePipingComponentLength({
    required String applicationId,
    required String component,
    required String piping,
    required int length,
  }) async {
    await _pipingComponentsRepository.updatePipingComponentLength(
        applicationId, length, component, piping);
  }

  void updatePipingComponentQuantity({
    required String applicationId,
    required String component,
    required String piping,
    required int quantity,
  }) async {
    await _pipingComponentsRepository.updatePipingComponentQuantity(
        applicationId, quantity, component, piping);
  }

  void updatePipingComponentCost({
    required String applicationId,
    required String component,
    required String piping,
    required int cost,
  }) async {
    await _pipingComponentsRepository.updatePipingComponentCost(
        applicationId, cost, component, piping);
  }

  Future<bool> checkPipingComponentExists(
      String applicationId, String component, String name) {
    return _pipingComponentsRepository.checkPipingComponentExists(
        applicationId, component, name);
  }

  Future<List<PipingComponentsModel>> getFutureSelectedPipingComponents(
      String applicationId, String component) async {
    return await _pipingComponentsRepository.getFutureSelectedPipingComponents(
        applicationId, component);
  }

  Stream<List<PipingComponentsModel>> getStreamSelectedPipingComponents(
      String applicationId, String component) {
    return _pipingComponentsRepository.getStreamSelectedPipingComponents(
        applicationId, component);
  }

  Stream<List<PipingComponentsModel>> getPipingComponents(
      String applicationId, String component) {
    return _pipingComponentsRepository.getPipingComponentsFromApplication(
        applicationId, component);
  }

}
