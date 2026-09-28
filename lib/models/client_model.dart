import 'package:solartide/core/utils/firestore_json.dart';
import 'package:solartide/models/quote_model.dart';

/// `users/{uid}/clients/{id}`. Someone the installer quotes for.
class ClientModel {
  const ClientModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.phone,
    this.email,
    this.location,
    this.notes,
  });

  final String id;
  final String name;

  /// As typed; see `whatsAppNumber` in `launch.dart` for the wa.me form.
  final String? phone;
  final String? email;

  /// Town or estate, "Kitengela" or "Milimani, Nakuru".
  final String? location;
  final String? notes;
  final DateTime createdAt;

  ClientSnapshot toSnapshot() => ClientSnapshot(id: id, name: name, phone: phone, email: email, location: location);

  factory ClientModel.fromMap(String id, Map<String, dynamic> map) => ClientModel(
        id: id,
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        location: map['location'] as String?,
        notes: map['notes'] as String?,
        createdAt: dateFrom(map['createdAt']) ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        // Lower-cased copy for prefix search; Firestore can't search
        // case-insensitively.
        'nameLower': name.toLowerCase(),
        'phone': phone,
        'email': email,
        'location': location,
        'notes': notes,
        'createdAt': timestampFrom(createdAt),
      };

  ClientModel copyWith({String? name, String? phone, String? email, String? location, String? notes}) => ClientModel(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
