import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/authentification/models/user_model.dart';
import 'package:solar_project/src/authentification/repository/auth_repository.dart';
import 'package:uuid/uuid.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authStateChangeProvider = StreamProvider((ref) {
  return ref.watch(authControllerProvider).authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  return ref.watch(authControllerProvider).getUserData(uid);
});

final authControllerProvider = Provider(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

class AuthController {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref;

  void emailSignUp(
      String name, String email, String password, BuildContext context) async {
    var uid = const Uuid().v1();

    final result = await _authRepository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      context: context,
      uid: uid,
    );

    _ref.read(userProvider.notifier).update((state) => result);
  }

  void emailLogin(String email, String password, BuildContext context) async {
    final result = await _authRepository.loginWithEmail(
        email: email, password: password, context: context);

    _ref.read(userProvider.notifier).update((state) => result);
  }

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
}
