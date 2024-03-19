import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/cable_lugs_model.dart';
import 'package:solar_project/src/repository/cable_lugs_repository.dart';

final getLugsStreamProvider =
    StreamProvider.family<List<CableLugsModel>, List<String>>((ref, arguments) {
  return ref
      .watch(cableLugsControllerProvider)
      .getLugs(arguments[0], arguments[1]);
});

final getSelectedLugsStreamProvider =
    StreamProvider.family<List<CableLugsModel>, List<String>>((ref, arguments) {
  return ref
      .watch(cableLugsControllerProvider)
      .getStreamSelectedLugs(arguments[0], arguments[1]);
});

final getFutureSelectedLugsFutureProvider =
    FutureProvider.family<List<CableLugsModel>, List<String>>((ref, arguments) {
  return ref
      .watch(cableLugsControllerProvider)
      .getFutureSelectedLugs(arguments[0], arguments[1]);
});

final cableLugsControllerProvider = Provider(
  (ref) => CableLugsController(
    cableLugsRepository: ref.watch(cableLugsRepositoryProvider),
  ),
);

class CableLugsController {
  final CableLugsRepository _cableLugsRepository;

  CableLugsController({required CableLugsRepository cableLugsRepository})
      : _cableLugsRepository = cableLugsRepository;

  void saveLugsToApplication(
      {required String applicationId, required String component}) async {
    final lugs = await _cableLugsRepository.getLugs(component);
    for (CableLugsModel lug in lugs) {
      await _cableLugsRepository.saveLugsToApplication(
          applicationId, lug, component);
    }
  }

  void updateLugsSelectedStatus({
    required String applicationId,
    required String component,
    required String lug,
    required bool selected,
  }) async {
    await _cableLugsRepository.updateLugsSelectedStatus(
        applicationId, selected, component, lug);
  }

  void updateLugsCost({
    required String applicationId,
    required String component,
    required String lug,
    required int cost,
  }) async {
    await _cableLugsRepository.updateLugsCost(
        applicationId, cost, component, lug);
  }

  void updateLugsQuantity({
    required String applicationId,
    required String component,
    required String lug,
    required int quantity,
  }) async {
    await _cableLugsRepository.updateLugsQuantity(
        applicationId, quantity, component, lug);
  }

  Future<bool> checkLugExists(
      String applicationId, String component, String name) {
    return _cableLugsRepository.checkLugExists(applicationId, component, name);
  }

  Future<List<CableLugsModel>> getFutureSelectedLugs(
      String applicationId, String component) async {
    return await _cableLugsRepository.getFutureSelectedLugs(
        applicationId, component);
  }

  Stream<List<CableLugsModel>> getStreamSelectedLugs(
      String applicationId, String component) {
    return _cableLugsRepository.getStreamSelectedLugs(applicationId, component);
  }

  Stream<List<CableLugsModel>> getLugs(String applicationId, String component) {
    return _cableLugsRepository.getLugsFromApplication(
        applicationId, component);
  }
}
