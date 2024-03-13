import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/dc_breaker_model.dart';
import 'package:solar_project/src/repository/dc_breaker_repository.dart';

final getBreakersStreamProvider =
    StreamProvider.family<List<DCBreakerModel>, List<String>>((ref, arguments) {
  return ref
      .watch(dcBreakerControllerProvider)
      .getBreakers(arguments[0], arguments[1]);
});

final getSelectedBreakersStreamProvider =
    StreamProvider.family<List<DCBreakerModel>, List<String>>((ref, arguments) {
  return ref
      .watch(dcBreakerControllerProvider)
      .getStreamSelectedBreakers(arguments[0], arguments[1]);
});

final dcBreakerControllerProvider = Provider(
  (ref) => DCBreakerController(
    dcBreakerRepository: ref.watch(dcBreakerRepositoryProvider),
  ),
);

class DCBreakerController {
  final DCBreakerRepository _dcBreakerRepository;

  DCBreakerController({required DCBreakerRepository dcBreakerRepository})
      : _dcBreakerRepository = dcBreakerRepository;

  void saveBreakersToApplication(
      {required String applicationId, required String component}) async {
    final breakers = await _dcBreakerRepository.getBreakers(component);
    for (DCBreakerModel breaker in breakers) {
      await _dcBreakerRepository.saveBreakersToApplication(
          applicationId, breaker, component);
    }
  }

  void updateBreakersSelectedStatus({
    required String applicationId,
    required String component,
    required String breaker,
    required bool selected,
  }) async {
    await _dcBreakerRepository.updateBreakersSelectedStatus(
        applicationId, selected, component, breaker);
  }

  Future<bool> checkBreakerExists(
      String applicationId, String component, String name) {
    return _dcBreakerRepository.checkBreakerExists(
        applicationId, component, name);
  }

  Future<List<DCBreakerModel>> getFutureSelectedBreakers(
      String applicationId, String component) async {
    return await _dcBreakerRepository.getFutureSelectedBreakers(
        applicationId, component);
  }

  Stream<List<DCBreakerModel>> getStreamSelectedBreakers(
      String applicationId, String component) {
    return _dcBreakerRepository.getStreamSelectedBreakers(
        applicationId, component);
  }

  Stream<List<DCBreakerModel>> getBreakers(
      String applicationId, String component) {
    return _dcBreakerRepository.getBreakerFromApplication(
        applicationId, component);
  }
}
