import 'package:solartide/core/enums/component_kind.dart';
import 'package:solartide/core/enums/sizing_role.dart';
import 'package:solartide/models/catalogue_item.dart';

/// Category names, in the order a quote lists them.
abstract final class CatalogueCategory {
  static const generation = 'Panels and mounting';
  static const inverter = 'Inverter and protection';
  static const storage = 'Batteries';
  static const ac = 'AC distribution';
  static const cabling = 'Cabling and earthing';
  static const materials = 'Installation materials';
  static const services = 'Transport and labour';

  static const all = [generation, inverter, storage, ac, cabling, materials, services];

  /// Sort key for a category; unknown ones go last.
  static int rank(String category) {
    final i = all.indexOf(category);
    return i < 0 ? all.length : i;
  }
}

/// Stable ids the app refers to directly.
abstract final class CatalogueIds {
  static const panels = 'panels';
  static const inverter = 'inverter';
  static const batteries = 'batteries';
}

/// The catalogue every new account starts with: the 46 components of the
/// original app, with the prices it charged (its `prices.dart` and Firestore
/// master catalogue as of 2024) and its installer notes. Installers change
/// prices in Settings > Price catalogue.
///
/// `order` is category × 100 + the component's number in the original app,
/// so lines group by category and keep their familiar order inside it.
final List<CatalogueItem> defaultCatalogue = [
  // Panels and mounting
  const CatalogueItem(
    id: CatalogueIds.panels,
    name: 'Solar panels',
    category: CatalogueCategory.generation,
    order: 1,
    kind: ComponentKind.quantity,
    unit: 'panel',
    unitPrice: 10000,
    inputs: [LineInput(id: 'count', label: 'Number of panels')],
    notes: ['Check the usable roof area.', "Size from the client's power needs, or use the sizing calculator."],
    rating: 450,
    sizingRole: SizingRole.panel,
  ),
  const CatalogueItem(
    id: 'mc4_connectors',
    name: 'MC4 connectors',
    category: CatalogueCategory.generation,
    order: 4,
    kind: ComponentKind.quantity,
    unitPrice: 120,
    inputs: [LineInput(id: 'count', label: 'Number of connectors')],
    notes: ['Number of strings × 4 for panels connected in series.'],
    linkedItemId: CatalogueIds.panels,
    linkFactor: 4,
  ),
  const CatalogueItem(
    id: 'pv_combiner_box',
    name: 'PV combiner box',
    category: CatalogueCategory.generation,
    order: 8,
    kind: ComponentKind.fixed,
    unitPrice: 9600,
  ),
  const CatalogueItem(
    id: 'combiner_box_9_way',
    name: '9-way combiner box',
    category: CatalogueCategory.generation,
    order: 9,
    kind: ComponentKind.fixed,
    unitPrice: 3300,
  ),
  const CatalogueItem(
    id: 'panel_frame',
    name: 'Aluminium solar panel frame',
    category: CatalogueCategory.generation,
    order: 36,
    kind: ComponentKind.quantity,
    unit: 'frame',
    unitPrice: 1200,
    inputs: [LineInput(id: 'count', label: 'Number of frames')],
    notes: ['One per panel.'],
    linkedItemId: CatalogueIds.panels,
  ),

  // Inverter and protection
  const CatalogueItem(
    id: CatalogueIds.inverter,
    name: 'Inverter',
    category: CatalogueCategory.inverter,
    order: 102,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '1000w', label: '1000 W', price: 60000, rating: 1000),
      CatalogueOption(id: '2000w', label: '2000 W', price: 80000, rating: 2000),
      CatalogueOption(id: '3000w', label: '3000 W', price: 90000, rating: 3000),
      CatalogueOption(id: '4000w', label: '4000 W', price: 120000, rating: 4000),
      CatalogueOption(id: '5000w', label: '5000 W', price: 145000, rating: 5000),
    ],
    notes: ['Depends on the output of the panels in series.'],
    sizingRole: SizingRole.inverter,
  ),
  const CatalogueItem(
    id: 'inverter_isolator',
    name: 'Inverter manual isolator',
    category: CatalogueCategory.inverter,
    order: 106,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '20a', label: '20 A', price: 200, rating: 20),
      CatalogueOption(id: '40a', label: '40 A', price: 400, rating: 40),
      CatalogueOption(id: '60a', label: '60 A', price: 600, rating: 60),
      CatalogueOption(id: '80a', label: '80 A', price: 800, rating: 80),
      CatalogueOption(id: '100a', label: '100 A', price: 1000, rating: 100),
    ],
    notes: ['Depends on the kVA rating of the panels. Pick the first rating at or above it.'],
  ),
  const CatalogueItem(
    id: 'dc_breaker',
    name: 'DC breaker',
    category: CatalogueCategory.inverter,
    order: 127,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '32a_1000v', label: 'DC breaker 32 A 1000 V (Sun Tree)', price: 1200),
      CatalogueOption(id: '32a_500v', label: 'DC breaker 32 A 500 V (Sun Tree)', price: 600),
    ],
    notes: [
      'Panels connected in series need the 1000 V breaker.',
      "Also depends on the inverter's maximum voltage.",
    ],
  ),
  const CatalogueItem(
    id: 'dc_breaker_enclosure',
    name: 'DC breaker enclosure',
    category: CatalogueCategory.inverter,
    order: 128,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '12_way', label: 'DC breaker enclosure 12-way IP65 (Sun Tree)', price: 800),
      CatalogueOption(id: '24_way', label: 'DC breaker enclosure 24-way IP65 (Sun Tree)', price: 1000),
    ],
    notes: ['Many solar circuits need the 24-way enclosure.'],
  ),
  const CatalogueItem(
    id: 'surge_protector',
    name: 'PV surge protector',
    category: CatalogueCategory.inverter,
    order: 129,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '40ka_1000v', label: 'PV surge protector 40 kA 1000 V', price: 1000),
      CatalogueOption(id: '40ka_500v', label: 'PV surge protector 40 kA 500 V', price: 500),
    ],
    notes: [
      'Panels connected in series need the 1000 V protector.',
      "Also depends on the inverter's maximum voltage (Voc).",
    ],
  ),
  const CatalogueItem(
    id: 'line_fuse',
    name: 'PV line fuse',
    category: CatalogueCategory.inverter,
    order: 130,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '20a', label: 'PV line fuse 20 A (Sun Tree)', price: 120),
      CatalogueOption(id: '30a', label: 'PV line fuse 30 A (Sun Tree)', price: 150),
    ],
    notes: ['High-current circuits need the 30 A fuse.', 'Also depends on the cable size.'],
  ),
  const CatalogueItem(
    id: 'lightning_arrestor',
    name: 'Lightning arrestor kit',
    category: CatalogueCategory.inverter,
    order: 134,
    kind: ComponentKind.fixed,
    unitPrice: 2600,
  ),

  // Batteries
  const CatalogueItem(
    id: CatalogueIds.batteries,
    name: 'Batteries',
    category: CatalogueCategory.storage,
    order: 203,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '100ah', label: '100 Ah', price: 1000, rating: 100),
      CatalogueOption(id: '200ah', label: '200 Ah', price: 2000, rating: 200),
      CatalogueOption(id: '300ah', label: '300 Ah', price: 3000, rating: 300),
      CatalogueOption(id: '400ah', label: '400 Ah', price: 4000, rating: 400),
      CatalogueOption(id: '500ah', label: '500 Ah', price: 5000, rating: 500),
    ],
    askQuantity: true,
    quantityLabel: 'Number of batteries',
    notes: ['Capacity should at least cover average nightly use.'],
    nominalVoltage: 12,
    sizingRole: SizingRole.battery,
  ),
  const CatalogueItem(
    id: 'battery_cable',
    name: 'Battery cable',
    category: CatalogueCategory.storage,
    order: 212,
    kind: ComponentKind.multi,
    options: [
      CatalogueOption(
          id: '4mm', label: '4 mm²', price: 20, unit: 'm', detail: 'For high-voltage LiFePO4 batteries.'),
      CatalogueOption(
          id: '16mm', label: '16 mm²', price: 40, unit: 'm', detail: 'Connects the arrestor to the earth rod.'),
      CatalogueOption(
          id: '25mm',
          label: '25 mm²',
          price: 45,
          unit: 'm',
          detail: 'Charge controllers only. Charge controller to battery bank.'),
      CatalogueOption(
          id: '35mm', label: '35 mm²', price: 50, unit: 'm', detail: 'LiFePO4 batteries. Battery to inverter.'),
      CatalogueOption(
          id: '50mm',
          label: '50 mm²',
          price: 60,
          unit: 'm',
          detail: 'Lead-acid batteries and inverters up to 10 kVA. Battery to inverter.'),
      CatalogueOption(
          id: '70mm',
          label: '70 mm²',
          price: 70,
          unit: 'm',
          detail: 'Lead-acid batteries and inverters over 10 kVA. Battery to inverter.'),
    ],
  ),
  const CatalogueItem(
    id: 'cable_lugs',
    name: 'Cable lugs',
    category: CatalogueCategory.storage,
    order: 213,
    kind: ComponentKind.multi,
    options: [
      CatalogueOption(id: 'battery', label: 'Battery cable lugs', price: 15),
      CatalogueOption(id: 'charge_control', label: 'Charge controller lugs', price: 15),
      CatalogueOption(id: 'earth', label: 'Earth cable lugs', price: 15),
    ],
    notes: [
      'Battery lugs: 2 × batteries + 2, plus 2 per inverter, 2 per charge controller and 4 per battery breaker.',
    ],
  ),
  const CatalogueItem(
    id: 'battery_breaker',
    name: 'DC battery breaker',
    category: CatalogueCategory.storage,
    order: 231,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: '150a', label: '150 A DC battery breaker (Sun Tree)', price: 150),
      CatalogueOption(id: '200a', label: '200 A DC battery breaker (Sun Tree)', price: 300),
    ],
    notes: ["Client's preference.", 'A battery fuse is a cheaper alternative, but not as good.'],
  ),
  const CatalogueItem(
    id: 'battery_fuse',
    name: 'Battery fuse',
    category: CatalogueCategory.storage,
    order: 232,
    kind: ComponentKind.fixed,
    unitPrice: 180,
    notes: ['Alternative to the DC battery breaker, on request.'],
  ),
  const CatalogueItem(
    id: 'busbar',
    name: 'Busbar (complete)',
    category: CatalogueCategory.storage,
    order: 243,
    kind: ComponentKind.fixed,
    unitPrice: 6000,
    notes: ['For large battery banks with more than 3 battery strings.'],
  ),

  // AC distribution
  const CatalogueItem(
    id: 'changeover_switch',
    name: 'Automatic changeover switch',
    category: CatalogueCategory.ac,
    order: 305,
    kind: ComponentKind.fixed,
    unitPrice: 660,
  ),
  const CatalogueItem(
    id: 'mccb_3_pole',
    name: 'Triple-pole MCCB 100 A',
    category: CatalogueCategory.ac,
    order: 317,
    kind: ComponentKind.fixed,
    unitPrice: 10000,
    notes: ['Needed if the home has a three-phase connection.'],
  ),
  const CatalogueItem(
    id: 'mcb_2_pole',
    name: 'Double-pole MCB 63 A',
    category: CatalogueCategory.ac,
    order: 318,
    kind: ComponentKind.fixed,
    unitPrice: 16000,
    notes: ['Needed if the home has a two-phase connection.'],
  ),
  const CatalogueItem(
    id: 'mccb_4_pole',
    name: 'Four-pole MCCB 63 A',
    category: CatalogueCategory.ac,
    order: 319,
    kind: ComponentKind.fixed,
    unitPrice: 4000,
    notes: ['Needed if the home has a four-phase connection.'],
  ),
  const CatalogueItem(
    id: 'ac_breaker_enclosure',
    name: 'AC breaker enclosure 12-way IP65',
    category: CatalogueCategory.ac,
    order: 320,
    kind: ComponentKind.fixed,
    unitPrice: 10000,
  ),
  const CatalogueItem(
    id: 'contactor_single_pole',
    name: '100 A AC single-pole contactor',
    category: CatalogueCategory.ac,
    order: 321,
    kind: ComponentKind.fixed,
    unitPrice: 16000,
    notes: ['Needed when the home is connected to the grid.'],
  ),
  const CatalogueItem(
    id: 'contactor_triple_pole',
    name: '100 A AC triple-pole contactor',
    category: CatalogueCategory.ac,
    order: 322,
    kind: ComponentKind.fixed,
    unitPrice: 16000,
    notes: ['Needed when the home is connected to the grid.'],
  ),
  const CatalogueItem(
    id: 'adapter_box_enclosure',
    name: 'Adapter box enclosure',
    category: CatalogueCategory.ac,
    order: 323,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: 'steel', label: 'Steel adapter box enclosure', price: 800, detail: '2 ft × 2 ft'),
      CatalogueOption(id: 'plastic', label: 'Plastic adapter box enclosure', price: 1000),
    ],
    notes: ["Client's preference.", 'Add a DIN rail with it.'],
  ),
  const CatalogueItem(
    id: 'din_rail',
    name: 'DIN rail',
    category: CatalogueCategory.ac,
    order: 324,
    kind: ComponentKind.fixed,
    unitPrice: 635,
    notes: ['Goes with the adapter box enclosure.'],
  ),
  const CatalogueItem(
    id: 'single_core_cable',
    name: '1.5 mm² single-core cable',
    category: CatalogueCategory.ac,
    order: 325,
    kind: ComponentKind.choice,
    unit: 'm',
    options: [
      CatalogueOption(id: 'rybn', label: 'R+Y+B+N (three-phase)', price: 40, unit: 'm'),
      CatalogueOption(id: 'ryb', label: 'R+Y+B', price: 30, unit: 'm'),
    ],
    askQuantity: true,
    quantityLabel: 'Metres',
    defaultQuantity: 4,
    notes: ['4 m when there is a contactor, otherwise not required.'],
  ),
  const CatalogueItem(
    id: 'voltage_guard',
    name: 'Voltage guard',
    category: CatalogueCategory.ac,
    order: 326,
    kind: ComponentKind.choice,
    options: [
      CatalogueOption(id: 'avs50_tbb', label: 'AVS 50 TBB single-phase', price: 1200),
      CatalogueOption(id: 'avs30_3p', label: 'AVS 30 three-phase', price: 1600),
    ],
    notes: ['Needed whenever the home is connected to the grid.'],
  ),

  // Cabling and earthing
  const CatalogueItem(
    id: 'core_cable',
    name: 'Core cable',
    category: CatalogueCategory.cabling,
    order: 407,
    kind: ComponentKind.length,
    unit: 'm',
    options: [
      CatalogueOption(id: '6mm', label: '6 mm²', price: 60, unit: 'm'),
      CatalogueOption(id: '10mm', label: '10 mm²', price: 100, unit: 'm'),
    ],
    inputs: [LineInput(id: 'inverter_board', label: 'Inverter to distribution board (m)', factor: 2)],
    notes: ['The run is counted twice, out and back.', 'The cross-section depends on the inverter power.'],
  ),
  const CatalogueItem(
    id: 'pv_cable',
    name: 'PV cable',
    category: CatalogueCategory.cabling,
    order: 410,
    kind: ComponentKind.length,
    unit: 'm',
    options: [
      CatalogueOption(id: '6mm', label: '6 mm²', price: 40, unit: 'm'),
      CatalogueOption(id: '10mm', label: '10 mm²', price: 100, unit: 'm'),
    ],
    inputs: [
      LineInput(id: 'roof_inverter', label: 'Roof to inverter (m)', factor: 2),
      LineInput(id: 'arrestor_earth', label: 'Arrestor to earth rod (m)'),
      LineInput(id: 'inverter_board', label: 'Inverter to distribution board (m)', factor: 2),
    ],
    notes: [
      'Roof to inverter and inverter to board are counted twice, out and back.',
      "The cross-section depends on the inverter power and the client's energy needs.",
    ],
  ),
  const CatalogueItem(
    id: 'earthing',
    name: 'Earth rod and cable',
    category: CatalogueCategory.cabling,
    order: 411,
    kind: ComponentKind.multi,
    options: [
      CatalogueOption(id: 'rod', label: 'Earth rod', price: 500),
      CatalogueOption(id: 'cable_16mm', label: '16 mm² earthing cable', price: 40, unit: 'm'),
    ],
  ),
  const CatalogueItem(
    id: 'piping',
    name: 'Piping',
    category: CatalogueCategory.cabling,
    order: 415,
    kind: ComponentKind.multi,
    options: [
      CatalogueOption(id: 'conduit_pipe', label: '32 mm H-gauge conduit pipes', price: 280),
      CatalogueOption(id: 'conduit_bend', label: '32 mm H-gauge conduit bends', price: 100),
      CatalogueOption(id: 'conduit_coupler', label: '32 mm H-gauge conduit couplers', price: 30),
      CatalogueOption(id: 'flex_conduit', label: '25/32 mm flex conduit', price: 80),
      CatalogueOption(id: 'saddle', label: '32 mm metal saddles', price: 40),
    ],
  ),
  const CatalogueItem(
    id: 'pvc_trunking',
    name: 'PVC trunking',
    category: CatalogueCategory.cabling,
    order: 416,
    kind: ComponentKind.length,
    unit: 'm',
    unitPrice: 45,
    inputs: [LineInput(id: 'length', label: 'Length of trunking (m)', defaultValue: 6)],
    notes: ['A standard house needs about 6 m.'],
  ),
  const CatalogueItem(
    id: 'adapter_box_pvc',
    name: 'PVC adapter box 100 × 100 × 70',
    category: CatalogueCategory.cabling,
    order: 433,
    kind: ComponentKind.quantity,
    unitPrice: 25,
    inputs: [LineInput(id: 'count', label: 'Number of pieces')],
  ),
  const CatalogueItem(
    id: 'communication',
    name: 'Communication components',
    category: CatalogueCategory.cabling,
    order: 435,
    kind: ComponentKind.multi,
    options: [
      CatalogueOption(id: 'cat6', label: 'Cat 6 communication cable', price: 30, unit: 'm'),
      CatalogueOption(id: 'rj45', label: 'RJ45 connectors', price: 15),
    ],
    notes: ["Client's preference."],
  ),

  // Installation materials
  const CatalogueItem(
    id: 'cable_ties',
    name: 'Cable ties 300 × 8 mm',
    category: CatalogueCategory.materials,
    order: 514,
    kind: ComponentKind.fixed,
    unitPrice: 1000,
  ),
  const CatalogueItem(
    id: 'pvc_glue',
    name: 'PVC glue',
    category: CatalogueCategory.materials,
    order: 537,
    kind: ComponentKind.fixed,
    unitPrice: 170,
  ),
  const CatalogueItem(
    id: 'scotch_tape',
    name: 'Waterproof scotch tape',
    category: CatalogueCategory.materials,
    order: 538,
    kind: ComponentKind.fixed,
    unitPrice: 90,
  ),
  const CatalogueItem(
    id: 'insulation_tape',
    name: 'Insulation tape',
    category: CatalogueCategory.materials,
    order: 539,
    kind: ComponentKind.quantity,
    unit: 'roll',
    unitPrice: 40,
    inputs: [LineInput(id: 'count', label: 'Number of rolls', defaultValue: 3)],
  ),
  const CatalogueItem(
    id: 'heat_shrink',
    name: 'Heat shrink tube 50 mm (red and black)',
    category: CatalogueCategory.materials,
    order: 540,
    kind: ComponentKind.fixed,
    unitPrice: 80,
  ),
  const CatalogueItem(
    id: 'wall_mounting',
    name: 'Wall mounting materials',
    category: CatalogueCategory.materials,
    order: 541,
    kind: ComponentKind.fixed,
    unit: 'set',
    unitPrice: 3500,
  ),
  const CatalogueItem(
    id: 'marine_board',
    name: 'Marine board 4 ft × 8 ft',
    category: CatalogueCategory.materials,
    order: 542,
    kind: ComponentKind.fixed,
    unitPrice: 1020,
    notes: ['For mounting the inverter on a rough wall, and with lead-acid batteries.'],
  ),

  // Transport and labour
  const CatalogueItem(
    id: 'transport',
    name: 'Transport',
    category: CatalogueCategory.services,
    order: 644,
    kind: ComponentKind.quantity,
    unit: 'minute',
    unitPrice: 40,
    inputs: [LineInput(id: 'minutes', label: 'Time on the road (minutes)')],
    notes: ["The van's time on the road, from Google Maps."],
  ),
  const CatalogueItem(
    id: 'labour',
    name: 'Labour',
    category: CatalogueCategory.services,
    order: 645,
    kind: ComponentKind.quantity,
    unit: 'technician-day',
    unitPrice: 2500,
    inputs: [
      LineInput(id: 'technicians', label: 'Number of technicians', defaultValue: 4),
      LineInput(id: 'days', label: 'Number of days'),
    ],
    notes: ['4 technicians is the usual crew.'],
  ),
  const CatalogueItem(
    id: 'miscellaneous',
    name: 'Miscellaneous',
    category: CatalogueCategory.services,
    order: 646,
    kind: ComponentKind.custom,
  ),
];
