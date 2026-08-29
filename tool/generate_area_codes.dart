/// FILE: tool/generate_area_codes.dart
///
/// Regenerates assets/data/area_codes.json from the user-provided
/// us-area-code-cities.csv (columns: areaCode, city, state, country, lat,
/// lng — vendored at assets/data/vendor/ravisorg_us_area_code_cities.csv,
/// confirmed byte-identical to the file supplied directly by the user).
///
/// Unlike the previous revision of this script, this one does NOT aggregate
/// to one row per area code and does NOT derive/approximate timezone: each
/// row of the CSV becomes one output record (multiple cities can share an
/// area code), state is kept as the full name exactly as given in the CSV,
/// and county/timezone are left null placeholders per the current task spec.
///
/// Run with: dart run tool/generate_area_codes.dart
library;

import 'dart:convert';
import 'dart:io';

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
  final outFile = File('assets/data/area_codes.json');

  final result = <Map<String, dynamic>>[];
  final seen = <String>{};

  for (final rawLine in citiesFile.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final parts = _parseCsvLine(line);
    if (parts.length < 6) continue;

    final areaCode = parts[0].trim();
    final city = parts[1].trim();
    final state = parts[2].trim();
    final country = parts[3].trim();
    final lat = double.tryParse(parts[4].trim());
    final lng = double.tryParse(parts[5].trim());

    // Validate: no empty areaCode/city/state.
    if (areaCode.isEmpty || city.isEmpty || state.isEmpty) continue;

    // Deduplicate exact repeated rows (the source CSV contains some).
    final dedupeKey = '$areaCode|$city|$state';
    if (!seen.add(dedupeKey)) continue;

    result.add({
      'areaCode': areaCode,
      'city': city,
      'state': state,
      'country': country.isEmpty ? null : country,
      'lat': lat,
      'lng': lng,
      'county': null,
      'timezone': null,
    });
  }

  outFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(result)}\n');
  stdout.writeln('Wrote ${result.length} area-code records to ${outFile.path}');
}

