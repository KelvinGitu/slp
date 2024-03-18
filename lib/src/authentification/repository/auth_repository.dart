import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_project/core/firestore_provider.dart';
import 'package:solar_project/core/snackbar.dart';
import 'package:solar_project/src/authentification/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.watch(authProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(
      {required FirebaseAuth auth, required FirebaseFirestore firestore})
      : _auth = auth,
        _firestore = firestore;

  Future signUpWithEmail(
      {required String name,
      required String email,
      required String password,
      required BuildContext context,
      required String uid}) async {
    try {
      // await _auth.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
        );
        await _users.doc(userModel.email).set(userModel.toMap());
      } else {
        userModel = await getUserData(email).first;
      }
      return userModel;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) showSnackBar(context, e.message!);
    }
  }

  Future loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      //     email: email, password: password);
      UserModel userModel = await getUserData(email).first;

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) showSnackBar(context, e.message!);
    }
  }

  Stream<UserModel> getUserData(String email) {
    return _users.doc(email).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  Stream<User?> get authStateChange => _auth.authStateChanges();

  CollectionReference get _users => _firestore.collection('users');
}
