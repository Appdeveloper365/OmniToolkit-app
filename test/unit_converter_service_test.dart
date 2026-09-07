import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/services/unit_converter_service.dart';

void main() {
  final service = UnitConverterService();

  test('categories include the required set', () {
    expect(service.categories, containsAll([
      'Length', 'Weight', 'Temperature', 'Volume', 'Area', 'Speed', 'Energy', 'Storage',
    ]));
  });

  test('Storage converts using binary (1024) factors: 1 GB = 1024 MB', () {
    expect(service.convert('Storage', 'GB', 'MB', 1), closeTo(1024, 1e-9));
    expect(service.convert('Storage', 'TB', 'GB', 1), closeTo(1024, 1e-9));
  });

  test('Area converts square meters to acres', () {
    final acres = service.convert('Area', 'Square Meters', 'Acres', 4046.8564224);
    expect(acres, closeTo(1, 1e-6));
  });

  test('Energy converts kilocalories to kilojoules', () {
    final kj = service.convert('Energy', 'Kilocalories', 'Kilojoules', 1);
    expect(kj, closeTo(4.184, 1e-9));
  });

  test('Temperature still converts correctly across all three units', () {
    expect(service.convert('Temperature', 'Celsius', 'Fahrenheit', 100), closeTo(212, 1e-9));
    expect(service.convert('Temperature', 'Fahrenheit', 'Kelvin', 32), closeTo(273.15, 1e-9));
  });
}