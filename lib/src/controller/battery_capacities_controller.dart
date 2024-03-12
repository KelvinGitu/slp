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

  Stream<List<BatteryCapacityModel>> getBatteryCapacity(
      String applicationId, String component) {
    return _batteryCapacitiesRepository.getBatteryCapacityFromApplication(
        applicationId, component);
  }
}
