import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/features/catalogue/repository/catalogue_repository.dart';
import 'package:solartide/models/catalogue_item.dart';

final catalogueControllerProvider = StateNotifierProvider<CatalogueController, bool>(CatalogueController.new);

class CatalogueController extends StateNotifier<bool> {
  CatalogueController(this._ref) : super(false);

  final Ref _ref;

  CatalogueRepository get _repo => _ref.read(catalogueRepositoryProvider);

  Future<bool> save(CatalogueItem item, BuildContext context) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return false;
    state = true;
    final result = await _repo.saveItem(uid, item);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return false;
    }, (_) {
      if (context.mounted) showSnackBar(context, '${item.name} saved.');
      return true;
    });
  }

  Future<void> resetToDefaults(BuildContext context) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return;
    state = true;
    final result = await _repo.resetTo(uid, defaultCatalogue);
    state = false;
    if (!context.mounted) return;
    result.fold(
      (f) => showSnackBar(context, f.message),
      (_) => showSnackBar(context, 'Prices are back to the defaults.'),
    );
  }
}
