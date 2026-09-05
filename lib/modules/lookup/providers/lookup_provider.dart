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
    await ref.watch(lookupDbServiceProvider).ensureSeeded().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('[LookupProvider] Database seeding warning: $e');
  }
});

final lookupModeProvider = StateProvider<LookupMode>((ref) => LookupMode.byZip);
final lookupQueryProvider = StateProvider<String>((ref) => '');

final lookupResultsProvider = FutureProvider<List<ZipEntry>>((ref) async {
  await ref.watch(lookupSeededProvider.future);
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final service = ref.watch(lookupDbServiceProvider);
  switch (ref.watch(lookupModeProvider)) {
    case LookupMode.byZip:
      return service.searchByZip(query);
    case LookupMode.byCity:
      return service.searchByCity(query);
    case LookupMode.byAreaCode:
      return service.searchByAreaCode(query);
  }
});

final lookupSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  await ref.watch(lookupSeededProvider.future);
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final mode = ref.watch(lookupModeProvider);
  return ref.watch(lookupDbServiceProvider).suggest(query, mode: mode);
});

final areaCodeCityResultsProvider = FutureProvider<List<AreaCodeRecord>>((ref) async {
  if (ref.watch(lookupModeProvider) != LookupMode.byAreaCode) return [];
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  return ref.watch(areaCodeGeoServiceProvider).resultsForAreaCode(query);
});

final areaCodeCitySuggestionsProvider = FutureProvider<List<String>>((ref) async {
  if (ref.watch(lookupModeProvider) != LookupMode.byAreaCode) return [];
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  return ref.watch(areaCodeGeoServiceProvider).suggestionsForAreaCode(query);
});
