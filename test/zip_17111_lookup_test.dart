/// FILE: test/zip_17111_lookup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/db/app_database.dart';
import 'package:omnitoolkit/modules/lookup/models/lookup_models.dart';
import 'package:omnitoolkit/modules/lookup/models/zip_entry.dart';
import 'package:omnitoolkit/modules/lookup/services/lookup_db_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late LookupDbService dbService;

  setUp(() async {
    dbService = LookupDbService();
    final db = await AppDatabase.instance.database;
    await db.delete('lookup');
    await db.insert('lookup', const ZipEntry(
      zip: '17111',
      city: 'Harrisburg',
      state: 'PA',
      county: 'Dauphin',
      areaCodes: ['717', '223'],
      region: ['Harrisburg, PA'],
      timezone: 'America/New_York',
      lat: 40.26895,
      lng: -76.78491,
    ).toMap());
  });

  group('ZIP 17111 Lookup Tests', () {
    test('searchByZip returns Harrisburg, PA for 17111', () async {
      final results = await dbService.searchByZip('17111');
      expect(results, isNotEmpty);
      expect(results.first.zip, equals('17111'));
      expect(results.first.city, equals('Harrisburg'));
      expect(results.first.state, equals('PA'));
      expect(results.first.county, equals('Dauphin'));
    });

    test('suggest returns 17111 autocomplete suggestion', () async {
      final suggestions = await dbService.suggest('1711', mode: LookupMode.byZip);
      expect(suggestions, contains('17111 (Harrisburg, PA)'));
    });

    test('searchByCity finds 17111 when searching Harrisburg', () async {
      final results = await dbService.searchByCity('Harrisburg');
      expect(results, isNotEmpty);
      expect(results.any((e) => e.zip == '17111'), isTrue);
    });
  });
}
