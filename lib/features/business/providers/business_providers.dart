import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/providers/stream_helpers.dart';
import 'package:solartide/features/auth/controller/auth_controller.dart';
import 'package:solartide/features/business/repository/business_repository.dart';
import 'package:solartide/models/business_profile.dart';

/// The signed-in installer's business profile; null until setup is done.
/// Watched by the route stage, so it lives for the whole session.
final businessProfileProvider = StreamProvider<BusinessProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return firebaseStream(ref, () => ref.watch(businessRepositoryProvider).profileStream(uid), null);
});
