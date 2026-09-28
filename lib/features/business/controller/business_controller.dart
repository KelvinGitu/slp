import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/auth/repository/auth_repository.dart';
import 'package:solartide/features/business/repository/business_repository.dart';
import 'package:solartide/features/catalogue/data/default_catalogue.dart';
import 'package:solartide/models/business_profile.dart';

final businessControllerProvider = StateNotifierProvider<BusinessController, bool>(BusinessController.new);

class BusinessController extends StateNotifier<bool> {
  BusinessController(this._ref) : super(false);

  final Ref _ref;

  BusinessRepository get _repo => _ref.read(businessRepositoryProvider);

  /// First run. On success the route stage flips to signed-in by itself.
  Future<void> completeSetup(BusinessProfile profile, BuildContext context) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return;
    state = true;
    // Repairs a sign-up whose user document write was interrupted.
    await _ref.read(authRepositoryProvider).ensureUserDoc();
    final result = await _repo.completeSetup(uid, profile, defaultCatalogue);
    state = false;
    result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
    }, (_) {});
  }

  Future<bool> save(BusinessProfile profile, BuildContext context) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return false;
    state = true;
    final result = await _repo.saveProfile(uid, profile);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return false;
    }, (_) {
      if (context.mounted) showSnackBar(context, 'Business details saved.');
      return true;
    });
  }

  /// Lets the installer pick a logo and uploads it. Returns the new URL, or
  /// null if they cancelled or it failed.
  Future<String?> pickAndUploadLogo(BuildContext context) async {
    final uid = _ref.read(currentUidProvider);
    if (uid == null) return null;
    // 512 px is plenty for a PDF header and keeps uploads small on mobile data.
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return null;
    state = true;
    final bytes = await file.readAsBytes();
    final result = await _repo.uploadLogo(uid, bytes, contentType: file.mimeType ?? 'image/png');
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return null;
    }, (url) => url);
  }
}
