import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/widgets/snackbar.dart';
import 'package:solartide/features/auth/repository/auth_repository.dart';
import 'package:solartide/features/business/providers/business_providers.dart';
import 'package:solartide/models/user_model.dart';

/// Where the signed-in person is in the app. [SolarTideApp] picks a route map
/// from this, and only rebuilds routing when it changes.
enum RouteStage {
  resolving,
  signedOut,

  /// Signed in, but no business profile yet. The first quote needs one.
  setup,
  signedIn,
}

final authStateChangeProvider = StreamProvider<User?>((ref) {
  if (!ref.watch(firebaseReadyProvider)) return Stream.value(null);
  return ref.watch(authRepositoryProvider).authStateChange;
});

/// The signed-in uid, or null. Every per-user provider keys off this, so
/// signing out tears them all down.
final currentUidProvider = Provider<String?>((ref) => ref.watch(authStateChangeProvider).valueOrNull?.uid);

final _userDocProvider = StreamProvider.family<UserModel?, String>(
  (ref, uid) => ref.watch(authRepositoryProvider).userStream(uid),
);

/// The signed-in user's document, or null when signed out or still loading.
final currentUserProvider = Provider<UserModel?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return null;
  return ref.watch(_userDocProvider(uid)).valueOrNull;
});

final routeStageProvider = Provider<RouteStage>((ref) {
  final auth = ref.watch(authStateChangeProvider);
  if (auth.isLoading) return RouteStage.resolving;
  if (auth.valueOrNull == null) return RouteStage.signedOut;

  final profile = ref.watch(businessProfileProvider);
  if (profile.isLoading && !profile.hasValue) return RouteStage.resolving;
  // An error reading the profile (offline on first launch) lands on setup,
  // where saving will surface the real problem, rather than a blank screen.
  return profile.valueOrNull == null ? RouteStage.setup : RouteStage.signedIn;
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>(AuthController.new);

/// Loading flag plus the auth actions. Errors surface as snackbars, as in the
/// other apps.
class AuthController extends StateNotifier<bool> {
  AuthController(this._ref) : super(false);

  final Ref _ref;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  bool _ready(BuildContext context) {
    if (_ref.read(firebaseReadyProvider)) return true;
    showSnackBar(context, "SolarTide can't reach its server. Run flutterfire configure, then restart.");
    return false;
  }

  Future<void> signIn({required String email, required String password, required BuildContext context}) async {
    if (!_ready(context)) return;
    state = true;
    final result = await _repo.signIn(email: email, password: password);
    state = false;
    result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
    }, (_) {});
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (!_ready(context)) return;
    state = true;
    final result = await _repo.signUp(name: name, email: email, password: password);
    state = false;
    result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
    }, (_) {});
  }

  Future<void> sendPasswordReset({required String email, required BuildContext context}) async {
    if (!email.contains('@')) {
      showSnackBar(context, 'Enter your email first, then tap Forgot password.');
      return;
    }
    if (!_ready(context)) return;
    final result = await _repo.sendPasswordReset(email);
    if (!context.mounted) return;
    result.fold(
      (f) => showSnackBar(context, f.message),
      (_) => showSnackBar(context, 'Check your email for a reset link.'),
    );
  }

  Future<void> signOut() => _repo.signOut();

  /// True when the account is gone; the route map then switches to sign-in
  /// by itself.
  Future<bool> deleteAccount({required String password, required BuildContext context}) async {
    state = true;
    final result = await _repo.deleteAccount(password: password);
    state = false;
    return result.fold((f) {
      if (context.mounted) showSnackBar(context, f.message);
      return false;
    }, (_) => true);
  }
}
