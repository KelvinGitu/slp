/// Firestore collection and document names. Everything a user owns sits under
/// `users/{uid}` so the security rules reduce to one ownership check.
abstract final class FirebaseConstants {
  static const users = 'users';
  static const business = 'business';
  static const businessProfileDoc = 'profile';
  static const catalogue = 'catalogue';
  static const clients = 'clients';
  static const quotes = 'quotes';

  /// Storage folder for business logos: `logos/{uid}.png`.
  static const logosFolder = 'logos';
}
