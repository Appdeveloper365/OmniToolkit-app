/// FILE: tool/verify_area_codes.dart
///
/// Validates assets/data/area_codes.json integrity:
/// - is a JSON array
/// - every record has a non-empty areaCode/city/state
/// - areaCode is 3 digits
/// - no duplicate areaCode keys
/// - lat/lng (when present) are within plausible US bounds
///
/// Run with: dart run tool/verify_area_codes.dart
/// Exits with a non-zero code if validation fails.
library;

import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/data/area_codes.json');
  if (!file.existsSync()) {
    stderr.writeln('FAIL: ${file.path} does not exist. Run tool/generate_area_codes.dart first.');
    exit(1);
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! List) {
    stderr.writeln('FAIL: ${file.path} must contain a JSON array.');
    exit(1);
  }

  final errors = <String>[];
  final seenCodes = <String>{};
  final areaCodePattern = RegExp(r'^\d{3}$');

  for (var i = 0; i < decoded.length; i++) {
    final row = decoded[i];
    if (row is! Map) {
      errors.add('Row $i is not an object.');
      continue;
    }
    final areaCode = row['areaCode'];
    final city = row['city'];
    final state = row['state'];
    final lat = row['lat'];
    final lng = row['lng'];

    if (areaCode is! String || areaCode.isEmpty) {
      errors.add('Row $i has an empty/missing areaCode.');
    } else {
      if (!areaCodePattern.hasMatch(areaCode)) {
        errors.add('Row $i areaCode "$areaCode" is not 3 digits.');
      }
      if (!seenCodes.add(areaCode)) {
        errors.add('Duplicate areaCode "$areaCode" at row $i.');
      }
    }
    if (city is! String || city.isEmpty) {
      errors.add('Row $i (areaCode=$areaCode) has an empty/missing city.');
    }
    if (state is! String || state.isEmpty) {
      errors.add('Row $i (areaCode=$areaCode) has an empty/missing state.');
    }
    if (lat != null && (lat is! num || lat < 15 || lat > 72)) {
      errors.add('Row $i (areaCode=$areaCode) has an implausible lat: $lat.');
    }
    if (lng != null && (lng is! num || lng < -170 || lng > -65)) {
      errors.add('Row $i (areaCode=$areaCode) has an implausible lng: $lng.');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('FAIL: ${errors.length} issue(s) found in ${file.path}:');
    for (final e in errors) {
      stderr.writeln('  - $e');
    }
    exit(1);
  }

  stdout.writeln('OK: ${decoded.length} area-code records validated in ${file.path}.');
}
