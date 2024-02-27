import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/repository/solar_repository.dart';

final getAllComponentsStreamProvider = StreamProvider((ref) {
  return ref.watch(solarControllerProvider).getAllComponents();
});

final getComponentStreamProvider =
    StreamProvider.family((ref, String component) {
  return ref.watch(solarControllerProvider).getComponent(component);
});

final getApplicationComponentStreamProvider =
    StreamProvider.family((ref, String applicationId) {
  return ref
      .watch(solarControllerProvider)
      .getApplicationComponents(applicationId);
});

final solarControllerProvider = Provider(
  (ref) => SolarController(
    solarRepository: ref.watch(solarRepositoryProvider),
  ),
);

class SolarController {
  final SolarRepository _solarRepository;

  SolarController({required SolarRepository solarRepository})
      : _solarRepository = solarRepository;

  Stream<List<ComponentsModel>> getAllComponents() {
    return _solarRepository.getAllComponents();
  }

  Stream<List<ComponentsModel>> getApplicationComponents(String applicationId) {
    return _solarRepository.getApplicationComponents(applicationId);
  }

  Stream<ComponentsModel> getComponent(String component) {
    return _solarRepository.getComponent(component);
  }

  void updateApplicationSelectedStatus(
      String component, bool selected, String applicationId) async {
    _solarRepository.updateComponentSelectedStatus(
        applicationId, selected, component);
  }

  void updateApplicationCost(
      String component, int cost, String applicationId) async {
    _solarRepository.updateComponentCost(applicationId, cost, component);
  }

  void updateApplicationComponentsList(String applicationId) async {
    final components =
        await _solarRepository.getAllFutureApplicationComponents(applicationId);
    await _solarRepository.updateApplicationComponentsList(
        applicationId, components);
  }

  void updateApplicationQuotation(
      String component, String applicationId) async {
    int quotation = 0;
    final application =
        await _solarRepository.getFutureApplication(applicationId);
    List<ComponentsModel> components = application.components;
    for (ComponentsModel component in components) {
      quotation = quotation + component.cost;
    }
    _solarRepository.updateApplicationQuotation(applicationId, quotation);
  }

  void createApplication({required applicationId}) async {
    ApplicationModel applicationModel = ApplicationModel(
      applicationId: applicationId,
      clientName: 'clientName',
      expertName: 'expertName',
      expertId: 'expertId',
      quotation: 0,
      isDone: false,
      components: [],
    );
    await _solarRepository.createApplication(applicationId, applicationModel);
  }

  void updateClientName({
    required String clientName,
    required String applicationId,
    // required ApplicationModel applicationModel,
  }) async {
    await _solarRepository.updateClientName(applicationId, clientName);
  }

  Stream<ApplicationModel> getApplication(String applicationId) {
    return _solarRepository.getApplication(applicationId);
  }

  Future<ApplicationModel> getFutureApplication(String applicationId) async {
    return _solarRepository.getFutureApplication(applicationId);
  }

  void saveComponentsToApplication({required applicationId}) async {
    final allComponents = await _solarRepository.getAllFutureComponents();
    for (ComponentsModel component in allComponents) {
      _solarRepository.saveComponentsToApplication(applicationId, component);
    }
  }
}
