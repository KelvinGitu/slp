import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/providers/stream_helpers.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/clients/repository/client_repository.dart';
import 'package:solartide/models/client_model.dart';

final clientsProvider = StreamProvider<List<ClientModel>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return firebaseStream(ref, () => ref.watch(clientRepositoryProvider).clientsStream(uid), const []);
});

/// One client from the list above, so the detail screen needs no extra read.
final clientProvider = Provider.family<ClientModel?, String>((ref, id) {
  for (final c in ref.watch(clientsProvider).valueOrNull ?? const <ClientModel>[]) {
    if (c.id == id) return c;
  }
  return null;
});

/// Search box text on the Clients tab.
final clientSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredClientsProvider = Provider.autoDispose<AsyncValue<List<ClientModel>>>((ref) {
  final query = ref.watch(clientSearchProvider).trim().toLowerCase();
  return ref.watch(clientsProvider).whenData((clients) {
    if (query.isEmpty) return clients;
    return clients
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            (c.phone?.contains(query) ?? false) ||
            (c.location?.toLowerCase().contains(query) ?? false))
        .toList();
  });
});
