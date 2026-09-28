import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:solartide/core/error/failure.dart';
import 'package:solartide/core/error/type_defs.dart';
import 'package:solartide/core/utils/log.dart';

final irradianceRepositoryProvider = Provider((ref) => IrradianceRepository(http.Client()));

/// Long-term average sun at a location, in peak sun hours (kWh/m²/day on a
/// horizontal surface).
class SunHours {
  const SunHours({required this.annual, required this.lowestMonth});

  final double annual;

  /// The worst month, for installers sizing off-grid systems conservatively.
  final double lowestMonth;
}

/// NASA POWER's climatology API: free, no key, and it allows browser
/// requests, so the web app can call it directly.
/// https://power.larc.nasa.gov/docs/services/api/temporal/climatology/
class IrradianceRepository {
  IrradianceRepository(this._client);

  final http.Client _client;

  /// The averages don't change, so each place is fetched once per session.
  final _cache = <String, SunHours>{};

  static const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

  FutureEither<SunHours> sunHours(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';
    final cached = _cache[key];
    if (cached != null) return right(cached);

    final uri = Uri.https('power.larc.nasa.gov', '/api/temporal/climatology/point', {
      'parameters': 'ALLSKY_SFC_SW_DWN',
      'community': 'RE',
      'latitude': lat.toStringAsFixed(4),
      'longitude': lng.toStringAsFixed(4),
      'format': 'JSON',
    });
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        logError('IrradianceRepository.sunHours', 'HTTP ${res.statusCode}: ${res.body}');
        return left(Failure("Couldn't get sun data for this place."));
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final values = ((json['properties'] as Map<String, dynamic>)['parameter'] as Map<String, dynamic>)['ALLSKY_SFC_SW_DWN']
          as Map<String, dynamic>;
      final monthly = [for (final m in _months) (values[m] as num).toDouble()];
      final result = SunHours(
        annual: (values['ANN'] as num).toDouble(),
        lowestMonth: monthly.reduce((a, b) => a < b ? a : b),
      );
      // NASA uses -999 for missing data.
      if (result.annual <= 0) return left(Failure('No sun data for this place.'));
      _cache[key] = result;
      return right(result);
    } catch (e, st) {
      logError('IrradianceRepository.sunHours', e, st);
      return left(Failure("You're offline, or the sun data service didn't answer."));
    }
  }
}
