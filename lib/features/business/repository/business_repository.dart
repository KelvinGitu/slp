import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:solartide/core/constants/firebase_constants.dart';
import 'package:solartide/core/error/failure.dart';
import 'package:solartide/core/error/type_defs.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/utils/log.dart';
import 'package:solartide/models/business_profile.dart';
import 'package:solartide/models/catalogue_item.dart';

final businessRepositoryProvider = Provider(
  (ref) => BusinessRepository(firestore: ref.read(firestoreProvider), storage: ref.read(storageProvider)),
);

class BusinessRepository {
  BusinessRepository({required FirebaseFirestore firestore, required FirebaseStorage storage})
      : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _profile(String uid) => _firestore
      .collection(FirebaseConstants.users)
      .doc(uid)
      .collection(FirebaseConstants.business)
      .doc(FirebaseConstants.businessProfileDoc);

  /// Null until setup is done.
  Stream<BusinessProfile?> profileStream(String uid) =>
      _profile(uid).snapshots().map((doc) => doc.exists ? BusinessProfile.fromMap(doc.data()!) : null);

  /// First-run setup: the profile and the starting catalogue in one batch, so
  /// an account can never end up with a profile but an empty catalogue.
  FutureVoid completeSetup(String uid, BusinessProfile profile, List<CatalogueItem> catalogue) async {
    try {
      final batch = _firestore.batch();
      batch.set(_profile(uid), {...profile.toMap(), 'nextQuoteNumber': 1, 'quoteNumberYear': DateTime.now().year});
      final items = _firestore.collection(FirebaseConstants.users).doc(uid).collection(FirebaseConstants.catalogue);
      for (final item in catalogue) {
        batch.set(items.doc(item.id), item.toMap());
      }
      await batch.commit();
      return right(null);
    } catch (e, st) {
      logError('BusinessRepository.completeSetup', e, st);
      return left(Failure("Couldn't save your business details. Check your connection and try again."));
    }
  }

  /// Merges so the quote counter, which the form doesn't carry, is kept.
  FutureVoid saveProfile(String uid, BusinessProfile profile) async {
    try {
      await _profile(uid).set(profile.toMap(), SetOptions(merge: true));
      return right(null);
    } catch (e, st) {
      logError('BusinessRepository.saveProfile', e, st);
      return left(Failure("Couldn't save your business details. Check your connection and try again."));
    }
  }

  /// Uploads the logo and returns its download URL. One file per account,
  /// replaced on each upload.
  FutureEither<String> uploadLogo(String uid, Uint8List bytes, {required String contentType}) async {
    try {
      final ref = _storage.ref('${FirebaseConstants.logosFolder}/$uid');
      await ref.putData(bytes, SettableMetadata(contentType: contentType));
      return right(await ref.getDownloadURL());
    } catch (e, st) {
      logError('BusinessRepository.uploadLogo', e, st);
      return left(Failure("Couldn't upload the logo. Try a smaller image."));
    }
  }
}
