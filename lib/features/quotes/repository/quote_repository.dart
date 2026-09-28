import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:solartide/core/constants/app_constants.dart';
import 'package:solartide/core/constants/firebase_constants.dart';
import 'package:solartide/core/enums/quote_status.dart';
import 'package:solartide/core/error/failure.dart';
import 'package:solartide/core/error/type_defs.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/utils/firestore_json.dart';
import 'package:solartide/core/utils/format_utils.dart';
import 'package:solartide/core/utils/log.dart';
import 'package:solartide/models/quote_model.dart';

final quoteRepositoryProvider = Provider((ref) => QuoteRepository(firestore: ref.read(firestoreProvider)));

class QuoteRepository {
  QuoteRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _firestore.collection(FirebaseConstants.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _quotes(String uid) => _user(uid).collection(FirebaseConstants.quotes);

  /// Newest first, deleted ones left out. Filtered here rather than in the
  /// query so no composite index is needed; an installer's quote count is
  /// small.
  Stream<List<QuoteModel>> quotesStream(String uid) =>
      _quotes(uid).orderBy('updatedAt', descending: true).snapshots().map((snap) => snap.docs
          .map((d) => QuoteModel.fromMap(d.id, d.data()))
          .where((q) => !q.deleted)
          .toList());

  Stream<QuoteModel?> quoteStream(String uid, String id) => _quotes(uid)
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? QuoteModel.fromMap(doc.id, doc.data()!) : null);

  /// Saves [draft] under a new id with the next quote number. The number is
  /// taken from the business profile in the same transaction, so two quotes
  /// started at once (phone and browser) never share a number. The sequence
  /// restarts at 1 each January.
  FutureEither<QuoteModel> create(String uid, QuoteModel draft) async {
    try {
      final profileRef = _user(uid).collection(FirebaseConstants.business).doc(FirebaseConstants.businessProfileDoc);
      final quoteRef = _quotes(uid).doc();
      final saved = await _firestore.runTransaction((tx) async {
        final profile = (await tx.get(profileRef)).data() ?? const <String, dynamic>{};
        final year = draft.createdAt.year;
        final sameYear = intFrom(profile['quoteNumberYear']) == year;
        final sequence = sameYear ? (intFrom(profile['nextQuoteNumber']) ?? 1) : 1;
        final prefix = profile['quotePrefix'] as String? ?? AppConstants.defaultQuotePrefix;

        final quote = draft.copyWith(id: quoteRef.id, number: formatQuoteNumber(prefix, year, sequence));
        tx.set(quoteRef, quote.toMap());
        tx.set(profileRef, {'nextQuoteNumber': sequence + 1, 'quoteNumberYear': year}, SetOptions(merge: true));
        return quote;
      });
      return right(saved);
    } catch (e, st) {
      logError('QuoteRepository.create', e, st);
      return left(Failure("Couldn't start the quote. Check your connection and try again."));
    }
  }

  /// Writes the whole quote: lines and totals always change together.
  FutureVoid save(String uid, QuoteModel quote) async {
    try {
      await _quotes(uid).doc(quote.id).set(quote.toMap());
      return right(null);
    } catch (e, st) {
      logError('QuoteRepository.save', e, st);
      return left(Failure("Couldn't save the quote. Check your connection and try again."));
    }
  }

  FutureVoid setStatus(String uid, String id, QuoteStatus status) =>
      _update(uid, id, {'status': status.name}, "Couldn't change the status. Try again.");

  /// Soft delete, as in the original app, so a mistaken delete can be undone.
  FutureVoid setDeleted(String uid, String id, {required bool deleted}) =>
      _update(uid, id, {'deleted': deleted}, "Couldn't delete the quote. Try again.");

  FutureVoid _update(String uid, String id, Map<String, dynamic> data, String message) async {
    try {
      await _quotes(uid).doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
      return right(null);
    } catch (e, st) {
      logError('QuoteRepository._update', e, st);
      return left(Failure(message));
    }
  }
}
