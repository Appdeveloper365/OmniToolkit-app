/// FILE: test/radio_stream_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/radio/models/station_model.dart';
import 'package:omnitoolkit/modules/radio/services/radio_service.dart';
import 'package:omnitoolkit/modules/radio/services/stream_resolver_service.dart';

void main() {
  final resolver = StreamResolverService();

  group('StreamResolverService tests', () {
    test('handles empty stream URL gracefully', () async {
      final result = await resolver.resolveAndValidate('');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('empty'));
    });

    test('validates direct MP3 stream URL', () async {
      const url = 'https://ice1.somafm.com/groovesalad-128-mp3';
      final result = await resolver.resolveAndValidate(url);
      expect(result.isValid, isTrue);
      expect(result.detectedFormat, 'MP3');
    });

    test('detects unsupported audio extensions', () async {
      const url = 'https://example.com/audio.wma';
      final result = await resolver.resolveAndValidate(url);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('unsupported audio format'));
    });

    test('StationModel handles json parsing with new fields', () {
      final json = {
        'stationuuid': 'stat-123',
        'name': 'Test Radio',
        'url_resolved': 'https://test.stream/live',
        'tags': 'jazz,classic',
        'country': 'United Kingdom',
        'countrycode': 'GB',
        'language': 'English',
        'bitrate': 128,
        'codec': 'MP3',
        'favicon': 'https://test.stream/logo.png',
      };
      final model = StationModel.fromJson(json);
      expect(model.id, 'stat-123');
      expect(model.name, 'Test Radio');
      expect(model.category, 'Jazz');
      expect(model.country, 'United Kingdom');
      expect(model.countryCode, 'GB');
      expect(model.bitrate, 128);
      expect(model.codec, 'MP3');
      expect(model.favicon, 'https://test.stream/logo.png');
    });

    test('RadioService country and genre directories are configured', () {
      expect(RadioService.genres, contains('Jazz'));
      expect(RadioService.genres, contains('Pop'));
      expect(RadioService.countries.any((c) => c.code == 'US'), isTrue);
      expect(RadioService.countries.any((c) => c.code == 'GB'), isTrue);
    });
  });
}
