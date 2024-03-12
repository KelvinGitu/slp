import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/core_cable_model.dart';
import 'package:solar_project/src/repository/pv_cables_repository.dart';


final getPVCablesStreamProvider =
    StreamProvider.family<List<CoreCableModel>, List<String>>((ref, arguments) {
  return ref
      .watch(pvCablesControllerProvider)
      .getPVCables(arguments[0], arguments[1]);
});

final pvCablesControllerProvider = Provider(
  (ref) => PVCablesController(
    pvCablesRepository: ref.watch(pvCablesRepositoryProvider),
  ),
);

class PVCablesController {
  final PVCablesRepository _pvCablesRepository;

  PVCablesController({required PVCablesRepository pvCablesRepository})
      : _pvCablesRepository = pvCablesRepository;

      
  // these functions save pv cables in the application
  // retrives pv cables from application

  void savePVCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables = await _pvCablesRepository.getPVCables(component);
    for (CoreCableModel cable in cables) {
      await _pvCablesRepository.savePVCablesToApplication(
          applicationId, cable, component);
    }
  }

  Stream<List<CoreCableModel>> getPVCables(
      String applicationId, String component) {
    return _pvCablesRepository.getPVCablesFromApplication(
        applicationId, component);
  }
}
