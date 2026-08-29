/// FILE: lib/modules/lookup/models/lookup_models.dart

enum LookupMode { byZip, byCity, byAreaCode }

/// Data model representing a single ZIP record in [zipData].
class ZipRecord {
  final String zip;
  final String city;
  final String state;
  final String? county;
  final String? timezone;
  final double? lat;
  final double? lng;

  const ZipRecord({
    required this.zip,
    required this.city,
    required this.state,
    this.county,
    this.timezone,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
        'zip': zip,
        'city': city,
        'state': state,
        'county': county,
        'timezone': timezone,
        'lat': lat,
        'lng': lng,
      };

  factory ZipRecord.fromJson(Map<String, dynamic> json) => ZipRecord(
        zip: json['zip'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        county: json['county'] as String?,
        timezone: json['timezone'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

/// Data model representing a single Area Code record in [areaCodeData],
/// enriched with county/timezone/lat-lng from the unified dataset (see
/// assets/data/area_codes.json, tool/generate_area_codes.dart).
class AreaCodeRecord {
  final String areaCode;
  final String city;
  final String state;
  final String? country;
  final String? county;
  final String? timezone;
  final double? lat;
  final double? lng;

  const AreaCodeRecord({
    required this.areaCode,
    required this.city,
    required this.state,
    this.country,
    this.county,
    this.timezone,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
        'areaCode': areaCode,
        'city': city,
        'state': state,
        'country': country,
        'county': county,
        'timezone': timezone,
        'lat': lat,
        'lng': lng,
      };

  factory AreaCodeRecord.fromJson(Map<String, dynamic> json) => AreaCodeRecord(
        areaCode: (json['area_code'] ?? json['areaCode']).toString(),
        city: (json['city'] ?? '').toString(),
        state: (json['state'] ?? '').toString(),
        country: json['country'] as String?,
        county: json['county'] as String?,
        timezone: json['timezone'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}
