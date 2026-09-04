/// FILE: lib/modules/calculator/services/unit_converter_service.dart

/// Supported unit conversion categories and their conversion factors,
/// expressed relative to a category-specific base unit.
class UnitConverterService {
  static const Map<String, Map<String, double>> _factors = {
    'Length': {
      'Meters': 1.0,
      'Kilometers': 1000.0,
      'Centimeters': 0.01,
      'Millimeters': 0.001,
      'Miles': 1609.344,
      'Yards': 0.9144,
      'Feet': 0.3048,
      'Inches': 0.0254,
    },
    'Weight': {
      'Kilograms': 1.0,
      'Grams': 0.001,
      'Milligrams': 0.000001,
      'Pounds': 0.45359237,
      'Ounces': 0.028349523125,
      'Tons': 1000.0,
    },
    'Volume': {
      'Liters': 1.0,
      'Milliliters': 0.001,
      'Gallons (US)': 3.785411784,
      'Cups': 0.2365882365,
      'Fluid Ounces (US)': 0.0295735296,
    },
    'Speed': {
      'Meters/sec': 1.0,
      'Kilometers/hour': 0.277778,
      'Miles/hour': 0.44704,
      'Knots': 0.514444,
    },
    'Area': {
      'Square Meters': 1.0,
      'Square Kilometers': 1000000.0,
      'Square Feet': 0.09290304,
      'Square Yards': 0.83612736,
      'Acres': 4046.8564224,
      'Hectares': 10000.0,
    },
    'Energy': {
      'Joules': 1.0,
      'Kilojoules': 1000.0,
      'Calories': 4.184,
      'Kilocalories': 4184.0,
      'Watt-hours': 3600.0,
      'Kilowatt-hours': 3600000.0,
    },
    'Storage': {
      'Bytes': 1.0,
      'KB': 1024.0,
      'MB': 1048576.0,
      'GB': 1073741824.0,
      'TB': 1099511627776.0,
    },
  };

  List<String> get categories => [..._factors.keys, 'Temperature'];

  List<String> unitsFor(String category) {
    if (category == 'Temperature') return ['Celsius', 'Fahrenheit', 'Kelvin'];
    return _factors[category]?.keys.toList() ?? [];
  }

  double convert(String category, String from, String to, double value) {
    if (category == 'Temperature') return _convertTemperature(from, to, value);
    final units = _factors[category];
    if (units == null) throw ArgumentError('Unknown category $category');
    final base = value * units[from]!;
    return base / units[to]!;
  }

  double _convertTemperature(String from, String to, double value) {
    double celsius;
    switch (from) {
      case 'Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        throw ArgumentError('Unknown unit $from');
    }
    switch (to) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        throw ArgumentError('Unknown unit $to');
    }
  }
}