/// FILE: lib/modules/lookup/providers/lookup_provider.dart
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

final lookupServiceInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(lookupServiceProvider);
  await service.ensureInitialized();
});

final lookupSeededProvider = FutureProvider<void>((ref) async {
  await ref.watch(lookupDbServiceProvider).ensureSeeded();
  await ref.watch(lookupServiceInitProvider.future);
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

/// Autocomplete suggestions (ZIP, city/state, area code) for the current query.
final lookupSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  await ref.watch(lookupSeededProvider.future);
  final query = ref.watch(lookupQueryProvider).trim();
  if (query.isEmpty) return [];
  final mode = ref.watch(lookupModeProvider);
  return ref.watch(lookupDbServiceProvider).suggest(query, mode: mode);
});

/// Aggregated city/state/county/timezone summary for an exact area code,
/// sourced from the unified assets/data/area_codes.json dataset. Only
/// populated in [LookupMode.byAreaCode]; null while typing a partial code.
final areaCodeSummaryProvider = FutureProvider<AreaCodeRecord?>((ref) async {
  if (ref.watch(lookupModeProvider) != LookupMode.byAreaCode) return null;
  final query = ref.watch(lookupQueryProvider).trim();
  if (!RegExp(r'^\d{3}$').hasMatch(query)) return null;
  return ref.watch(areaCodeGeoServiceProvider).lookup(query);
});
