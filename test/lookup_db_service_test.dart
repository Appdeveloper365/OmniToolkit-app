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
      zip: '10001',
      city: 'New York',
      state: 'NY',
      county: 'New York County',
      areaCodes: ['212', '646', '332'],
      region: ['NYC Metro'],
      timezone: 'America/New_York',
      lat: 40.7506,
      lng: -73.9972,
    ).toMap());
    await db.insert('lookup', const ZipEntry(
      zip: '02101',
      city: 'Boston',
      state: 'MA',
      county: 'Suffolk County',
      areaCodes: ['617', '857'],
      region: ['Boston, MA'],
      timezone: 'America/New_York',
      lat: 42.3588,
      lng: -71.0567,
    ).toMap());
  });

  group('LookupDbService Tests', () {
    test('searchByZip finds 5-digit and padded 4-digit zip', () async {
      final res1 = await dbService.searchByZip('10001');
      expect(res1.length, equals(1));
      expect(res1.first.city, equals('New York'));

      final res2 = await dbService.searchByZip('2101');
      expect(res2.length, equals(1));
      expect(res2.first.city, equals('Boston'));
    });

    test('searchByCity finds city name and partial match', () async {
      final res = await dbService.searchByCity('New York');
      expect(res.length, equals(1));
      expect(res.first.zip, equals('10001'));
    });

    test('searchByAreaCode matches area codes in middle or start of CSV list', () async {
      final res646 = await dbService.searchByAreaCode('646');
      expect(res646.length, equals(1));
      expect(res646.first.city, equals('New York'));

      final res617 = await dbService.searchByAreaCode('617');
      expect(res617.length, equals(1));
      expect(res617.first.city, equals('Boston'));
    });

    test('suggest returns mode-tailored suggestions', () async {
      final zipSugg = await dbService.suggest('100', mode: LookupMode.byZip);
      expect(zipSugg, contains('10001 (New York, NY)'));

      final citySugg = await dbService.suggest('Bost', mode: LookupMode.byCity);
      expect(citySugg, contains('Boston, MA'));

      final areaSugg = await dbService.suggest('64', mode: LookupMode.byAreaCode);
      expect(areaSugg, contains('646 (New York, NY)'));
    });
  });
}
