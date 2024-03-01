import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/battery_capacity_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/models/isolator_switch_model.dart';
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

final getBatteryCapacityStreamProvider =
    StreamProvider.family<List<BatteryCapacityModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getBatteryCapacity(arguments[0], arguments[1]);
});

final getIsolatorSwitchStreamProvider =
    StreamProvider.family<List<IsolatorSwitchModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getIsolatorSwitch(arguments[0], arguments[1]);
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

final getApplicationComponentsStreamProvider =
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

  void saveComponent() async {
    ComponentsModel componentsModel = ComponentsModel(
      name: 'Inverter Manual Isolator',
      cost: 0,
      dependents: false,
      isSelected: false,
      measurement: ['depends on the KVA rating of the panels'],
      number: 6,
      quantity: 0,
      length: 0,
      weight: 0,
      capacity: 0,
    );
    await _solarRepository.saveComponent(componentsModel);
  }

  Stream<List<ComponentsModel>> getAllComponents() {
    return _solarRepository.getAllComponents();
  }

  Stream<List<ComponentsModel>> getApplicationComponents(String applicationId) {
    return _solarRepository.getApplicationComponents(applicationId);
  }

  Stream<ComponentsModel> getComponent(String component) {
    return _solarRepository.getComponent(component);
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

  void updateApplicationSelectedStatus(
      String component, bool selected, String applicationId) async {
    _solarRepository.updateComponentSelectedStatus(
        applicationId, selected, component);
  }

  void updateComponentCost(
      String component, int cost, String applicationId) async {
    _solarRepository.updateComponentCost(applicationId, cost, component);
  }

  void updateComponentQuantity(
      String component, int quantity, String applicationId) async {
    _solarRepository.updateComponentQuantity(
        applicationId, quantity, component);
  }

  void updateComponentCapacity(
      String component, int capacity, String applicationId) async {
    _solarRepository.updateComponentCapacity(
        applicationId, capacity, component);
  }


   void updateComponentLength(
      String component, int length, String applicationId) async {
    _solarRepository.updateComponentLength(
        applicationId, length, component);
  }

  void updateApplicationComponentsCostListAdd(
      String applicationId, int componentCost) async {
    await _solarRepository.updateApplicationComponentsCostListAdd(
        applicationId, componentCost);
  }

  void updateApplicationComponentsCostListRemove(
      String applicationId, int componentCost) async {
    await _solarRepository.updateApplicationComponentsCostListRemove(
        applicationId, componentCost);
  }

  void updateApplicationQuotation(String applicationId) async {
    int quotation = 0;
    final application =
        await _solarRepository.getAllFutureApplicationComponents(applicationId);

    for (ComponentsModel component in application) {
      quotation = quotation + component.cost;
      _solarRepository.updateApplicationQuotation(applicationId, quotation);
    }
  }

  void createApplication({required applicationId, required clientName}) async {
    ApplicationModel applicationModel = ApplicationModel(
      applicationId: applicationId,
      clientName: clientName,
      expertName: 'expertName',
      expertId: 'expertId',
      quotation: 0,
      isDone: false,
    );
    await _solarRepository.createApplication(applicationId, applicationModel);
  }

  void saveBatteryCapacityToApplication(
      {required String applicationId, required String component}) async {
    final capacities = await _solarRepository.getBatteryCapacity(component);
    for (BatteryCapacityModel capacity in capacities) {
      await _solarRepository.saveBatteryCapacityToApplication(
          applicationId, capacity, component);
    }
  }

  void saveIsolatorSwitchToApplication(
      {required String applicationId, required String component}) async {
    final isolators = await _solarRepository.getIsolatorSwitch(component);
    for (IsolatorSwitchModel isolator in isolators) {
      await _solarRepository.saveManualIsolatorsToApplication(
          applicationId, isolator, component);
    }
  }

  Stream<ApplicationModel> getApplication(String applicationId) {
    return _solarRepository.getApplication(applicationId);
  }

  Stream<List<ApplicationModel>> getAllApplications() {
    return _solarRepository.getAllApplications();
  }

  Future<ApplicationModel> getFutureApplication(String applicationId) async {
    return _solarRepository.getFutureApplication(applicationId);
  }

  Stream<List<BatteryCapacityModel>> getBatteryCapacity(
      String applicationId, String component) {
    return _solarRepository.getBatteryCapacityFromApplication(
        applicationId, component);
  }

  Stream<List<IsolatorSwitchModel>> getIsolatorSwitch(
      String applicationId, String component) {
    return _solarRepository.getIsolatorSwitchFromApplication(
        applicationId, component);
  }

  void saveComponentsToApplication({required applicationId}) async {
    final allComponents = await _solarRepository.getAllFutureComponents();
    for (ComponentsModel component in allComponents) {
      _solarRepository.saveComponentsToApplication(applicationId, component);
    }
  }
}
