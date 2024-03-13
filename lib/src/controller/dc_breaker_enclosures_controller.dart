import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/dc_breaker_enclosure_model.dart';
import 'package:solar_project/src/repository/dc_breaker_enclosure_repository.dart';

final getBreakerEnclosuresStreamProvider =
    StreamProvider.family<List<DCBreakerEnclosureModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(dcBreakerEnclosureControllerProvider)
      .getBreakerEnclosures(arguments[0], arguments[1]);
});

final getSelectedBreakerEnclosuresStreamProvider =
    StreamProvider.family<List<DCBreakerEnclosureModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(dcBreakerEnclosureControllerProvider)
      .getStreamSelectedBreakerEnclosures(arguments[0], arguments[1]);
});

final dcBreakerEnclosureControllerProvider = Provider(
  (ref) => DCBreakerEnclosureController(
    dcBreakerEnclosureRepository:
        ref.watch(dcBreakerEnclosureRepositoryProvider),
  ),
);

class DCBreakerEnclosureController {
  final DCBreakerEnclosureRepository _dcBreakerEnclosureRepository;

  DCBreakerEnclosureController(
      {required DCBreakerEnclosureRepository dcBreakerEnclosureRepository})
      : _dcBreakerEnclosureRepository = dcBreakerEnclosureRepository;

  void saveBreakerEnclosuresToApplication(
      {required String applicationId, required String component}) async {
    final enclosures =
        await _dcBreakerEnclosureRepository.getBreakerEnclosures(component);
    for (DCBreakerEnclosureModel enclosure in enclosures) {
      await _dcBreakerEnclosureRepository.saveBreakerEnclosuresToApplication(
          applicationId, enclosure, component);
    }
  }

  void updateBreakerEnclosureSelectedStatus({
    required String applicationId,
    required String component,
    required String enclosure,
    required bool selected,
  }) async {
    await _dcBreakerEnclosureRepository.updateBreakerEnclosuresSelectedStatus(
        applicationId, selected, component, enclosure);
  }

  Future<bool> checkBreakerEnclosureExists(
      String applicationId, String component, String name) {
    return _dcBreakerEnclosureRepository.checkBreakerEnclosureExists(
        applicationId, component, name);
  }

  Future<List<DCBreakerEnclosureModel>> getFutureSelectedBreakerEnclosures(
      String applicationId, String component) async {
    return await _dcBreakerEnclosureRepository
        .getFutureSelectedBreakerEnclosures(applicationId, component);
  }

  Stream<List<DCBreakerEnclosureModel>> getStreamSelectedBreakerEnclosures(
      String applicationId, String component) {
    return _dcBreakerEnclosureRepository.getStreamSelectedBreakerEnclosures(
        applicationId, component);
  }

  Stream<List<DCBreakerEnclosureModel>> getBreakerEnclosures(
      String applicationId, String component) {
    return _dcBreakerEnclosureRepository.getBreakerEnclosuresFromApplication(
        applicationId, component);
  }
}
