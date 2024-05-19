import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/src/authentification/controller/auth_controller.dart';
import 'package:solar_project/src/repository/solar_repository.dart';

final getAllComponentsStreamProvider = StreamProvider((ref) {
  return ref.watch(solarControllerProvider).getAllComponents();
});

final getComponentStreamProvider =
    StreamProvider.family((ref, String component) {
  return ref.watch(solarControllerProvider).getComponent(component);
});

final getAllApplicationsStreamProvider = StreamProvider((ref) {
  return ref.watch(solarControllerProvider).getAllApplications();
});

final getApplicationStreamProvider =
    StreamProvider.family((ref, String applicationId) {
  return ref.watch(solarControllerProvider).getApplication(applicationId);
});

final getApplicationComponentStreamProvider =
    StreamProvider.family<ComponentsModel, List<String>>((ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getApplicationComponent(arguments[0], arguments[1]);
});

final getApplcationComponentFutureProvider =
    FutureProvider.family<ComponentsModel, List<String>>((ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getFutureApplicationComponent(arguments[0], arguments[1]);
});

final getFutureSelectedApplicationComponentsFutureProvider =
    FutureProvider.family((ref, String applicationId) {
  return ref
      .watch(solarControllerProvider)
      .getFutureSelectedApplicationComponents(applicationId);
});

final getApplicationComponentsStreamProvider =
    StreamProvider.family((ref, String applicationId) {
  return ref
      .watch(solarControllerProvider)
      .getApplicationComponents(applicationId);
});

final solarControllerProvider = Provider(
  (ref) => SolarController(
    solarRepository: ref.watch(solarRepositoryProvider),
    ref: ref,
  ),
);

// this is where the solar controller class begins
// every variable above this class is either a  provider, stream provider or future provider

class SolarController {
  final SolarRepository _solarRepository;
  final Ref _ref;

  SolarController({required SolarRepository solarRepository, required Ref ref})
      : _solarRepository = solarRepository,
        _ref = ref;

  // this function saves components to firestore

  void saveComponent() async {
    ComponentsModel componentsModel = ComponentsModel(
      name: 'Miscellaneous',
      cost: 0,
      isRequired: true,
      isSelected: false,
      number: 46,
      measurement: [],
      quantity: 0,
      length: 0,
      weight: 0,
      capacity: 0,
      crossSection: '',
    );
    await _solarRepository.saveComponent(componentsModel);
  }

  // these functions fetch components from firestore

  Stream<List<ComponentsModel>> getAllComponents() {
    return _solarRepository.getAllComponents();
  }

  Stream<ComponentsModel> getComponent(String component) {
    return _solarRepository.getComponent(component);
  }

  // these functions are for creating applications, fetching applications,
  // and fetching components in an application
  // updating various component fields such as cost and selected status
  // fetching a stream of applications, fetching an individual application

  void createApplication(
      {required String applicationId, required String clientName}) async {
    final user = _ref.read(userProvider)!;

    ApplicationModel applicationModel = ApplicationModel(
      applicationId: applicationId,
      clientName: clientName,
      expertName: user.name,
      expertId: user.uid,
      quotation: 0,
      isDone: false,
      isDeleted: false,
      createdAt: DateTime.now(),
    );
    await _solarRepository.createApplication(applicationId, applicationModel);
  }

  void deleteApplication({required String applicationId}) async {
    await _solarRepository.deleteApplication(applicationId);
  }

  void saveComponentsToApplication({required applicationId}) async {
    final allComponents = await _solarRepository.getAllFutureComponents();
    for (ComponentsModel component in allComponents) {
      _solarRepository.saveComponentsToApplication(applicationId, component);
    }
  }

  void updateApplicationDoneStatus(String applicationId, bool done) async {
    return _solarRepository.updateApplicationDoneStatus(applicationId, done);
  }

  Stream<ApplicationModel> getApplication(String applicationId) {
    return _solarRepository.getApplication(applicationId);
  }

  Stream<List<ApplicationModel>> getAllApplications() {
    final user = _ref.read(userProvider)!;
    return _solarRepository.getAllApplications(user.uid);
  }

  Future<ApplicationModel> getFutureApplication(String applicationId) async {
    return _solarRepository.getFutureApplication(applicationId);
  }

  Stream<List<ComponentsModel>> getApplicationComponents(String applicationId) {
    return _solarRepository.getApplicationComponents(applicationId);
  }

  Future<List<ComponentsModel>> getFutureSelectedApplicationComponents(
      String applicationId) async {
    return await _solarRepository
        .getFutureSelectedApplicationComponents(applicationId);
  }

  Stream<ComponentsModel> getApplicationComponent(
      String applicationId, String component) {
    return _solarRepository.getApplicationComponent(applicationId, component);
  }

  Future<ComponentsModel> getFutureApplicationComponent(
      String applicationId, String component) async {
    return _solarRepository.getFutureApplicationComponent(
        applicationId, component);
  }

  void updateApplicationComponentSelectedStatus(
      String component, bool selected, String applicationId) async {
    _solarRepository.updateComponentSelectedStatus(
        applicationId, selected, component);
  }

  void updateApplicationComponentRequiredStatus(
      String component, bool required, String applicationId) async {
    _solarRepository.updateComponentRequiredStatus(
        applicationId, required, component);
  }

  void updateApplicationComponentCost(
      String component, int cost, String applicationId) async {
    _solarRepository.updateComponentCost(applicationId, cost, component);
  }

  void updateApplicationComponentQuantity(
      String component, int quantity, String applicationId) async {
    _solarRepository.updateComponentQuantity(
        applicationId, quantity, component);
  }

  void updateApplicationComponentCapacity(
      String component, int capacity, String applicationId) async {
    _solarRepository.updateComponentCapacity(
        applicationId, capacity, component);
  }

  void updateApplicationComponentLength(
      String component, int length, String applicationId) async {
    _solarRepository.updateComponentLength(applicationId, length, component);
  }

  void updateApplicationComponentCrossSection(
      String component, String crossSection, String applicationId) async {
    _solarRepository.updateComponentCrossSection(
        applicationId, crossSection, component);
  }

  void updateApplicationComponentMeasurement(
      String component, String measurement, String applicationId) async {
    _solarRepository.updateComponentMeasurement(
        applicationId, measurement, component);
  }

  void updateApplicationQuotation(String applicationId) async {
    // updates the application's quotation based on individual components
    int quotation = 0;
    final application = await _solarRepository
        .getFutureSelectedApplicationComponents(applicationId);
    if (application.isNotEmpty) {
      for (ComponentsModel component in application) {
        quotation = quotation + component.cost;

        _solarRepository.updateApplicationQuotation(applicationId, quotation);
      }
    } else {
      _solarRepository.updateApplicationQuotation(applicationId, 0);
    }
  }
}
