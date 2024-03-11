import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/adapter_box_model.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/battery_cable_model.dart';
import 'package:solar_project/models/battery_capacity_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/models/core_cable_model.dart';
import 'package:solar_project/models/isolator_switch_model.dart';
import 'package:solar_project/models/piping_components_model.dart';
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

final getCoreCablesStreamProvider =
    StreamProvider.family<List<CoreCableModel>, List<String>>((ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getCoreCables(arguments[0], arguments[1]);
});

final getPVCablesStreamProvider =
    StreamProvider.family<List<CoreCableModel>, List<String>>((ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getPVCables(arguments[0], arguments[1]);
});

final getBatteryCablesStreamProvider =
    StreamProvider.family<List<BatteryCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getBatteryCables(arguments[0], arguments[1]);
});

final getSelectedBatteryCablesStreamProvider =
    StreamProvider.family<List<BatteryCableModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getStreamSelectedBatteryCables(arguments[0], arguments[1]);
});

final getPipingComponentsStreamProvider =
    StreamProvider.family<List<PipingComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getPipingComponents(arguments[0], arguments[1]);
});

final getSelectedPipingComponentsStreamProvider =
    StreamProvider.family<List<PipingComponentsModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getStreamSelectedPipingComponents(arguments[0], arguments[1]);
});

final getBoxesStreamProvider =
    StreamProvider.family<List<AdapterBoxModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getBoxesFromApplication(arguments[0], arguments[1]);
});

