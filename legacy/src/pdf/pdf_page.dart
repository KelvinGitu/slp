import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/models/adapter_box_model.dart';
import 'package:solar_project/models/application_model.dart';
import 'package:solar_project/models/battery_breaker_model.dart';
import 'package:solar_project/models/battery_cable_model.dart';
import 'package:solar_project/models/battery_capacity_model.dart';
import 'package:solar_project/models/cable_lugs_model.dart';
import 'package:solar_project/models/communication_components_model.dart';
import 'package:solar_project/models/components_model.dart';
import 'package:solar_project/models/dc_breaker_enclosure_model.dart';
import 'package:solar_project/models/dc_breaker_model.dart';
import 'package:solar_project/models/inverter_module_model.dart';
import 'package:solar_project/models/line_fuse_model.dart';
import 'package:solar_project/models/piping_components_model.dart';
import 'package:solar_project/models/single_core_cable_model.dart';
import 'package:solar_project/models/surge_protector_model.dart';
import 'package:solar_project/models/voltage_guard_model.dart';
import 'package:solar_project/src/controller/adapter_boxes_controller.dart';
import 'package:solar_project/src/controller/battery_breaker_controller.dart';
import 'package:solar_project/src/controller/battery_cables_controller.dart';
import 'package:solar_project/src/controller/battery_capacities_controller.dart';
import 'package:solar_project/src/controller/cable_lugs_controller.dart';
import 'package:solar_project/src/controller/communication_components_controller.dart';
import 'package:solar_project/src/controller/dc_breaker_controller.dart';
import 'package:solar_project/src/controller/dc_breaker_enclosures_controller.dart';
import 'package:solar_project/src/controller/inverter_module_controller.dart';
import 'package:solar_project/src/controller/line_fuse_controller.dart';
import 'package:solar_project/src/controller/piping_components_controller.dart';
import 'package:solar_project/src/controller/single_core_cables_controller.dart';

import 'package:solar_project/src/controller/solar_controller.dart';
import 'package:solar_project/src/controller/surge_protector_controller.dart';
import 'package:solar_project/src/controller/voltage_guards_controller.dart';
import 'package:solar_project/src/home_screen.dart';
import 'package:solar_project/src/pdf/pdf_list_viewer.dart';
import 'package:solar_project/src/pdf/pdf_model.dart';
import 'package:solar_project/src/pdf/pdf_viewer.dart';
import 'package:solar_project/src/widgets/confirm_selection_button.dart';

