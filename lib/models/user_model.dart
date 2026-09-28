import 'package:solartide/core/utils/firestore_json.dart';

/// `users/{uid}`. Keyed by uid, not email as the original app did, so a
/// changed email never orphans the account's quotes.
class UserModel {
  const UserModel({required this.uid, required this.name, required this.email, required this.createdAt});

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
        uid: uid,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        createdAt: dateFrom(map['createdAt']) ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {'name': name, 'email': email, 'createdAt': timestampFrom(createdAt)};
}
