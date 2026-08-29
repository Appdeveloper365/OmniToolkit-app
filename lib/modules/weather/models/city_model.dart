/// FILE: lib/modules/weather/models/city_model.dart

/// Represents a searchable place returned by the Open-Meteo geocoding API.
class CityModel {
  const CityModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.admin1,
  });

  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;
  final String timezone;

  String get displayName =>
      [name, if (admin1 != null && admin1!.isNotEmpty) admin1, country].join(', ');

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? 'UTC',
    );
  }
}
