import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/line_fuse_model.dart';
import 'package:solar_project/src/repository/line_fuse_repository.dart';

final getLineFusesStreamProvider =
    StreamProvider.family<List<LineFuseModel>, List<String>>((ref, arguments) {
  return ref
      .watch(lineFuseControllerProvider)
      .getFuses(arguments[0], arguments[1]);
});

final getSelectedLineFusesStreamProvider =
    StreamProvider.family<List<LineFuseModel>, List<String>>((ref, arguments) {
  return ref
      .watch(lineFuseControllerProvider)
      .getStreamSelectedFuses(arguments[0], arguments[1]);
});

final getFutureSelectedLineFusesProvider =
    FutureProvider.family<List<LineFuseModel>, List<String>>((ref, arguments) {
  return ref
      .watch(lineFuseControllerProvider)
      .getFutureSelectedFuses(arguments[0], arguments[1]);
});

final lineFuseControllerProvider = Provider(
  (ref) => LineFuseController(
    lineFuseRepository: ref.watch(lineFuseRepositoryPrrovider),
  ),
);

class LineFuseController {
  final LineFuseRepository _lineFuseRepository;

  LineFuseController({required LineFuseRepository lineFuseRepository})
      : _lineFuseRepository = lineFuseRepository;

  void saveFusesToApplication(
      {required String applicationId, required String component}) async {
    final fuses = await _lineFuseRepository.getFuses(component);
    for (LineFuseModel fuse in fuses) {
      await _lineFuseRepository.saveFusesToApplication(
          applicationId, fuse, component);
    }
  }

  void updateFuseSelectedStatus({
    required String applicationId,
    required String component,
    required String fuse,
    required bool selected,
  }) async {
    await _lineFuseRepository.updateFusesSelectedStatus(
        applicationId, selected, component, fuse);
  }

  Future<bool> checkFuseExists(
      String applicationId, String component, String name) {
    return _lineFuseRepository.checkFuseExists(applicationId, component, name);
  }

  Future<List<LineFuseModel>> getFutureSelectedFuses(
      String applicationId, String component) async {
    return await _lineFuseRepository.getFutureSelectedFuses(
        applicationId, component);
  }

  Stream<List<LineFuseModel>> getStreamSelectedFuses(
      String applicationId, String component) {
    return _lineFuseRepository.getStreamSelectedFuses(applicationId, component);
  }

  Stream<List<LineFuseModel>> getFuses(String applicationId, String component) {
    return _lineFuseRepository.getFusesFromApplication(
        applicationId, component);
  }
}
