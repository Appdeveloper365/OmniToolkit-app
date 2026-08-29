/// FILE: tool/generate_area_codes.dart
///
/// Regenerates assets/data/area_codes.json — a dataset unified & keyed by
/// telephone area code (NPA): areaCode, city, state, county, timezone, lat, lng.
///
/// DATA SOURCE NOTES (read before re-running):
/// - city/state/lat/lng come from the real, verified, public-domain
///   ravisorg/Area-Code-Geolocation-Database repo (MIT-style "free for any
///   use, commercial or not" license), vendored locally at
///   assets/data/vendor/ravisorg_us_area_code_{cities,geo}.csv so this script
///   runs fully offline. City/state are the first-listed city per area code
///   from us-area-code-cities.csv; lat/lng are the pre-averaged per-area-code
///   values from us-area-code-geo.csv.
/// - The user-requested "EvvyTools" area-codes dataset
///   (https://evvytools.com/lists/us-area-codes/) DOES genuinely exist (358
///   rows: area_code/state/city/timezone) and was confirmed live, but its
///   CSV/JSON export is generated client-side by a "choose columns, then
///   download" UI with no plain GET/API endpoint discoverable from this
///   environment (no browser-automation tooling available here), so it could
///   not be mechanically fetched. Rather than fabricate that data, timezone
///   is instead derived deterministically from state via
///   [_stateTimezones] below — a reasonable, clearly-documented
///   approximation, not real per-area-code IANA data from EvvyTools.
/// - The other requested source, "GitHub: us-area-code-geolocation-database"
///   (an "ocolunga" fork), could not be independently verified to exist from
///   this environment, so it was not used; ravisorg's original (which the
///   fork request describes identically: same filename, same fields) stood
///   in as the verified source for city/state/lat/lng.
/// - county is intentionally left null (per task instructions: "derive later
///   if possible") — neither source provides it.
///
/// Run with: dart run tool/generate_area_codes.dart
library;

import 'dart:convert';
import 'dart:io';

const Map<String, String> _stateAbbreviations = {
  'Alabama': 'AL', 'Alaska': 'AK', 'Arizona': 'AZ', 'Arkansas': 'AR',
  'California': 'CA', 'Colorado': 'CO', 'Connecticut': 'CT', 'Delaware': 'DE',
  'District of Columbia': 'DC', 'Florida': 'FL', 'Georgia': 'GA', 'Hawaii': 'HI',
  'Idaho': 'ID', 'Illinois': 'IL', 'Indiana': 'IN', 'Iowa': 'IA', 'Kansas': 'KS',
  'Kentucky': 'KY', 'Louisiana': 'LA', 'Maine': 'ME', 'Maryland': 'MD',
  'Massachusetts': 'MA', 'Michigan': 'MI', 'Minnesota': 'MN', 'Mississippi': 'MS',
  'Missouri': 'MO', 'Montana': 'MT', 'Nebraska': 'NE', 'Nevada': 'NV',
  'New Hampshire': 'NH', 'New Jersey': 'NJ', 'New Mexico': 'NM', 'New York': 'NY',
  'North Carolina': 'NC', 'North Dakota': 'ND', 'Ohio': 'OH', 'Oklahoma': 'OK',
  'Oregon': 'OR', 'Pennsylvania': 'PA', 'Rhode Island': 'RI',
  'South Carolina': 'SC', 'South Dakota': 'SD', 'Tennessee': 'TN', 'Texas': 'TX',
  'Utah': 'UT', 'Vermont': 'VT', 'Virginia': 'VA', 'Washington': 'WA',
  'West Virginia': 'WV', 'Wisconsin': 'WI', 'Wyoming': 'WY',
};

