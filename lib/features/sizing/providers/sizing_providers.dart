import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solartide/features/sizing/data/kenya_counties.dart';
import 'package:solartide/features/sizing/repository/irradiance_repository.dart';

/// Sun hours for a place, or null when the service can't be reached (the
/// screen then falls back and says so). Never throws.
final sunHoursProvider = FutureProvider.autoDispose.family<SunHours?, SiteLocation>((ref, place) async {
  final result = await ref.watch(irradianceRepositoryProvider).sunHours(place.lat, place.lng);
  return result.fold((_) => null, (s) => s);
});