final getSelectedBoxesStreamProvider =
    StreamProvider.family<List<AdapterBoxModel>, List<String>>(
        (ref, arguments) {
  return ref
      .watch(solarControllerProvider)
      .getStreamSelectedBoxes(arguments[0], arguments[1]);
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
      name: 'Adapter Box Enclosure',
      cost: 0,
      isRequired: true,
      isSelected: false,
      measurement: ['client preference'],
      number: 23,
      quantity: 0,
      length: 0,
      weight: 0,
      capacity: 0,
      crossSection: '',
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

  void updateApplicationRequiredStatus(
      String component, bool required, String applicationId) async {
    _solarRepository.updateComponentRequiredStatus(
        applicationId, required, component);
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
    _solarRepository.updateComponentLength(applicationId, length, component);
  }

  void updateComponentCrossSection(
      String component, String crossSection, String applicationId) async {
    _solarRepository.updateComponentCrossSection(
        applicationId, crossSection, component);
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

  void saveCoreCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables = await _solarRepository.getCoreCables(component);
    for (CoreCableModel cable in cables) {
      await _solarRepository.saveCoreCablesToApplication(
          applicationId, cable, component);
    }
  }

  void savePVCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables = await _solarRepository.getPVCables(component);
    for (CoreCableModel cable in cables) {
      await _solarRepository.savePVCablesToApplication(
          applicationId, cable, component);
    }
  }

  void saveBatteryCablesToApplication(
      {required String applicationId, required String component}) async {
    final cables = await _solarRepository.getBatteryCables(component);
    for (BatteryCableModel cable in cables) {
      await _solarRepository.saveBatteryCablesToApplication(
          applicationId, cable, component);
    }
  }

  void updateBatteryCableSelectedStatus({
    required String applicationId,
    required String component,
    required String cable,
    required bool selected,
  }) async {
    await _solarRepository.updateBatteryCableSelectedStatus(
        applicationId, selected, component, cable);
  }

  void updateBatteryCableLength({
    required String applicationId,
    required String component,
    required String cable,
    required int length,
  }) async {
    await _solarRepository.updateBatteryCableLength(
        applicationId, length, component, cable);
  }

  void updateBatteryCableCost({
    required String applicationId,
    required String component,
    required String cable,
    required int cost,
  }) async {
    await _solarRepository.updateBatteryCableCost(
        applicationId, cost, component, cable);
  }

  Future<bool> checkBatteryCableExists(
      String applicationId, String component, String name) {
    return _solarRepository.checkBatteryCableExists(
        applicationId, component, name);
  }

  Future<List<BatteryCableModel>> getFutureSelectedBatteryCables(
      String applicationId, String component) async {
    return await _solarRepository.getFutureSelectedBatteryCables(
        applicationId, component);
  }

  Stream<List<BatteryCableModel>> getStreamSelectedBatteryCables(
      String applicationId, String component) {
    return _solarRepository.getStreamSelectedBatteryCables(
        applicationId, component);
  }

  void savePipingComponentsToApplication(
      {required String applicationId, required String component}) async {
    final pipings = await _solarRepository.getPipingComponents(component);
    for (PipingComponentsModel piping in pipings) {
      await _solarRepository.savePipingComponetsToApplication(
          applicationId, piping, component);
    }
  }

  void updatePipingComponentSelectedStatus({
    required String applicationId,
    required String component,
    required String piping,
    required bool selected,
  }) async {
    await _solarRepository.updatePipingComponentSelectedStatus(
        applicationId, selected, component, piping);
  }

  void updatePipingComponentLength({
    required String applicationId,
    required String component,
    required String piping,
    required int length,
  }) async {
    await _solarRepository.updatePipingComponentLength(
        applicationId, length, component, piping);
  }

  void updatePipingComponentQuantity({
    required String applicationId,
    required String component,
    required String piping,
    required int quantity,
  }) async {
    await _solarRepository.updatePipingComponentQuantity(
        applicationId, quantity, component, piping);
  }

  void updatePipingComponentCost({
    required String applicationId,
    required String component,
    required String piping,
    required int cost,
  }) async {
    await _solarRepository.updatePipingComponentCost(
        applicationId, cost, component, piping);
  }

  Future<bool> checkPipingComponentExists(
      String applicationId, String component, String name) {
    return _solarRepository.checkPipingComponentExists(
        applicationId, component, name);
  }

  void saveBoxesToApplication(
      {required String applicationId, required String component}) async {
    final boxes = await _solarRepository.getBoxes(component);
    for (AdapterBoxModel box in boxes) {
      await _solarRepository.saveBoxesToApplication(
          applicationId, box, component);
    }
  }

  void updateBoxSelectedStatus({
    required String applicationId,
    required String component,
    required String box,
    required bool selected,
  }) async {
    await _solarRepository.updateBoxesSelectedStatus(
        applicationId, selected, component, box);
  }

  Future<bool> checkBoxExists(
      String applicationId, String component, String name) {
    return _solarRepository.checkBoxExists(applicationId, component, name);
  }

  Future<List<PipingComponentsModel>> getFutureSelectedPipingComponents(
      String applicationId, String component) async {
    return await _solarRepository.getFutureSelectedPipingComponents(
        applicationId, component);
  }

  Stream<List<PipingComponentsModel>> getStreamSelectedPipingComponents(
      String applicationId, String component) {
    return _solarRepository.getStreamSelectedPipingComponents(
        applicationId, component);
  }

  Future<List<AdapterBoxModel>> getFutureSelectedBoxes(
      String applicationId, String component) async {
    return await _solarRepository.getFutureSelectedBoxes(
        applicationId, component);
  }

  Stream<List<AdapterBoxModel>> getStreamSelectedBoxes(
      String applicationId, String component) {
    return _solarRepository.getStreamSelectedBoxes(applicationId, component);
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

  Stream<List<CoreCableModel>> getCoreCables(
      String applicationId, String component) {
    return _solarRepository.getCoreCablesFromApplication(
        applicationId, component);
  }

  Stream<List<CoreCableModel>> getPVCables(
      String applicationId, String component) {
    return _solarRepository.getPVCablesFromApplication(
        applicationId, component);
  }

  Stream<List<BatteryCableModel>> getBatteryCables(
      String applicationId, String component) {
    return _solarRepository.getBatteryCablesFromApplication(
        applicationId, component);
  }

  Stream<List<PipingComponentsModel>> getPipingComponents(
      String applicationId, String component) {
    return _solarRepository.getPipingComponentsFromApplication(
        applicationId, component);
  }

  Stream<List<AdapterBoxModel>> getBoxesFromApplication(
      String applicationId, String component) {
    return _solarRepository.getBoxesFromApplication(applicationId, component);
  }

  void saveComponentsToApplication({required applicationId}) async {
    final allComponents = await _solarRepository.getAllFutureComponents();
    for (ComponentsModel component in allComponents) {
      _solarRepository.saveComponentsToApplication(applicationId, component);
    }
  }
}
