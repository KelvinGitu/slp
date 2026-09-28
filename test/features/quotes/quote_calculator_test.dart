import 'package:flutter_test/flutter_test.dart';
import 'package:solartide/core/enums/line_state.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/models/catalogue_item.dart';
import 'package:solartide/models/quote_model.dart';

CatalogueItem item(String id) => defaultCatalogue.firstWhere((i) => i.id == id);

QuoteLine lineFor(String id) => QuoteCalculator.linesFor([item(id)]).single;

QuoteModel quoteWith(List<QuoteLine> lines, {double markup = 0, double vat = 0}) {
  final now = DateTime(2026, 9, 28);
  return QuoteModel(
    id: 'q',
    number: 'ST-2026-0001',
    client: const ClientSnapshot(id: 'c', name: 'Client'),
    status: QuoteStatus.draft,
    lines: lines,
    markupPercent: markup,
    vatPercent: vat,
    totals: QuoteCalculator.totals(lines, markupPercent: markup, vatPercent: vat),
    createdAt: now,
    updatedAt: now,
    validUntil: now,
  );
}

void main() {
  group('default catalogue', () {
    test('has the 46 components of the original app with unique ids', () {
      expect(defaultCatalogue, hasLength(46));
      expect(defaultCatalogue.map((i) => i.id).toSet(), hasLength(46));
    });

    test('every option id is unique within its item', () {
      for (final i in defaultCatalogue) {
        expect(i.options.map((o) => o.id).toSet(), hasLength(i.options.length), reason: i.id);
      }
    });

    test('new quote lines follow category order', () {
      final lines = QuoteCalculator.linesFor(defaultCatalogue);
      expect(lines.first.itemId, CatalogueIds.panels);
      expect(lines.last.itemId, 'miscellaneous');
      expect(lines.every((l) => l.state == LineState.pending), isTrue);
    });

    test('inactive items are left off new quotes', () {
      final catalogue = [item('panels').copyWith(active: false), item('busbar')];
      expect(QuoteCalculator.linesFor(catalogue).map((l) => l.itemId), ['busbar']);
    });
  });

  group('include', () {
    test('fixed item costs its unit price once', () {
      final line = QuoteCalculator.include(item('busbar'), lineFor('busbar'));
      expect(line.state, LineState.included);
      expect(line.total, 6000);
    });

    test('panels: count × unit price', () {
      final line = QuoteCalculator.include(item('panels'), lineFor('panels'), inputs: {'count': 12});
      expect(line.quantity, 12);
      expect(line.total, 120000);
    });

    test('labour: technicians × days × day rate', () {
      final line =
          QuoteCalculator.include(item('labour'), lineFor('labour'), inputs: {'technicians': 4, 'days': 3});
      expect(line.quantity, 12);
      expect(line.total, 30000);
    });

    test('labour with days missing costs nothing', () {
      final line = QuoteCalculator.include(item('labour'), lineFor('labour'), inputs: {'technicians': 4});
      expect(line.total, 0);
    });

    test('core cable: the run counts twice at the chosen cross-section', () {
      final line = QuoteCalculator.include(
        item('core_cable'),
        lineFor('core_cable'),
        inputs: {'inverter_board': 10},
        picks: [(optionId: '6mm', quantity: 0)],
      );
      expect(line.quantity, 20);
      expect(line.total, 1200);
      expect(line.selections.single.label, '6 mm²');
    });

    test('PV cable: 2 × roof + arrestor + 2 × board', () {
      final line = QuoteCalculator.include(
        item('pv_cable'),
        lineFor('pv_cable'),
        inputs: {'roof_inverter': 10, 'arrestor_earth': 5, 'inverter_board': 3},
        picks: [(optionId: '10mm', quantity: 0)],
      );
      expect(line.quantity, 31);
      expect(line.total, 3100);
    });

    test('trunking without options uses the unit price', () {
      final line = QuoteCalculator.include(item('pvc_trunking'), lineFor('pvc_trunking'), inputs: {'length': 6});
      expect(line.total, 270);
    });

    test('batteries: chosen capacity × number of batteries', () {
      final line = QuoteCalculator.include(
        item('batteries'),
        lineFor('batteries'),
        picks: [(optionId: '200ah', quantity: 4)],
      );
      expect(line.quantity, 4);
      expect(line.total, 8000);
    });

    test('choice without a quantity question costs one of the option', () {
      final line = QuoteCalculator.include(
        item('inverter'),
        lineFor('inverter'),
        picks: [(optionId: '3000w', quantity: 7)],
      );
      expect(line.quantity, 1);
      expect(line.total, 90000);
    });

    test('choice with an unknown option costs nothing', () {
      final line =
          QuoteCalculator.include(item('inverter'), lineFor('inverter'), picks: [(optionId: 'gone', quantity: 1)]);
      expect(line.total, 0);
      expect(line.selections, isEmpty);
    });

    test('multi: each option × its quantity, zero quantities dropped', () {
      final line = QuoteCalculator.include(
        item('earthing'),
        lineFor('earthing'),
        picks: [(optionId: 'rod', quantity: 2), (optionId: 'cable_16mm', quantity: 15), (optionId: 'x', quantity: 3)],
      );
      expect(line.selections, hasLength(2));
      expect(line.total, 2 * 500 + 15 * 40);
    });

    test('custom: typed amount and description', () {
      final line = QuoteCalculator.include(
        item('miscellaneous'),
        lineFor('miscellaneous'),
        amount: 4500,
        description: '  Scaffolding hire ',
      );
      expect(line.total, 4500);
      expect(line.description, 'Scaffolding hire');
    });

    test('negative input counts as zero', () {
      final line = QuoteCalculator.include(item('panels'), lineFor('panels'), inputs: {'count': -3});
      expect(line.total, 0);
    });

    test('not required clears previous answers', () {
      final added = QuoteCalculator.include(item('panels'), lineFor('panels'), inputs: {'count': 3});
      final line = QuoteCalculator.notRequired(added);
      expect(line.state, LineState.notRequired);
      expect(line.total, 0);
      expect(line.inputs, isEmpty);
    });
  });

  group('linked quantities', () {
    test('MC4 connectors follow panels × 4; frames follow panels × 1', () {
      final panels = QuoteCalculator.include(item('panels'), lineFor('panels'), inputs: {'count': 6});
      final quote = quoteWith([panels, lineFor('mc4_connectors'), lineFor('panel_frame')]);
      expect(QuoteCalculator.linkedQuantity(item('mc4_connectors'), quote), 24);
      expect(QuoteCalculator.linkedQuantity(item('panel_frame'), quote), 6);
    });

    test('no suggestion until panels are added', () {
      final quote = quoteWith([lineFor('panels'), lineFor('mc4_connectors')]);
      expect(QuoteCalculator.linkedQuantity(item('mc4_connectors'), quote), isNull);
    });
  });

  group('totals', () {
    test('only included lines count; markup on cost, VAT on cost + markup', () {
      final lines = [
        QuoteCalculator.include(item('panels'), lineFor('panels'), inputs: {'count': 10}),
        QuoteCalculator.include(item('busbar'), lineFor('busbar')),
        QuoteCalculator.notRequired(lineFor('din_rail')),
        lineFor('pvc_glue'),
      ];
      final t = QuoteCalculator.totals(lines, markupPercent: 10, vatPercent: 16);
      expect(t.cost, 106000);
      expect(t.markup, 10600);
      expect(t.vat, 18656);
      expect(t.total, 135256);
    });

    test('withLine replaces the line and recomputes totals', () {
      final quote = quoteWith([lineFor('panels'), lineFor('busbar')], vat: 16);
      final updated = QuoteCalculator.withLine(quote, QuoteCalculator.include(item('busbar'), lineFor('busbar')));
      expect(updated.lineFor('busbar')!.state, LineState.included);
      expect(updated.totals.total, 6960);
    });

    test('withRates recomputes with the new markup', () {
      final quote = quoteWith([QuoteCalculator.include(item('busbar'), lineFor('busbar'))]);
      expect(QuoteCalculator.withRates(quote, markupPercent: 50).totals.subtotal, 9000);
    });

    test('selling totals add up exactly to the subtotal', () {
      final lines = [
        QuoteCalculator.include(item('pvc_glue'), lineFor('pvc_glue')),
        QuoteCalculator.include(item('scotch_tape'), lineFor('scotch_tape')),
        QuoteCalculator.include(item('heat_shrink'), lineFor('heat_shrink')),
      ];
      final t = QuoteCalculator.totals(lines, markupPercent: 12.5, vatPercent: 16);
      final selling = QuoteCalculator.sellingTotals(lines, t);
      expect(selling.reduce((a, b) => a + b), t.subtotal);
    });
  });

  group('serialization', () {
    test('a priced quote survives toMap/fromMap', () {
      final lines = [
        QuoteCalculator.include(item('batteries'), lineFor('batteries'), picks: [(optionId: '100ah', quantity: 2)]),
        QuoteCalculator.include(item('labour'), lineFor('labour'), inputs: {'technicians': 2, 'days': 1}),
      ];
      final quote = quoteWith(lines, markup: 5, vat: 16);
      final back = QuoteModel.fromMap('q', quote.toMap());
      expect(back.totals, quote.totals);
      expect(back.lines.first.selections.single.optionId, '100ah');
      expect(back.lines.last.inputs, {'technicians': 2, 'days': 1});
    });

    test('fromMap tolerates missing fields and doubles for ints', () {
      final q = QuoteModel.fromMap('q', {
        'lines': [
          {'itemId': 'panels', 'total': 1000.0, 'inputs': {'count': 2.0}},
          'not a map',
        ],
      });
      expect(q.lines, hasLength(1));
      expect(q.lines.single.total, 1000);
      expect(q.lines.single.inputs['count'], 2);
      expect(q.status, QuoteStatus.draft);
    });

    test('catalogue items survive toMap/fromMap', () {
      for (final i in defaultCatalogue) {
        final back = CatalogueItem.fromMap(i.id, i.toMap());
        expect(back.toMap(), i.toMap(), reason: i.id);
      }
    });
  });
}
