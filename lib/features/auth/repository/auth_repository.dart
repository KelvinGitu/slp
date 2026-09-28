import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:solartide/core/constants/firebase_constants.dart';
import 'package:solartide/core/error/failure.dart';
import 'package:solartide/core/error/type_defs.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/utils/log.dart';
import 'package:solartide/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(firestore: ref.read(firestoreProvider), auth: ref.read(authProvider)),
);

/// Email and password accounts. Installers sign themselves up; everything
/// they create lives under `users/{uid}`.
class AuthRepository {
  AuthRepository({required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection(FirebaseConstants.users);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  /// The user's document, or null when it doesn't exist. Emits the absence
  /// rather than filtering it out, so a missing document never leaves a
  /// screen loading forever.
  Stream<UserModel?> userStream(String uid) =>
      _users.doc(uid).snapshots().map((doc) => doc.exists ? UserModel.fromMap(doc.id, doc.data()!) : null);

  FutureVoid signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return right(null);
    } on FirebaseAuthException catch (e, st) {
      logError('AuthRepository.signIn', 'code=${e.code} message=${e.message}', st);
      return left(Failure(_messageFor(e, fallback: "Couldn't sign you in. Try again.")));
    } catch (e, st) {
      logError('AuthRepository.signIn', e, st);
      return left(Failure("Couldn't sign you in. Try again."));
    }
  }

  /// Creates the account and its `users/{uid}` document. If the document
  /// write fails the account still exists; [ensureUserDoc] repairs it on the
  /// setup screen.
  FutureVoid signUp({required String name, required String email, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      await _users
          .doc(user.uid)
          .set(UserModel(uid: user.uid, name: name.trim(), email: email.trim(), createdAt: DateTime.now()).toMap());
      return right(null);
    } on FirebaseAuthException catch (e, st) {
      logError('AuthRepository.signUp', 'code=${e.code} message=${e.message}', st);
      return left(Failure(_messageFor(e, fallback: "Couldn't create your account. Try again.")));
    } catch (e, st) {
      logError('AuthRepository.signUp', e, st);
      return left(Failure("Couldn't create your account. Try again."));
    }
  }

  /// Writes `users/{uid}` if it's missing, from the Auth profile.
  FutureVoid ensureUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return left(Failure('You are signed out. Sign in again.'));
    try {
      final doc = _users.doc(user.uid);
      if (!(await doc.get()).exists) {
        await doc.set(UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        ).toMap());
      }
      return right(null);
    } catch (e, st) {
      logError('AuthRepository.ensureUserDoc', e, st);
      return left(Failure("Couldn't save your account. Check your connection and try again."));
    }
  }

  FutureVoid sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return right(null);
    } on FirebaseAuthException catch (e, st) {
      logError('AuthRepository.sendPasswordReset', 'code=${e.code} message=${e.message}', st);
      return left(Failure(_messageFor(e, fallback: "Couldn't send the reset email. Try again.")));
    } catch (e, st) {
      logError('AuthRepository.sendPasswordReset', e, st);
      return left(Failure("Couldn't send the reset email. Try again."));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Deletes everything the user owns, then the account. Firestore doesn't
  /// delete subcollections with their parent, so each is cleared first.
  ///
  /// Firebase refuses to delete an account that signed in long ago; the
  /// password re-confirms it.
  FutureVoid deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return left(Failure('You are signed out. Sign in again.'));
    try {
      await user.reauthenticateWithCredential(EmailAuthProvider.credential(email: user.email!, password: password));
      final root = _users.doc(user.uid);
      for (final name in [
        FirebaseConstants.quotes,
        FirebaseConstants.clients,
        FirebaseConstants.catalogue,
        FirebaseConstants.business,
      ]) {
        await _deleteCollection(root.collection(name));
      }
      await root.delete();
      await user.delete();
      return right(null);
    } on FirebaseAuthException catch (e, st) {
      logError('AuthRepository.deleteAccount', 'code=${e.code} message=${e.message}', st);
      return left(Failure(_messageFor(e, fallback: "Couldn't delete your account. Try again.")));
    } catch (e, st) {
      logError('AuthRepository.deleteAccount', e, st);
      return left(Failure("Couldn't delete your account. Check your connection and try again."));
    }
  }

  /// Batches stay under Firestore's 500-write limit.
  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> collection) async {
    while (true) {
      final page = await collection.limit(400).get();
      if (page.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static String _messageFor(FirebaseAuthException e, {required String fallback}) => switch (e.code) {
        'invalid-email' => 'That email address looks wrong.',
        'user-disabled' => 'This account is turned off.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Email or password is wrong.',
        'email-already-in-use' => 'An account with that email already exists. Sign in instead.',
        'weak-password' => 'Use a password of at least 8 characters.',
        'too-many-requests' => 'Too many attempts. Wait a minute and try again.',
        'network-request-failed' => "You're offline. Connect and try again.",
        _ => fallback,
      };
}
