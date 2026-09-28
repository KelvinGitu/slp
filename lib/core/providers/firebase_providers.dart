import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether `Firebase.initializeApp` succeeded. False in widget tests and on a
/// machine without Firebase config.
final firebaseReadyProvider = Provider<bool>((ref) => Firebase.apps.isNotEmpty);

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);
final storageProvider = Provider((ref) => FirebaseStorage.instance);

/// `--dart-define=USE_EMULATORS=true` runs against `firebase emulators:start`.
abstract final class EmulatorConfig {
  static const enabled = bool.fromEnvironment('USE_EMULATORS');

  /// The Android emulator reaches the host machine at 10.0.2.2.
  static String get host => !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';

  static Future<void> connect() async {
    final h = host;
    await FirebaseAuth.instance.useAuthEmulator(h, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(h, 8080);
    await FirebaseStorage.instance.useStorageEmulator(h, 9199);
  }
}
