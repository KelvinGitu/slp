import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_cable_model.dart';
import 'package:solar_project/src/repository/battery_cables_repository.dart';

final getBatteryCablesStreamProvider =
    StreamProvider.family<List<BatteryCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryCablesControllerProvider)
      .getBatteryCables(arguments[0], arguments[1]);
});

final getSelectedBatteryCablesStreamProvider =
    StreamProvider.family<List<BatteryCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryCablesControllerProvider)
      .getStreamSelectedBatteryCables(arguments[0], arguments[1]);
});


final getFutureSelectedBatteryCablesProvider =
    FutureProvider.family<List<BatteryCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryCablesControllerProvider)
      .getFutureSelectedBatteryCables(arguments[0], arguments[1]);
});

final batteryCablesControllerProvider = Provider(
  (ref) => BatteryCablesController(
    batteryCablesRepository: ref.watch(batteryCablesRepositoryProvider),
  ),
);

class BatteryCablesController {
  final BatteryCablesRepository _batteryCablesRepository;

  BatteryCablesController(
      {required BatteryCablesRepository batteryCablesRepository})
      : _batteryCablesRepository = batteryCablesRepository;

  // these functions save battery cables in the application
  // retrives battery cables from the application, updates battery cable selected status, length, cost
  // fetches selected == true cables from the application

  void saveBatteryCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables = await _batteryCablesRepository.getBatteryCables(component);
    for (BatteryCableModel cable in cables) {
      await _batteryCablesRepository.saveBatteryCablesToApplication(
          applicationId, cable, component);
    }
  }

  void updateBatteryCableSelectedStatus({
    required String applicationId,
    required String component,
    required String cable,
    required bool selected,
  }) async {
    await _batteryCablesRepository.updateBatteryCableSelectedStatus(
        applicationId, selected, component, cable);
  }

  void updateBatteryCableLength({
    required String applicationId,
    required String component,
    required String cable,
    required int length,
  }) async {
    await _batteryCablesRepository.updateBatteryCableLength(
        applicationId, length, component, cable);
  }

  void updateBatteryCableCost({
    required String applicationId,
    required String component,
    required String cable,
    required int cost,
  }) async {
    await _batteryCablesRepository.updateBatteryCableCost(
        applicationId, cost, component, cable);
  }

  Future<bool> checkBatteryCableExists(
      String applicationId, String component, String name) {
    return _batteryCablesRepository.checkBatteryCableExists(
        applicationId, component, name);
  }

  Future<List<BatteryCableModel>> getFutureSelectedBatteryCables(
      String applicationId, String component) async {
    return await _batteryCablesRepository.getFutureSelectedBatteryCables(
        applicationId, component);
  }

  Stream<List<BatteryCableModel>> getStreamSelectedBatteryCables(
      String applicationId, String component) {
    return _batteryCablesRepository.getStreamSelectedBatteryCables(
        applicationId, component);
  }

  Stream<List<BatteryCableModel>> getBatteryCables(
      String applicationId, String component) {
    return _batteryCablesRepository.getBatteryCablesFromApplication(
        applicationId, component);
  }
}
