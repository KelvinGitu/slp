import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:solartide/core/constants/firebase_constants.dart';
import 'package:solartide/core/error/failure.dart';
import 'package:solartide/core/error/type_defs.dart';
import 'package:solartide/core/providers/firebase_providers.dart';
import 'package:solartide/core/utils/log.dart';
import 'package:solartide/models/client_model.dart';

final clientRepositoryProvider = Provider((ref) => ClientRepository(firestore: ref.read(firestoreProvider)));

class ClientRepository {
  ClientRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _clients(String uid) =>
      _firestore.collection(FirebaseConstants.users).doc(uid).collection(FirebaseConstants.clients);

  /// A–Z. Installers have tens of clients, not thousands, so the list is
  /// streamed whole and searched on the device.
  Stream<List<ClientModel>> clientsStream(String uid) => _clients(uid)
      .orderBy('nameLower')
      .snapshots()
      .map((snap) => snap.docs.map((d) => ClientModel.fromMap(d.id, d.data())).toList());

  /// A new id for a client that hasn't been saved yet.
  String newId(String uid) => _clients(uid).doc().id;

  FutureEither<ClientModel> save(String uid, ClientModel client) async {
    try {
      await _clients(uid).doc(client.id).set(client.toMap());
      return right(client);
    } catch (e, st) {
      logError('ClientRepository.save', e, st);
      return left(Failure("Couldn't save the client. Check your connection and try again."));
    }
  }

  /// Quotes keep their own copy of the client, so deleting a client never
  /// changes a quote.
  FutureVoid delete(String uid, String clientId) async {
    try {
      await _clients(uid).doc(clientId).delete();
      return right(null);
    } catch (e, st) {
      logError('ClientRepository.delete', e, st);
      return left(Failure("Couldn't delete the client. Check your connection and try again."));
    }
  }
}
