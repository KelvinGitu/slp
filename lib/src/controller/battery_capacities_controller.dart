import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/battery_capacity_model.dart';
import 'package:solar_project/src/repository/battery_capacities_repository.dart';

final getBatteryCapacityStreamProvider =
    StreamProvider.family<List<BatteryCapacityModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryCapacitiesControllerProvider)
      .getBatteryCapacity(arguments[0], arguments[1]);
});

final getFutureSelectedBatteryCapacityProvider =
    FutureProvider.family<List<BatteryCapacityModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(batteryCapacitiesControllerProvider)
      .getFutureSelectedBatteryCapacities(arguments[0], arguments[1]);
});

final batteryCapacitiesControllerProvider = Provider(
  (ref) => BatteryCapacitiesController(
    batteryCapacitiesRepository: ref.watch(batteryCapacityRepositoryProvider),
  ),
);

class BatteryCapacitiesController {
  final BatteryCapacitiesRepository _batteryCapacitiesRepository;

  BatteryCapacitiesController(
      {required BatteryCapacitiesRepository batteryCapacitiesRepository})
      : _batteryCapacitiesRepository = batteryCapacitiesRepository;

  void saveBatteryCapacityToApplication(
      {required String applicationId, required String component}) async {
    final capacities =
        await _batteryCapacitiesRepository.getBatteryCapacity(component);
    for (BatteryCapacityModel capacity in capacities) {
      await _batteryCapacitiesRepository.saveBatteryCapacityToApplication(
          applicationId, capacity, component);
    }
  }

  void updateBatteryCapacitySelectedStatus({
    required String applicationId,
    required String component,
    required int capacity,
    required bool selected,
  }) async {
    await _batteryCapacitiesRepository.updateBatteryCapacitySelectedStatus(
        applicationId, selected, component, capacity);
  }

  Future<bool> checkBatteryCapacityExists(
      String applicationId, String component, String name) {
    return _batteryCapacitiesRepository.checkBatteryCapcityExists(
        applicationId, component, name);
  }

   Future<List<BatteryCapacityModel>> getFutureSelectedBatteryCapacities(
      String applicationId, String component) async {
    return await _batteryCapacitiesRepository.getFutureSelectedBatteryCapacity(
        applicationId, component);
  }

  Stream<List<BatteryCapacityModel>> getBatteryCapacity(
      String applicationId, String component) {
    return _batteryCapacitiesRepository.getBatteryCapacityFromApplication(
        applicationId, component);
  }
}
