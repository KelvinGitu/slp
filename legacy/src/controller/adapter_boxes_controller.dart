import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/adapter_box_model.dart';
import 'package:solar_project/src/repository/adapter_boxes_repository.dart';

final getBoxesStreamProvider =
    StreamProvider.family<List<AdapterBoxModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(adapterBoxesControllerProvider)
      .getBoxesFromApplication(arguments[0], arguments[1]);
});

final getSelectedBoxesStreamProvider =
    StreamProvider.family<List<AdapterBoxModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(adapterBoxesControllerProvider)
      .getStreamSelectedBoxes(arguments[0], arguments[1]);
});

final getFutureSelectedBoxesStreamProvider =
    FutureProvider.family<List<AdapterBoxModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(adapterBoxesControllerProvider)
      .getFutureSelectedBoxes(arguments[0], arguments[1]);
});

final adapterBoxesControllerProvider = Provider(
  (ref) => AdapterBoxesController(
    adapterBoxesRepository: ref.watch(adapterBoxesRepositoryProvider),
  ),
);

class AdapterBoxesController {
  final AdapterBoxesRepository _adapterBoxesRepository;

  AdapterBoxesController(
      {required AdapterBoxesRepository adapterBoxesRepository})
      : _adapterBoxesRepository = adapterBoxesRepository;

  // these functions save adapter box enclosures in the application
  // updates selected boxes status
  // retrieves selected boxes from application

  void saveBoxesToApplication(
      {required String applicationId, required String component}) async {
    final boxes = await _adapterBoxesRepository.getBoxes(component);
    for (AdapterBoxModel box in boxes) {
      await _adapterBoxesRepository.saveBoxesToApplication(
          applicationId, box, component);
    }
  }

  void updateBoxSelectedStatus({
    required String applicationId,
    required String component,
    required String box,
    required bool selected,
  }) async {
    await _adapterBoxesRepository.updateBoxesSelectedStatus(
        applicationId, selected, component, box);
  }

  Future<bool> checkBoxExists(
      String applicationId, String component, String name) {
    return _adapterBoxesRepository.checkBoxExists(
        applicationId, component, name);
  }

  Future<List<AdapterBoxModel>> getFutureSelectedBoxes(
      String applicationId, String component) async {
    return await _adapterBoxesRepository.getFutureSelectedBoxes(
        applicationId, component);
  }

  Stream<List<AdapterBoxModel>> getStreamSelectedBoxes(
      String applicationId, String component) {
    return _adapterBoxesRepository.getStreamSelectedBoxes(
        applicationId, component);
  }

  Stream<List<AdapterBoxModel>> getBoxesFromApplication(
      String applicationId, String component) {
    return _adapterBoxesRepository.getBoxesFromApplication(
        applicationId, component);
  }
}
