import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads a date that may arrive as a Firestore [Timestamp], a [DateTime], epoch
/// millis or an ISO string (tests and the RTDB write the latter two).
DateTime? dateFrom(Object? value) => switch (value) {
      final Timestamp t => t.toDate(),
      final DateTime d => d,
      final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      final String s => DateTime.tryParse(s),
      _ => null,
    };

Timestamp? timestampFrom(DateTime? value) => value == null ? null : Timestamp.fromDate(value);

double? doubleFrom(Object? value) => value is num ? value.toDouble() : null;

/// Whole number from any numeric field; Firestore hands back doubles for
/// values a web client wrote as `1.0`.
int? intFrom(Object? value) => value is num ? value.round() : null;

/// A list of maps, skipping anything malformed rather than throwing the whole
/// document away.
List<Map<String, dynamic>> mapListFrom(Object? value) => value is List
    ? value.whereType<Map<Object?, Object?>>().map((m) => m.cast<String, dynamic>()).toList()
    : const [];

List<String> stringListFrom(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];
