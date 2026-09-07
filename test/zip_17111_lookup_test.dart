/// FILE: test/zip_17111_lookup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/db/app_database.dart';
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
    await db.insert('lookup', const ZipEntry(
      zip: '10001',
      city: 'New York',
      state: 'NY',
      county: 'New York County',
      areaCodes: ['212'],
      region: ['NYC Metro'],
      timezone: 'America/New_York',
      lat: 40.7506,
      lng: -73.9972,
    ).toMap());
    await db.insert('lookup', const ZipEntry(
      zip: '90210',
      city: 'Beverly Hills',
      state: 'CA',
      county: 'Los Angeles County',
      areaCodes: ['310'],
      region: ['Los Angeles, CA'],
      timezone: 'America/Los_Angeles',
      lat: 34.0901,
      lng: -118.4065,
    ).toMap());
    await db.insert('lookup', const ZipEntry(
      zip: '00501',
      city: 'Holtsville',
      state: 'NY',
      county: 'Suffolk County',
      areaCodes: ['631'],
      region: ['Suffolk County, NY'],
      timezone: 'America/New_York',
      lat: 40.8154,
      lng: -73.0451,
    ).toMap());
    await db.insert('lookup', const ZipEntry(
      zip: '02108',
      city: 'Boston',
      state: 'MA',
      county: 'Suffolk County',
      areaCodes: ['617'],
      region: ['Boston, MA'],
      timezone: 'America/New_York',
      lat: 42.3588,
      lng: -71.0567,
    ).toMap());
  });

  group('ZIP & Area Code Local Data-Driven Required Test Cases', () {
    test('17111 -> Harrisburg, PA', () async {
      final results = await dbService.searchByZip('17111');
      expect(results, isNotEmpty);
      expect(results.first.city, equals('Harrisburg'));
      expect(results.first.state, equals('PA'));
      expect(results.first.county, equals('Dauphin'));
    });

    test('10001 -> New York, NY', () async {
      final results = await dbService.searchByZip('10001');
      expect(results, isNotEmpty);
      expect(results.first.city, equals('New York'));
      expect(results.first.state, equals('NY'));
    });

    test('90210 -> Beverly Hills, CA', () async {
      final results = await dbService.searchByZip('90210');
      expect(results, isNotEmpty);
      expect(results.first.city, equals('Beverly Hills'));
      expect(results.first.state, equals('CA'));
    });

    test('00501 -> Holtsville, NY (Leading Zeros Preserved)', () async {
      final results = await dbService.searchByZip('00501');
      expect(results, isNotEmpty);
      expect(results.first.city, equals('Holtsville'));
      expect(results.first.state, equals('NY'));
    });

    test('02108 -> Boston, MA (Leading Zero Preserved)', () async {
      final results = await dbService.searchByZip('02108');
      expect(results, isNotEmpty);
      expect(results.first.city, equals('Boston'));
      expect(results.first.state, equals('MA'));
    });

    test('717 -> Area Code searchByAreaCode returns Harrisburg, PA', () async {
      final results = await dbService.searchByAreaCode('717');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.city == 'Harrisburg' && r.state == 'PA'), isTrue);
    });

    test('212 -> Area Code searchByAreaCode returns New York, NY', () async {
      final results = await dbService.searchByAreaCode('212');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.city == 'New York' && r.state == 'NY'), isTrue);
    });

    test('310 -> Area Code searchByAreaCode returns Beverly Hills, CA', () async {
      final results = await dbService.searchByAreaCode('310');
      expect(results, isNotEmpty);
      expect(results.any((r) => r.state == 'CA'), isTrue);
    });

    test('Fuzzy matching: "harrisburg" and "Harris burg" -> Harrisburg', () async {
      final res1 = await dbService.searchByCity('harrisburg');
      expect(res1, isNotEmpty);
      expect(res1.first.city, equals('Harrisburg'));

      final res2 = await dbService.searchByCity('Harris burg');
      expect(res2, isNotEmpty);
      expect(res2.first.city, equals('Harrisburg'));
    });

    test('ZIP+4 format 17111-1234 -> Harrisburg, PA', () async {
      final results = await dbService.searchByZip('17111-1234');
      expect(results, isNotEmpty);
      expect(results.first.city, equals('Harrisburg'));
      expect(results.first.state, equals('PA'));
    });
  });
}
