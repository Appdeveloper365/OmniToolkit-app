import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/radio/services/radio_service.dart';

void main() {
  final service = RadioService();

  test('RadioService returns public stations with http and https streams', () async {
    final stations = await service.topStations();
    expect(stations, isNotEmpty);
    expect(stations.first.streamUrl, startsWith('http'));
  });
}
