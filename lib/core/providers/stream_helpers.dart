import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/core/providers/firebase_providers.dart';

/// Returns [build]'s stream when Firebase is up, else a single [fallback].
///
/// Keeps every screen renderable in widget tests and in unconfigured debug
/// builds, where touching `FirebaseFirestore.instance` would throw.
Stream<T> firebaseStream<T>(Ref ref, Stream<T> Function() build, T fallback) {
  if (!ref.watch(firebaseReadyProvider)) return Stream.value(fallback);
  return build();
}
