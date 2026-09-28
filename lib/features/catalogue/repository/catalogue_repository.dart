import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:solartide/core/constants/firebase_constants.dart';
import 'package:solartide/core/error/failure.dart';
import 'package:solartide/core/error/type_defs.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/utils/log.dart';
import 'package:solartide/models/catalogue_item.dart';

final catalogueRepositoryProvider = Provider((ref) => CatalogueRepository(firestore: ref.read(firestoreProvider)));

class CatalogueRepository {
  CatalogueRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection(FirebaseConstants.users).doc(uid).collection(FirebaseConstants.catalogue);

  Stream<List<CatalogueItem>> catalogueStream(String uid) => _items(uid)
      .snapshots()
      .map((snap) => snap.docs.map((d) => CatalogueItem.fromMap(d.id, d.data())).toList());

  FutureVoid saveItem(String uid, CatalogueItem item) async {
    try {
      await _items(uid).doc(item.id).set(item.toMap());
      return right(null);
    } catch (e, st) {
      logError('CatalogueRepository.saveItem', e, st);
      return left(Failure("Couldn't save the price. Check your connection and try again."));
    }
  }

  /// Puts back every default item, replacing edited prices. Items the
  /// installer never had (or deleted) come back too.
  FutureVoid resetTo(String uid, List<CatalogueItem> items) async {
    try {
      final batch = _firestore.batch();
      for (final item in items) {
        batch.set(_items(uid).doc(item.id), item.toMap());
      }
      await batch.commit();
      return right(null);
    } catch (e, st) {
      logError('CatalogueRepository.resetTo', e, st);
      return left(Failure("Couldn't reset the catalogue. Check your connection and try again."));
    }
  }
}
