import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/providers/stream_helpers.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/quotes/repository/quote_repository.dart';
import 'package:solartide/models/quote_model.dart';

/// Every live quote, newest first. Shared by the Quotes tab, the dashboard
/// and client detail, so it isn't auto-disposed.
final quotesProvider = StreamProvider<List<QuoteModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return firebaseStream(ref, () => ref.watch(quoteRepositoryProvider).quotesStream(uid), const []);
});

/// One quote, live. Its own stream rather than a lookup in [quotesProvider]
/// so a deep link to a quote works before the list has loaded.
final quoteProvider = StreamProvider.autoDispose.family<QuoteModel?, String>((ref, id) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return firebaseStream(ref, () => ref.watch(quoteRepositoryProvider).quoteStream(uid, id), null);
});

/// Quotes tab filter; null shows every status.
final quoteStatusFilterProvider = StateProvider.autoDispose<QuoteStatus?>((ref) => null);
final quoteSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredQuotesProvider = Provider.autoDispose<AsyncValue<List<QuoteModel>>>((ref) {
  final status = ref.watch(quoteStatusFilterProvider);
  final query = ref.watch(quoteSearchProvider).trim().toLowerCase();
  return ref.watch(quotesProvider).whenData((quotes) => quotes
      .where((q) => status == null || q.status == status)
      .where((q) =>
          query.isEmpty || q.client.name.toLowerCase().contains(query) || q.number.toLowerCase().contains(query))
      .toList());
});

final clientQuotesProvider = Provider.autoDispose.family<List<QuoteModel>, String>((ref, clientId) =>
    (ref.watch(quotesProvider).valueOrNull ?? const []).where((q) => q.client.id == clientId).toList());
