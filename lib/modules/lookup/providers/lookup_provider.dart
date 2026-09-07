/// FILE: lib/modules/lookup/providers/lookup_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lookup_models.dart';
import '../models/zip_entry.dart';
import '../services/area_code_geo_service.dart';
import '../services/lookup_db_service.dart';
import '../services/lookup_service.dart';

export '../models/lookup_models.dart' show LookupMode;

final lookupDbServiceProvider = Provider((ref) => LookupDbService());
final lookupServiceProvider = Provider((ref) => LookupService());
final areaCodeGeoServiceProvider = Provider((ref) => AreaCodeGeoService());

final lookupSeededProvider = FutureProvider<void>((ref) async {
  try {
    final dbService = ref.read(lookupDbServiceProvider);
    await dbService.ensureSeeded().timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('[LookupProvider] Database seeding warning/timeout: $e');
  }
});

final lookupModeProvider = StateProvider<LookupMode>((ref) => LookupMode.byZip);
final lookupQueryProvider = StateProvider<String>((ref) => '');

final lookupResultsProvider = FutureProvider<List<ZipEntry>>((ref) async {
  try {
    await ref.watch(lookupSeededProvider.future).timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('[LookupProvider] Seeding wait timeout: $e');
  }
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final service = ref.read(lookupDbServiceProvider);
  try {
    switch (ref.watch(lookupModeProvider)) {
      case LookupMode.byZip:
        return await service.searchByZip(query).timeout(const Duration(seconds: 4));
      case LookupMode.byCity:
        return await service.searchByCity(query).timeout(const Duration(seconds: 4));
      case LookupMode.byAreaCode:
        return await service.searchByAreaCode(query).timeout(const Duration(seconds: 4));
    }
  } catch (e) {
    debugPrint('[LookupProvider] Search query error: $e');
    return [];
  }
});

final lookupSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  try {
    await ref.watch(lookupSeededProvider.future).timeout(const Duration(seconds: 4));
  } catch (_) {}
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final mode = ref.watch(lookupModeProvider);
  try {
    return await ref.read(lookupDbServiceProvider).suggest(query, mode: mode).timeout(const Duration(seconds: 4));
  } catch (_) {
    return [];
  }
});

/// Returns area-code city records for [LookupMode.byAreaCode].
/// Now falls back to querying ZipEntry records if area_codes.json yields no result.
final areaCodeCityResultsProvider = FutureProvider<List<AreaCodeRecord>>((ref) async {
  if (ref.watch(lookupModeProvider) != LookupMode.byAreaCode) return [];
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final geoService = ref.read(areaCodeGeoServiceProvider);
  final dbService = ref.read(lookupDbServiceProvider);

  try {
    final geoResults = await geoService.resultsForAreaCode(query).timeout(const Duration(seconds: 4));
    if (geoResults.isNotEmpty) return geoResults;
  } catch (_) {}

  // Fallback: Query ZipEntry database by ZIP or City if input was a ZIP code / City name on Area Code tab
  try {
    final zipResults = query.replaceAll(RegExp(r'[^\d]'), '').isNotEmpty && query.length >= 5
        ? await dbService.searchByZip(query).timeout(const Duration(seconds: 4))
        : await dbService.searchByCity(query).timeout(const Duration(seconds: 4));

    final areaCodeRecords = <AreaCodeRecord>[];
    for (final z in zipResults) {
      for (final code in z.areaCodes) {
        if (code.isNotEmpty) {
          areaCodeRecords.add(AreaCodeRecord(
            areaCode: code,
            city: z.city,
            state: z.state,
            lat: z.lat,
            lng: z.lng,
          ));
        }
      }
    }
    return areaCodeRecords;
  } catch (_) {
    return [];
  }
});

/// Autocomplete suggestions ("areaCode (city, state)") for [LookupMode.byAreaCode].
final areaCodeCitySuggestionsProvider = FutureProvider<List<String>>((ref) async {
  if (ref.watch(lookupModeProvider) != LookupMode.byAreaCode) return [];
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final geoService = ref.read(areaCodeGeoServiceProvider);
  final dbService = ref.read(lookupDbServiceProvider);

  try {
    final geoSugg = await geoService.suggestionsForAreaCode(query).timeout(const Duration(seconds: 4));
    if (geoSugg.isNotEmpty) return geoSugg;
  } catch (_) {}

  try {
    return await dbService.suggest(query, mode: LookupMode.byAreaCode).timeout(const Duration(seconds: 4));
  } catch (_) {
    return [];
  }
});
