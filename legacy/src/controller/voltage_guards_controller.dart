import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/voltage_guard_model.dart';
import 'package:solar_project/src/repository/voltage_guard_repository.dart';

final getVoltageGuardsStreamProvider =
    StreamProvider.family<List<VoltagGuardModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(voltageGuardsControllerProvider)
      .getVoltageGuards(arguments[0], arguments[1]);
});

final getSelectedVoltageGuardsStreamProvider =
    StreamProvider.family<List<VoltagGuardModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(voltageGuardsControllerProvider)
      .getStreamSelectedVoltageGuards(arguments[0], arguments[1]);
});

final getFutureSelectedVoltageGuardsProvider =
    FutureProvider.family<List<VoltagGuardModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(voltageGuardsControllerProvider)
      .getFutureSelectedVoltageGuards(arguments[0], arguments[1]);
});

final voltageGuardsControllerProvider = Provider(
  (ref) => VoltageGuardsController(
    voltageGuardRepository: ref.watch(voltageGuardRepositoryProvider),
  ),
);

class VoltageGuardsController {
  final VoltageGuardRepository _voltageGuardRepository;

  VoltageGuardsController(
      {required VoltageGuardRepository voltageGuardRepository})
      : _voltageGuardRepository = voltageGuardRepository;

  void saveVoltageGuardsToApplication(
      {required String applicationId, required String component}) async {
    final guards = await _voltageGuardRepository.getVoltageGuards(component);
    for (VoltagGuardModel guard in guards) {
      await _voltageGuardRepository.saveVolatgeGuardsToApplication(
          applicationId, guard, component);
    }
  }

  void updateVoltageGuardSelectedStatus({
    required String applicationId,
    required String component,
    required String guard,
    required bool selected,
  }) async {
    await _voltageGuardRepository.updateVolatageGuardsSelectedStatus(
        applicationId, selected, component, guard);
  }

  Future<bool> checkVoltageGuardExists(
      String applicationId, String component, String name) {
    return _voltageGuardRepository.checkVoltageGuardExists(
        applicationId, component, name);
  }

  Future<List<VoltagGuardModel>> getFutureSelectedVoltageGuards(
      String applicationId, String component) async {
    return await _voltageGuardRepository.getFutureSelectedVoltageGuards(
        applicationId, component);
  }

  Stream<List<VoltagGuardModel>> getStreamSelectedVoltageGuards(
      String applicationId, String component) {
    return _voltageGuardRepository.getStreamSelectedVoltageGuards(
        applicationId, component);
  }

  Stream<List<VoltagGuardModel>> getVoltageGuards(
      String applicationId, String component) {
    return _voltageGuardRepository.getVoltageGuardsFromApplication(
        applicationId, component);
  }
}
