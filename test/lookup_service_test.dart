import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/lookup/models/lookup_models.dart';
import 'package:omnitoolkit/modules/lookup/services/lookup_service.dart';

void main() {
  group('LookupService Cross-Lookup Tests', () {
    late LookupService service;

    setUp(() {
      service = LookupService();

      // Seed zipData
      service.addZipRecord(const ZipRecord(
        zip: '10001',
        city: 'New York',
        state: 'NY',
        county: 'New York County',
        timezone: 'America/New_York',
        lat: 40.7506,
        lng: -73.9972,
      ));
      service.addZipRecord(const ZipRecord(
        zip: '10002',
        city: 'New York',
        state: 'NY',
        county: 'New York County',
        timezone: 'America/New_York',
        lat: 40.7157,
        lng: -73.9863,
      ));
      service.addZipRecord(const ZipRecord(
        zip: '90001',
        city: 'Los Angeles',
        state: 'CA',
        county: 'Los Angeles County',
        timezone: 'America/Los_Angeles',
        lat: 33.9731,
        lng: -118.2479,
      ));
      service.addZipRecord(const ZipRecord(
        zip: '02101',
        city: 'Boston',
        state: 'MA',
        county: 'Suffolk County',
        timezone: 'America/New_York',
        lat: 42.3588,
        lng: -71.0567,
      ));

      // Seed areaCodeData
      service.addAreaCodeRecord(const AreaCodeRecord(
        areaCode: '212',
        city: 'New York',
        state: 'NY',
      ));
      service.addAreaCodeRecord(const AreaCodeRecord(
        areaCode: '646',
        city: 'New York',
        state: 'NY',
      ));
      service.addAreaCodeRecord(const AreaCodeRecord(
        areaCode: '332',
        city: 'New York',
        state: 'NY',
      ));
      service.addAreaCodeRecord(const AreaCodeRecord(
        areaCode: '213',
        city: 'Los Angeles',
        state: 'CA',
      ));
      service.addAreaCodeRecord(const AreaCodeRecord(
        areaCode: '323',
        city: 'Los Angeles',
        state: 'CA',
      ));
      service.addAreaCodeRecord(const AreaCodeRecord(
        areaCode: '617',
        city: 'Boston',
        state: 'MA',
      ));
    });

    test('1. lookupAreaCodesFromZip(zip)', () {
      final codes = service.lookupAreaCodesFromZip('10001');
      expect(codes, equals(['212', '332', '646'])); // Sorted ascending & deduplicated
    });

    test('2. lookupZipsFromAreaCode(areaCode)', () {
      final zips = service.lookupZipsFromAreaCode('212');
      expect(zips, equals(['10001', '10002'])); // Sorted ascending & deduplicated
    });

    test('3. lookupCityFromZip(zip)', () {
      final city1 = service.lookupCityFromZip('10001');
      expect(city1, equals('New York, NY'));

      final city2 = service.lookupCityFromZip('02101');
      expect(city2, equals('Boston, MA'));

      final city3 = service.lookupCityFromZip('99999');
      expect(city3, isNull);
    });

    test('4. lookupZipsFromCity(city)', () {
      final zips = service.lookupZipsFromCity('new york');
      expect(zips, equals(['10001', '10002']));
    });

    test('5. lookupCityFromAreaCode(areaCode)', () {
      final city = service.lookupCityFromAreaCode('213');
      expect(city, equals('Los Angeles, CA'));
    });

    test('6. lookupAreaCodesFromCity(city)', () {
      final codes = service.lookupAreaCodesFromCity('Los Angeles');
      expect(codes, equals(['213', '323']));
    });
  });
}