/// Primary IANA timezone per state (deterministic approximation used because
/// the EvvyTools per-area-code timezone export could not be fetched — see
/// file header). A handful of states span two zones; the more populous /
/// eastern-leaning zone is used as the default.
const Map<String, String> _stateTimezones = {
  'AL': 'America/Chicago', 'AK': 'America/Anchorage', 'AZ': 'America/Phoenix',
  'AR': 'America/Chicago', 'CA': 'America/Los_Angeles', 'CO': 'America/Denver',
  'CT': 'America/New_York', 'DE': 'America/New_York', 'DC': 'America/New_York',
  'FL': 'America/New_York', 'GA': 'America/New_York', 'HI': 'Pacific/Honolulu',
  'ID': 'America/Denver', 'IL': 'America/Chicago', 'IN': 'America/Indiana/Indianapolis',
  'IA': 'America/Chicago', 'KS': 'America/Chicago', 'KY': 'America/New_York',
  'LA': 'America/Chicago', 'ME': 'America/New_York', 'MD': 'America/New_York',
  'MA': 'America/New_York', 'MI': 'America/Detroit', 'MN': 'America/Chicago',
  'MS': 'America/Chicago', 'MO': 'America/Chicago', 'MT': 'America/Denver',
  'NE': 'America/Chicago', 'NV': 'America/Los_Angeles', 'NH': 'America/New_York',
  'NJ': 'America/New_York', 'NM': 'America/Denver', 'NY': 'America/New_York',
  'NC': 'America/New_York', 'ND': 'America/Chicago', 'OH': 'America/New_York',
  'OK': 'America/Chicago', 'OR': 'America/Los_Angeles', 'PA': 'America/New_York',
  'RI': 'America/New_York', 'SC': 'America/New_York', 'SD': 'America/Chicago',
  'TN': 'America/Chicago', 'TX': 'America/Chicago', 'UT': 'America/Denver',
  'VT': 'America/New_York', 'VA': 'America/New_York', 'WA': 'America/Los_Angeles',
  'WV': 'America/New_York', 'WI': 'America/Chicago', 'WY': 'America/Denver',
};

List<String> _parseCsvLine(String line) {
  final result = <String>[];
  final current = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString());
      current.clear();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString());
  return result;
}

void main() {
  final citiesFile = File('assets/data/vendor/ravisorg_us_area_code_cities.csv');
  final geoFile = File('assets/data/vendor/ravisorg_us_area_code_geo.csv');
  final outFile = File('assets/data/area_codes.json');

  // Primary city/state: first-listed city per area code in the cities file.
  final primaryCity = <String, ({String city, String state})>{};
  for (final rawLine in citiesFile.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final parts = _parseCsvLine(line);
    if (parts.length < 3) continue;
    final areaCode = parts[0].trim();
    final city = parts[1].trim();
    final stateName = parts[2].trim();
    if (areaCode.isEmpty || city.isEmpty || stateName.isEmpty) continue;
    primaryCity.putIfAbsent(
      areaCode,
      () => (city: city, state: _stateAbbreviations[stateName] ?? stateName),
    );
  }

  // Averaged lat/lng per area code.
  final geo = <String, ({double lat, double lng})>{};
  for (final rawLine in geoFile.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final parts = _parseCsvLine(line);
    if (parts.length < 3) continue;
    final areaCode = parts[0].trim();
    final lat = double.tryParse(parts[1].trim());
    final lng = double.tryParse(parts[2].trim());
    if (areaCode.isEmpty || lat == null || lng == null) continue;
    geo[areaCode] = (lat: lat, lng: lng);
  }

  // Merge: prefer primary city/state; validate; skip incomplete rows.
  final result = <Map<String, dynamic>>[];
  final sortedCodes = primaryCity.keys.toList()..sort();
  for (final areaCode in sortedCodes) {
    final cityState = primaryCity[areaCode]!;
    if (areaCode.isEmpty || cityState.city.isEmpty || cityState.state.isEmpty) continue;
    final coords = geo[areaCode];
    result.add({
      'areaCode': areaCode,
      'city': cityState.city,
      'state': cityState.state,
      'county': null,
      'timezone': _stateTimezones[cityState.state],
      'lat': coords?.lat,
      'lng': coords?.lng,
    });
  }

  outFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(result)}\n');
  stdout.writeln('Wrote ${result.length} area-code records to ${outFile.path}');
}