class PDFPage extends ConsumerStatefulWidget {
  final String applicationId;
  const PDFPage({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PDFPageState();
}

class _PDFPageState extends ConsumerState<PDFPage> {
  late List<String> adapterBoxesArguments;
  late List<String> cableLugsArguments;
  late List<String> batteryBreakerArguments;
  late List<String> batteryCablesArguments;
  late List<String> batteryCapacitiesArguments;
  late List<String> communicationComponentsArguments;
  late List<String> dcBreakerArguments;
  late List<String> dcBreakerEnclosuresArguments;
  late List<String> inverterModuleArguments;
  late List<String> lineFuseArguments;
  late List<String> pipingComponentsArguments;
  late List<String> singleCoreCablesArguments;
  late List<String> surgeProtectorsArguments;
  late List<String> voltageGuardsArguments;

  @override
  void initState() {
    adapterBoxesArguments = [widget.applicationId, 'Adapter Box Enclosure'];
    cableLugsArguments = [widget.applicationId, 'Cable Lugs'];
    batteryBreakerArguments = [widget.applicationId, 'DC Battery Breaker'];
    batteryCablesArguments = [widget.applicationId, 'Battery Cable'];
    batteryCapacitiesArguments = [widget.applicationId, 'Batteries'];
    communicationComponentsArguments = [
      widget.applicationId,
      'Communication Components'
    ];
    dcBreakerArguments = [widget.applicationId, 'DC Breaker'];
    dcBreakerEnclosuresArguments = [
      widget.applicationId,
      'DC Breaker Enclosure'
    ];
    inverterModuleArguments = [widget.applicationId, 'Inverter Module'];
    lineFuseArguments = [widget.applicationId, 'Line Fuse'];
    pipingComponentsArguments = [widget.applicationId, 'Piping'];
    singleCoreCablesArguments = [
      widget.applicationId,
      '1.5mm² Single Core Cable'
    ];
    surgeProtectorsArguments = [widget.applicationId, 'Surge Protector'];
    voltageGuardsArguments = [widget.applicationId, 'Voltage Guard'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final application =
        ref.watch(getApplicationStreamProvider(widget.applicationId));
    final applicationComponents = ref.watch(
        getFutureSelectedApplicationComponentsFutureProvider(
            widget.applicationId));
    final selectedAdapterBoxes =
        ref.watch(getFutureSelectedBoxesStreamProvider(adapterBoxesArguments));
    final selectedCableLugs =
        ref.watch(getFutureSelectedLugsFutureProvider(cableLugsArguments));
    final selectedbatteryBreakers = ref.watch(
        getFutureSelectedBatteryBreakersProvider(batteryBreakerArguments));
    final selectedBatteryCables = ref
        .watch(getFutureSelectedBatteryCablesProvider(batteryCablesArguments));
    final selectedBatteryCapacities = ref.watch(
        getFutureSelectedBatteryCapacityProvider(batteryCapacitiesArguments));
    final selectedCommunicationComponents = ref.watch(
        getFutureSelectedCommunicationComponentsProvider(
            communicationComponentsArguments));
    final selectedBreakers =
        ref.watch(getFutureSelectedBreakersStreamProvider(dcBreakerArguments));
    final selectedBreakerEnclosures = ref.watch(
        getFutureSelectedBreakerEnclosuresProvider(
            dcBreakerEnclosuresArguments));
    final selectedInverterModule =
        ref.watch(getFutureSelectedModulesProvider(inverterModuleArguments));
    final selectedLineFuse =
        ref.watch(getFutureSelectedLineFusesProvider(lineFuseArguments));
    final selectedPipingComponents = ref.watch(
        getFutureSelectedPipingComponentsProvider(pipingComponentsArguments));
    final selectedSingleCoreCable = ref.watch(
        getFutureSelectedSingleCoreCablesProvider(singleCoreCablesArguments));
    final selectedSurgeProtector = ref.watch(
        getFutureSelectedSurgeProtectorsProvider(surgeProtectorsArguments));
    final selectedVoltageGuards = ref
        .watch(getFutureSelectedVoltageGuardsProvider(voltageGuardsArguments));

    return application.when(
      data: (application) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Preview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: applicationComponents.when(
            data: (components) {
              List<AdapterBoxModel> boxes = [];
              selectedAdapterBoxes.whenData((value) {
                boxes = value;
              });
              List<CableLugsModel> lugs = [];
              selectedCableLugs.whenData((value) {
                lugs = value;
              });
              List<DCBatteryBreakerModel> breakers = [];
              selectedbatteryBreakers.whenData((value) {
                breakers = value;
              });
              List<BatteryCableModel> batteryCables = [];
              selectedBatteryCables.whenData((value) {
                batteryCables = value;
              });
              List<BatteryCapacityModel> capacities = [];
              selectedBatteryCapacities.whenData((value) {
                capacities = value;
              });
              List<CommunicationComponentsModel> commComponents = [];
              selectedCommunicationComponents.whenData((value) {
                commComponents = value;
              });
              List<DCBreakerModel> dcBreakers = [];
              selectedBreakers.whenData((value) {
                dcBreakers = value;
              });
              List<DCBreakerEnclosureModel> enclosures = [];
              selectedBreakerEnclosures.whenData((value) {
                enclosures = value;
              });
              List<InverterModuleModel> modules = [];
              selectedInverterModule.whenData((value) {
                modules = value;
              });
              List<LineFuseModel> fuses = [];
              selectedLineFuse.whenData((value) {
                fuses = value;
              });
              List<PipingComponentsModel> piping = [];
              selectedPipingComponents.whenData((value) {
                piping = value;
              });
              List<SingleCoreCableModel> coreCables = [];
              selectedSingleCoreCable.whenData((value) {
                coreCables = value;
              });
              List<SurgeProtectorModel> protectors = [];
              selectedSurgeProtector.whenData((value) {
                protectors = value;
              });
              List<VoltagGuardModel> guards = [];
              selectedVoltageGuards.whenData((value) {
                guards = value;
              });

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${application.clientName}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Contractor: ${application.expertName}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quotation: ${application.quotation}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 40),
                    showOptions(
                      context: context,
                      application: application,
                      components: components,
                      boxes: boxes,
                      lugs: lugs,
                      breakers: breakers,
                      batteryCables: batteryCables,
                      capacities: capacities,
                      commComponents: commComponents,
                      dcBreakers: dcBreakers,
                      enclosures: enclosures,
                      modules: modules,
                      fuses: fuses,
                      piping: piping,
                      coreCables: coreCables,
                      protectors: protectors,
                      guards: guards,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
            error: (error, stacktrace) => Text(error.toString()),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, stacktrace) => Text(error.toString()),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

Widget showOptions({
  required BuildContext context,
  required ApplicationModel application,
  required List<ComponentsModel> components,
  required List<AdapterBoxModel> boxes,
  required List<CableLugsModel> lugs,
  required List<DCBatteryBreakerModel> breakers,
  required List<BatteryCableModel> batteryCables,
  required List<BatteryCapacityModel> capacities,
  required List<CommunicationComponentsModel> commComponents,
  required List<DCBreakerModel> dcBreakers,
  required List<DCBreakerEnclosureModel> enclosures,
  required List<InverterModuleModel> modules,
  required List<LineFuseModel> fuses,
  required List<PipingComponentsModel> piping,
  required List<SingleCoreCableModel> coreCables,
  required List<SurgeProtectorModel> protectors,
  required List<VoltagGuardModel> guards,
}) {
  final size = MediaQuery.of(context).size;
  return Align(
    alignment: Alignment.topCenter,
    child:  ConfirmSelectionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FractionallySizedBox(
                    heightFactor: 0.3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 5,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.withOpacity(0.4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          generateSubComponents(
                            context: context,
                            application: application,
                            components: components,
                            boxes: boxes,
                            lugs: lugs,
                            breakers: breakers,
                            batteryCables: batteryCables,
                            capacities: capacities,
                            commComponents: commComponents,
                            dcBreakers: dcBreakers,
                            enclosures: enclosures,
                            modules: modules,
                            fuses: fuses,
                            piping: piping,
                            coreCables: coreCables,
                            protectors: protectors,
                            guards: guards,
                          ),
                          const SizedBox(height: 15),
                          InkWell(
                              onTap: () {
                                Invoice invoice = Invoice(
                                  quotation: application.quotation,
                                  info: InvoiceInfo(
                                      description: 'description',
                                      number: 'number',
                                      date: DateTime.now(),
                                      dueDate: DateTime.now()),
                                  supplier: Supplier(
                                    name: application.expertName,
                                    address: 'address',
                                    paymentInfo: 'paymentInfo',
                                  ),
                                  customer: Customer(
                                    name: application.clientName,
                                    address: 'address',
                                  ),
                                  items: List.generate(
                                    components.length,
                                    (index) => InvoiceItem(
                                      description: components[index].name,
                                      cost: components[index].cost,
                                      units: components[index].number,
                                      unitPrice: components[index].capacity,
                                      specificItems: [],
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => PDFViewer(
                                          invoice: invoice,
                                        )),
                                  ),
                                );
                              },
                              child: SizedBox(
                                  height: 40,
                                  width: size.width,
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                      'Generate invoice',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))),
                          const SizedBox(height: 15),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => const HomeScreen()),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: SizedBox(
                                  height: 40,
                                  width: size.width,
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                      'Exit',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))),
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
        message: 'See options',
      ),
    );
}

Widget generateSubComponents({
  required BuildContext context,
  required ApplicationModel application,
  required List<ComponentsModel> components,
  required List<AdapterBoxModel> boxes,
  required List<CableLugsModel> lugs,
  required List<DCBatteryBreakerModel> breakers,
  required List<BatteryCableModel> batteryCables,
  required List<BatteryCapacityModel> capacities,
  required List<CommunicationComponentsModel> commComponents,
  required List<DCBreakerModel> dcBreakers,
  required List<DCBreakerEnclosureModel> enclosures,
  required List<InverterModuleModel> modules,
  required List<LineFuseModel> fuses,
  required List<PipingComponentsModel> piping,
  required List<SingleCoreCableModel> coreCables,
  required List<SurgeProtectorModel> protectors,
  required List<VoltagGuardModel> guards,
}) {
  final size = MediaQuery.of(context).size;

  return InkWell(
    onTap: () {
      Invoice invoice = Invoice(
        quotation: application.quotation,
        info: InvoiceInfo(
            description: 'description',
            number: 'number',
            date: DateTime.now(),
            dueDate: DateTime.now()),
        supplier: Supplier(
          name: application.expertName,
          address: 'address',
          paymentInfo: 'paymentInfo',
        ),
        customer: Customer(
          name: application.clientName,
          address: 'address',
        ),
        items: List.generate(
          components.length,
          (index) => InvoiceItem(
            description: components[index].name,
            cost: components[index].cost,
            units: components[index].number,
            unitPrice: components[index].capacity,
            specificItems: (components[index].name == 'Adapter Box Enclosure')
                ? List.generate(
                    boxes.length,
                    (boxIndex) => SpecificInvoiceItem(
                        description: boxes[boxIndex].name, units: '1 unit'))
                : (components[index].name == 'Cable Lugs')
                    ? List.generate(
                        lugs.length,
                        (lugsIndex) => SpecificInvoiceItem(
                            description: lugs[lugsIndex].name,
                            units: '${lugs[lugsIndex].quantity} units'))
                    : (components[index].name == 'DC Battery Breaker')
                        ? List.generate(
                            breakers.length,
                            (breakersIndex) => SpecificInvoiceItem(
                                  description: breakers[breakersIndex].name,
                                  units: '1 unit',
                                ))
                        : (components[index].name == 'Battery Cable')
                            ? List.generate(
                                batteryCables.length,
                                (batteryCablesIndex) => SpecificInvoiceItem(
                                      description:
                                          'Cross section ${batteryCables[batteryCablesIndex].crossSection}',
                                      units:
                                          '${batteryCables[batteryCablesIndex].length}m',
                                    ))
                            : (components[index].name == 'Batteries')
                                ? List.generate(
                                    capacities.length,
                                    (capacitiesIndex) => SpecificInvoiceItem(
                                          description:
                                              'Capacity : ${capacities[capacitiesIndex].capacity}Ah',
                                          units:
                                              '${components[index].quantity} units',
                                        ))
                                : (components[index].name ==
                                        'Communication Components')
                                    ? List.generate(commComponents.length,
                                        (commComponentsIndex) {
                                        String value = '';
                                        if (commComponents[commComponentsIndex]
                                                .name ==
                                            'RJ 45 connectors') {
                                          value =
                                              '${commComponents[commComponentsIndex].quantity} units';
                                        } else {
                                          value =
                                              '${commComponents[commComponentsIndex].length}m';
                                        }
                                        return SpecificInvoiceItem(
                                          description: commComponents[
                                                  commComponentsIndex]
                                              .name,
                                          units: value,
                                        );
                                      })
                                    : (components[index].name == 'DC Breaker')
                                        ? List.generate(
                                            dcBreakers.length,
                                            (dcBreakersIndex) => SpecificInvoiceItem(
                                                description:
                                                    dcBreakers[dcBreakersIndex]
                                                        .name,
                                                units: '1 unit'))
                                        : (components[index].name ==
                                                'DC Breaker Enclosure')
                                            ? List.generate(
                                                enclosures.length,
                                                (enclosuresIndex) => SpecificInvoiceItem(
                                                    description:
                                                        enclosures[enclosuresIndex]
                                                            .name,
                                                    units: '1 unit'))
                                            : (components[index].name ==
                                                    'Inverter Module')
                                                ? List.generate(
                                                    modules.length,
                                                    (modulesIndex) =>
                                                        SpecificInvoiceItem(
                                                            description:
                                                                'Rating: ${modules[modulesIndex].name}',
                                                            units: '1 unit'))
                                                : (components[index].name == 'Line Fuse')
                                                    ? List.generate(
                                                        fuses.length,
                                                        (fusesIndex) =>
                                                            SpecificInvoiceItem(
                                                                description:
                                                                    fuses[fusesIndex]
                                                                        .name,
                                                                units:
                                                                    '1 unit'),
                                                      )
                                                    : (components[index].name == 'Piping')
                                                        ? List.generate(
                                                            piping.length,
                                                            (pipingIndex) =>
                                                                SpecificInvoiceItem(
                                                                    description:
                                                                        piping[pipingIndex]
                                                                            .name,
                                                                    units:
                                                                        '${piping[pipingIndex].quantity} units'),
                                                          )
                                                        : (components[index].name == '1.5mm² Single Core Cable')
                                                            ? List.generate(
                                                                coreCables
                                                                    .length,
                                                                (coreCablesIndex) => SpecificInvoiceItem(
                                                                    description:
                                                                        coreCables[coreCablesIndex]
                                                                            .name,
                                                                    units:
                                                                        '1 unit'),
                                                              )
                                                            : (components[index].name == 'Surge Protector')
                                                                ? List.generate(
                                                                    protectors
                                                                        .length,
                                                                    (protectorsIndex) => SpecificInvoiceItem(
                                                                        description:
                                                                            protectors[protectorsIndex]
                                                                                .name,
                                                                        units:
                                                                            '1 unit'),
                                                                  )
                                                                : (components[index].name == 'Voltage Guard')
                                                                    ? List.generate(
                                                                        guards
                                                                            .length,
                                                                        (guardsIndex) => SpecificInvoiceItem(
                                                                            description:
                                                                                guards[guardsIndex].name,
                                                                            units: '1 unit'),
                                                                      )
                                                                    : (components[index].name == 'Earth Rod and Cable')
                                                                        ? [
                                                                            SpecificInvoiceItem(
                                                                                description: 'Earth rod',
                                                                                units: '${components[index].quantity} units'),
                                                                            SpecificInvoiceItem(
                                                                              description: 'Earthing cable',
                                                                              units: '${components[index].length}m',
                                                                            ),
                                                                          ]
                                                                        : (components[index].name == 'Core Cable')
                                                                            ? [
                                                                                SpecificInvoiceItem(
                                                                                  description: 'Length',
                                                                                  units: '${components[index].length}m',
                                                                                ),
                                                                              ]
                                                                            : (components[index].name == 'PV Cable')
                                                                                ? [
                                                                                    SpecificInvoiceItem(
                                                                                      description: 'Length',
                                                                                      units: '${components[index].length}m',
                                                                                    ),
                                                                                  ]
                                                                                : (components[index].name == 'Panels')
                                                                                    ? [
                                                                                        SpecificInvoiceItem(
                                                                                          description: 'No. of units',
                                                                                          units: '${components[index].quantity}',
                                                                                        ),
                                                                                      ]
                                                                                    : (components[index].name == 'Transport')
                                                                                        ? [
                                                                                            SpecificInvoiceItem(
                                                                                              description: 'Time in minutes',
                                                                                              units: '${components[index].quantity}',
                                                                                            ),
                                                                                          ]
                                                                                        : (components[index].name == 'PVC Trunking')
                                                                                            ? [
                                                                                                SpecificInvoiceItem(
                                                                                                  description: 'Length',
                                                                                                  units: '${components[index].length}m',
                                                                                                ),
                                                                                              ]
                                                                                            : (components[index].name == 'Adapter Box PVC')
                                                                                                ? [
                                                                                                    SpecificInvoiceItem(
                                                                                                      description: 'No. of units',
                                                                                                      units: '${components[index].quantity}',
                                                                                                    ),
                                                                                                  ]
                                                                                                : (components[index].name == 'Aluminium Solar Panel Frame')
                                                                                                    ? [
                                                                                                        SpecificInvoiceItem(
                                                                                                          description: 'No. of units',
                                                                                                          units: '${components[index].quantity}',
                                                                                                        ),
                                                                                                      ]
                                                                                                    : (components[index].name == 'Inverter Manual Isolator')
                                                                                                    ? [
                                                                                                        SpecificInvoiceItem(
                                                                                                          description: 'Rating',
                                                                                                          units: '${components[index].capacity}A',
                                                                                                        ),
                                                                                                      ]
                                                                                                    : [],
          ),
        ),
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => PDFListViewer(
                invoice: invoice,
              )),
        ),
      );
    },
    child: SizedBox(
      height: 40,
      width: size.width,
      child: const Padding(
        padding: EdgeInsets.only(top: 10, left: 10),
        child: Text(
          'Generate components list',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
}
