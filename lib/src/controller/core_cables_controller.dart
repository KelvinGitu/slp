import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/core_cable_model.dart';
import 'package:solar_project/src/repository/core_cables_repository.dart';

final getCoreCablesStreamProvider =
    StreamProvider.family<List<CoreCableModel>, List<String>>((ref, arguments) {
  return ref
      .watch(coreCablesControllerProvider)
      .getCoreCables(arguments[0], arguments[1]);
});

final coreCablesControllerProvider = Provider(
  (ref) => CoreCablesController(
    coreCablesRepository: ref.watch(coreCablesRepositoryProvider),
  ),
);

class CoreCablesController {
  final CoreCablesRepository _coreCablesRepository;

  CoreCablesController({required CoreCablesRepository coreCablesRepository})
      : _coreCablesRepository = coreCablesRepository;

  // These functions save core cables in the application
  // retrieves core cables from the application

  void saveCoreCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables = await _coreCablesRepository.getCoreCables(component);
    for (CoreCableModel cable in cables) {
      await _coreCablesRepository.saveCoreCablesToApplication(
          applicationId, cable, component);
    }
  }

  Future<bool> checkCoreCableExists(
      String applicationId, String component, String name) {
    return _coreCablesRepository.checkCoreCableExists(
        applicationId, component, name);
  }


  Stream<List<CoreCableModel>> getCoreCables(
      String applicationId, String component) {
    return _coreCablesRepository.getCoreCablesFromApplication(
        applicationId, component);
  }
}
