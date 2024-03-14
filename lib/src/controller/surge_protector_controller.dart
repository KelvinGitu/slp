import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/surge_protector_model.dart';
import 'package:solar_project/src/repository/surge_protector_repository.dart';

final getSurgeProtectorsStreamProvider =
    StreamProvider.family<List<SurgeProtectorModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(surgeProtectorControllerProvider)
      .getSurgeProtectors(arguments[0], arguments[1]);
});

final getSelectedSurgeProtectorsStreamProvider =
    StreamProvider.family<List<SurgeProtectorModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(surgeProtectorControllerProvider)
      .getStreamSelectedSurgeProtectors(arguments[0], arguments[1]);
});

final surgeProtectorControllerProvider = Provider(
  (ref) => SurgeProtectorController(
    surgeProtectorRepository: ref.watch(surgeProtectorRepositoryProvider),
  ),
);

class SurgeProtectorController {
  final SurgeProtectorRepository _surgeProtectorRepository;

  SurgeProtectorController(
      {required SurgeProtectorRepository surgeProtectorRepository})
      : _surgeProtectorRepository = surgeProtectorRepository;

  void saveSurgeProtectorsToApplication(
      {required String applicationId, required String component}) async {
    final protectors =
        await _surgeProtectorRepository.getSurgeProtectors(component);
    for (SurgeProtectorModel protector in protectors) {
      await _surgeProtectorRepository.saveSurgeProtectorsToApplication(
          applicationId, protector, component);
    }
  }

  void updateSurgeProtectorSelectedStatus({
    required String applicationId,
    required String component,
    required String protector,
    required bool selected,
  }) async {
    await _surgeProtectorRepository.updateSurgeProtectorsSelectedStatus(
        applicationId, selected, component, protector);
  }

  Future<bool> checkSurgeProtectorExists(
      String applicationId, String component, String name) {
    return _surgeProtectorRepository.checkSurgeProtectorExists(
        applicationId, component, name);
  }

  Future<List<SurgeProtectorModel>> getFutureSelectedSurgeProtectors(
      String applicationId, String component) async {
    return await _surgeProtectorRepository.getFutureSelectedSurgeProtectors(
        applicationId, component);
  }

  Stream<List<SurgeProtectorModel>> getStreamSelectedSurgeProtectors(
      String applicationId, String component) {
    return _surgeProtectorRepository.getStreamSelectedSurgeProtectors(
        applicationId, component);
  }

  Stream<List<SurgeProtectorModel>> getSurgeProtectors(
      String applicationId, String component) {
    return _surgeProtectorRepository.getSurgeProtectorsFromApplication(
        applicationId, component);
  }
}
