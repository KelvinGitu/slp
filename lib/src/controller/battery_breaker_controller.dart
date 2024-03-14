import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_breaker_model.dart';
import 'package:solar_project/src/repository/battery_breaker_repository.dart';

final getBatteryBreakersStreamProvider =
    StreamProvider.family<List<DCBatteryBreakerModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryBreakerControllerProvider)
      .getBatteryBreakers(arguments[0], arguments[1]);
});

final getSelectedBatteryBreakersStreamProvider =
    StreamProvider.family<List<DCBatteryBreakerModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryBreakerControllerProvider)
      .getStreamSelectedBatteryBreakers(arguments[0], arguments[1]);
});

final batteryBreakerControllerProvider = Provider(
  (ref) => BatteryBreakerController(
    batteryBreakersRepository: ref.watch(batteryBreakerRepositoryProvider),
  ),
);

class BatteryBreakerController {
  final BatteryBreakersRepository _batteryBreakersRepository;

  BatteryBreakerController(
      {required BatteryBreakersRepository batteryBreakersRepository})
      : _batteryBreakersRepository = batteryBreakersRepository;

  void saveBatteryBreakersToApplication(
      {required String applicationId, required String component}) async {
    final breakers =
        await _batteryBreakersRepository.getBatteryBreakers(component);
    for (DCBatteryBreakerModel breaker in breakers) {
      await _batteryBreakersRepository.saveBatteryBreakersToApplication(
          applicationId, breaker, component);
    }
  }

  void updateBatteryBreakersSelectedStatus({
    required String applicationId,
    required String component,
    required String breaker,
    required bool selected,
  }) async {
    await _batteryBreakersRepository.updateBatteryBreakersSelectedStatus(
        applicationId, selected, component, breaker);
  }

  Future<bool> checkBatteryBreakerExists(
      String applicationId, String component, String name) {
    return _batteryBreakersRepository.checkBatteryBreakerExists(
        applicationId, component, name);
  }

  Future<List<DCBatteryBreakerModel>> getFutureSelectedBatteryBreakers(
      String applicationId, String component) async {
    return await _batteryBreakersRepository.getFutureSelectedBatteryBreakers(
        applicationId, component);
  }

  Stream<List<DCBatteryBreakerModel>> getStreamSelectedBatteryBreakers(
      String applicationId, String component) {
    return _batteryBreakersRepository.getStreamSelectedBatteryBreakers(
        applicationId, component);
  }

  Stream<List<DCBatteryBreakerModel>> getBatteryBreakers(
      String applicationId, String component) {
    return _batteryBreakersRepository.getBatteryBreakersFromApplication(
        applicationId, component);
  }
}
