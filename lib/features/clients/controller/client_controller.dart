import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/clients/repository/client_repository.dart';
import 'package:solartide/models/client_model.dart';

final clientControllerProvider = StateNotifierProvider<ClientController, bool>(ClientController.new);

class ClientController extends StateNotifier<bool> {
  ClientController(this._ref) : super(false);

  final Ref _ref;

  ClientRepository get _repo => _ref.read(clientRepositoryProvider);

  /// Saves a new or edited client. [id] is null for a new one. Returns the
  /// saved client so the new-quote flow can carry straight on with it.
  Future<ClientModel?> save({
    String? id,
    required String name,
    String? phone,
    String? email,
    String? location,
    String? notes,
    DateTime? createdAt,
    required BuildContext context,
  }) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return null;
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final client = ClientModel(
      id: id ?? _repo.newId(uid),
      name: name.trim(),
      phone: clean(phone),
      email: clean(email),
      location: clean(location),
      notes: clean(notes),
      createdAt: createdAt ?? DateTime.now(),
    );
    state = true;
    final result = await _repo.save(uid, client);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return null;
    }, (c) => c);
  }

  Future<bool> delete(ClientModel client, BuildContext context) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return false;
    state = true;
    final result = await _repo.delete(uid, client.id);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return false;
    }, (_) {
      if (context.mounted) showSnackBar(context, '${client.name} deleted. Their quotes are kept.');
      return true;
    });
  }
}
