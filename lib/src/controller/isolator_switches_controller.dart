import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/isolator_switch_model.dart';
import 'package:solar_project/src/repository/isolator_switches_repository.dart';

final getIsolatorSwitchStreamProvider =
    StreamProvider.family<List<IsolatorSwitchModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(isolatorSwitchesControllerProvider)
      .getIsolatorSwitch(arguments[0], arguments[1]);
});

final isolatorSwitchesControllerProvider = Provider(
  (ref) => IsolatorSwitchesController(
    isolatorSwitchesRepository: ref.watch(isolatorSwitchesRepositoryProvider),
  ),
);

class IsolatorSwitchesController {
  final IsolatorSwitchesRepository _isolatorSwitchesRepository;

  IsolatorSwitchesController(
      {required IsolatorSwitchesRepository isolatorSwitchesRepository})
      : _isolatorSwitchesRepository = isolatorSwitchesRepository;

  // These functions save isolator switches in the application
  // retrives all isolator switches from application

  void saveIsolatorSwitchToApplication(
      {required String applicationId, required String component}) async {
    final isolators =
        await _isolatorSwitchesRepository.getIsolatorSwitch(component);
    for (IsolatorSwitchModel isolator in isolators) {
      await _isolatorSwitchesRepository.saveManualIsolatorsToApplication(
          applicationId, isolator, component);
    }
  }

  Stream<List<IsolatorSwitchModel>> getIsolatorSwitch(
      String applicationId, String component) {
    return _isolatorSwitchesRepository.getIsolatorSwitchFromApplication(
        applicationId, component);
  }
}
