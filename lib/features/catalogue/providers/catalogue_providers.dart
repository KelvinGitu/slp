import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/providers/stream_helpers.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/features/catalogue/repository/catalogue_repository.dart';
import 'package:solartide/features/quotes/logic/quote_calculator.dart';
import 'package:solartide/models/catalogue_item.dart';

/// The installer's catalogue, sorted the way quotes list it. Not
/// auto-disposed: the quote editor, the catalogue screen and sizing all read
/// it, and re-subscribing on every screen change would flicker.
///
/// Falls back to the defaults when Firebase isn't up (widget tests).
final catalogueProvider = StreamProvider<List<CatalogueItem>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return firebaseStream(
    ref,
    () => ref.watch(catalogueRepositoryProvider).catalogueStream(uid).map((items) => items..sort(QuoteCalculator.compareItems)),
    [...defaultCatalogue]..sort(QuoteCalculator.compareItems),
  );
});

/// Items by id, for the quote editor to find the item behind a line.
final catalogueByIdProvider = Provider<Map<String, CatalogueItem>>((ref) {
  final items = ref.watch(catalogueProvider).valueOrNull ?? const [];
  return {for (final i in items) i.id: i};
});
