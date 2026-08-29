/// FILE: tool/generate_area_codes.dart
///
/// Regenerates assets/data/area_codes.json — a dataset unified & keyed by
/// telephone area code (NPA), aggregated from the app's own bundled,
/// already-vetted local dataset (assets/data/lookup_data.json).
///
/// NOTE ON DATA SOURCE: the app previously referenced a remote "OpenDataSoft
/// nanpa-area-codes" dataset (see LookupService.areaCodeApiUrl) for updates.
/// That dataset id no longer exists on OpenDataSoft (returns
/// `{"error":"Unknown dataset: nanpa-area-codes"}` as of this writing), and
/// no other verified, reachable, commercially-permissible NPA->city/county
/// geolocation dataset was substituted — this script intentionally avoids
/// fabricating a replacement URL. Instead it derives the unified dataset
/// from data already vetted and bundled in this repo, so regeneration is
/// fully offline/local. `assets/data/curated_us_zips.csv` has no area-code
/// column, so coverage is limited to the area codes present in
/// lookup_data.json (major metros) — not full NANPA coverage.
///
/// Run with: dart run tool/generate_area_codes.dart
library;

import 'dart:convert';
import 'dart:io';

class _Agg {
  final Map<String, int> cities = {};
  final Map<String, int> states = {};
  final Map<String, int> counties = {};
  final Map<String, int> timezones = {};
  double latSum = 0;
  double lngSum = 0;
  int count = 0;

  void add({
    required String city,
    required String state,
    String? county,
    String? timezone,
    double? lat,
    double? lng,
  }) {
    cities.update(city, (v) => v + 1, ifAbsent: () => 1);
    states.update(state, (v) => v + 1, ifAbsent: () => 1);
    if (county != null && county.isNotEmpty) {
      counties.update(county, (v) => v + 1, ifAbsent: () => 1);
    }
    if (timezone != null && timezone.isNotEmpty) {
      timezones.update(timezone, (v) => v + 1, ifAbsent: () => 1);
    }
    if (lat != null && lng != null) {
      latSum += lat;
      lngSum += lng;
    }
    count++;
  }

  static String? _mode(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  Map<String, dynamic> toJson(String areaCode) => {
        'areaCode': areaCode,
        'city': _mode(cities),
        'state': _mode(states),
        'county': _mode(counties),
        'timezone': _mode(timezones),
        'lat': count > 0 ? double.parse((latSum / count).toStringAsFixed(4)) : null,
        'lng': count > 0 ? double.parse((lngSum / count).toStringAsFixed(4)) : null,
      };
}

void main() {
  final sourceFile = File('assets/data/lookup_data.json');
  final outFile = File('assets/data/area_codes.json');

  final decoded = jsonDecode(sourceFile.readAsStringSync()) as List<dynamic>;
  final aggregates = <String, _Agg>{};

  for (final raw in decoded) {
    final row = raw as Map<String, dynamic>;
    final city = (row['city'] as String?)?.trim() ?? '';
    final state = (row['state'] as String?)?.trim() ?? '';
    final county = (row['county'] as String?)?.trim();
    final timezone = (row['timezone'] as String?)?.trim();
    final lat = (row['lat'] as num?)?.toDouble();
    final lng = (row['lng'] as num?)?.toDouble();

    // Validate: skip rows without a usable city/state before crediting any area code.
    if (city.isEmpty || state.isEmpty) continue;

    final areaCodeField = row['area_code'];
    final codes = areaCodeField is List
        ? areaCodeField.map((e) => e.toString().trim()).where((e) => e.isNotEmpty)
        : <String>[];

    for (final code in codes) {
      aggregates.putIfAbsent(code, () => _Agg()).add(
            city: city,
            state: state,
            county: county,
            timezone: timezone,
            lat: lat,
            lng: lng,
          );
    }
  }

  // Validate: no empty areaCode, no duplicate keys (Map already guarantees uniqueness).
  final sortedCodes = aggregates.keys.where((c) => c.isNotEmpty).toList()..sort();
  final result = sortedCodes.map((code) => aggregates[code]!.toJson(code)).toList();

  outFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(result)}\n');

  stdout.writeln('Wrote ${result.length} area-code records to ${outFile.path}');
}
