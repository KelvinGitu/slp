import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/src/authentification/models/user_model.dart';
import 'package:solar_project/src/authentification/repository/auth_repository.dart';
import 'package:uuid/uuid.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authStateChangeProvider = StreamProvider((ref) {
  return ref.watch(authControllerProvider.notifier).authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String email) {
  return ref.watch(authControllerProvider.notifier).getUserData(email);
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  void emailSignUp(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    state = true;
    var uid = const Uuid().v1();

    final result = await _authRepository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      context: context,
      uid: uid,
    );
    state = false;

    _ref.read(userProvider.notifier).update((state) => result);
  }

  void emailLogin(
    String email,
    String password,
    BuildContext context,
  ) async {
    state = true;
    final result = await _authRepository.loginWithEmail(
        email: email, password: password, context: context);
    state = false;

    _ref.read(userProvider.notifier).update((state) => result);
  }

  void signUserOut() async {
    await _authRepository.signUserOut();
  }

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  User? get getUser => _authRepository.getUser;

  Stream<UserModel> getUserData(String email) {
    return _authRepository.getUserData(email);
  }
}
