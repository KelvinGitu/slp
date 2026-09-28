import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local time, ticking once a minute. Drives the greeting and the header
/// date; nothing in SolarTide needs seconds. Auto-disposed so it only ticks
/// while a screen is showing it.
final nowProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});
