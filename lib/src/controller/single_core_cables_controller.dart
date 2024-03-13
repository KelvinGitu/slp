import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/single_core_cable_model.dart';
import 'package:solar_project/src/repository/single_core_cables_repository.dart';

final getSingleCoreCablesStreamProvider =
    StreamProvider.family<List<SingleCoreCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(singleCoreCablesControllerProvider)
      .getSingleCoreCables(arguments[0], arguments[1]);
});

final getSelectedSingleCoreCablesStreamProvider =
    StreamProvider.family<List<SingleCoreCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(singleCoreCablesControllerProvider)
      .getStreamSelectedSingleCables(arguments[0], arguments[1]);
});

final singleCoreCablesControllerProvider = Provider(
  (ref) => SingleCoreCablesController(
    singleCoreCablesRepository: ref.watch(singleCoreCablesRepositoryProvider),
  ),
);

class SingleCoreCablesController {
  final SingleCoreCablesRepository _singleCoreCablesRepository;

  SingleCoreCablesController(
      {required SingleCoreCablesRepository singleCoreCablesRepository})
      : _singleCoreCablesRepository = singleCoreCablesRepository;

  void saveSingleCoreCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables =
        await _singleCoreCablesRepository.getSingleCoreCables(component);
    for (SingleCoreCableModel cable in cables) {
      await _singleCoreCablesRepository.saveSingleCoreCablesToApplication(
          applicationId, cable, component);
    }
  }

  void updateSingleCoreCableSelectedStatus({
    required String applicationId,
    required String component,
    required String cable,
    required bool selected,
  }) async {
    await _singleCoreCablesRepository.updateSingleCoreCableSelectedStatus(
        applicationId, selected, component, cable);
  }

  void updateSingleCoreCableCost({
    required String applicationId,
    required String component,
    required String cable,
    required int cost,
  }) async {
    await _singleCoreCablesRepository.updateSingleCoreCableCost(
        applicationId, cost, component, cable);
  }

  Future<bool> checkSingelCoreCableExists(
      String applicationId, String component, String name) {
    return _singleCoreCablesRepository.checkSingleCoreCableExists(
        applicationId, component, name);
  }

  Future<List<SingleCoreCableModel>> getFutureSelectedSingleCoreCables(
      String applicationId, String component) async {
    return await _singleCoreCablesRepository.getFutureSelectedSingleCoreCables(
        applicationId, component);
  }

  Stream<List<SingleCoreCableModel>> getStreamSelectedSingleCables(
      String applicationId, String component) {
    return _singleCoreCablesRepository.getStreamSelectedSingleCoreCables(
        applicationId, component);
  }

  Stream<List<SingleCoreCableModel>> getSingleCoreCables(
      String applicationId, String component) {
    return _singleCoreCablesRepository.getSingleCoreCablesFromApplication(
        applicationId, component);
  }
}
