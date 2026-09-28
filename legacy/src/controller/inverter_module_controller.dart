import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/inverter_module_model.dart';
import 'package:solar_project/src/repository/inverter_module_repository.dart';

final getModulesStreamProvider =
    StreamProvider.family<List<InverterModuleModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(inverterModuleControllerProvider)
      .getModules(arguments[0], arguments[1]);
});

final getSelectedModulesStreamProvider =
    StreamProvider.family<List<InverterModuleModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(inverterModuleControllerProvider)
      .getStreamSelectedModules(arguments[0], arguments[1]);
});

final getFutureSelectedModulesProvider =
    FutureProvider.family<List<InverterModuleModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(inverterModuleControllerProvider)
      .getFutureSelectedModules(arguments[0], arguments[1]);
});

final inverterModuleControllerProvider = Provider(
  (ref) => InverterModuleController(
    inverterModuleRepository: ref.watch(inverterModuleRepositoryProvider),
  ),
);

class InverterModuleController {
  final InverterModuleRepository _inverterModuleRepository;

  InverterModuleController(
      {required InverterModuleRepository inverterModuleRepository})
      : _inverterModuleRepository = inverterModuleRepository;

  void saveModulesToApplication(
      {required String applicationId, required String component}) async {
    final modules = await _inverterModuleRepository.getModules(component);
    for (InverterModuleModel module in modules) {
      await _inverterModuleRepository.saveModulesToApplication(
          applicationId, module, component);
    }
  }

  void updateModulesSelectedStatus({
    required String applicationId,
    required String component,
    required String module,
    required bool selected,
  }) async {
    await _inverterModuleRepository.updateModulesSelectedStatus(
        applicationId, selected, component, module);
  }

  Future<bool> checkModuleExists(
      String applicationId, String component, String name) {
    return _inverterModuleRepository.checkModuleExists(
        applicationId, component, name);
  }

  Future<List<InverterModuleModel>> getFutureSelectedModules(
      String applicationId, String component) async {
    return await _inverterModuleRepository.getFutureSelectedModules(
        applicationId, component);
  }

  Stream<List<InverterModuleModel>> getStreamSelectedModules(
      String applicationId, String component) {
    return _inverterModuleRepository.getStreamSelectedModules(
        applicationId, component);
  }

  Stream<List<InverterModuleModel>> getModules(
      String applicationId, String component) {
    return _inverterModuleRepository.getModulesFromApplication(
        applicationId, component);
  }
}
