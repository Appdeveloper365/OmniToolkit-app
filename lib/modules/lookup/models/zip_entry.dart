/// FILE: lib/modules/lookup/models/zip_entry.dart

/// A single offline ZIP / city / state / county / area-code / region /
/// timezone / lat-lng lookup record.
class ZipEntry {
  const ZipEntry({
    this.id,
    required this.zip,
    required this.city,
    required this.state,
    this.county,
    required this.areaCodes,
    this.region = const [],
    this.timezone,
    this.lat,
    this.lng,
  });

  final int? id;
  final String zip;
  final String city;
  final String state;
  final String? county;
  final List<String> areaCodes;
  final List<String> region;
  final String? timezone;
  final double? lat;
  final double? lng;

  /// Comma-joined area codes for display/back-compat with single-value UI.
  String get areaCode => areaCodes.join(', ');

  /// Comma-joined region labels, or null when none are known.
  String? get regionLabel => region.isEmpty ? null : region.join(', ');

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'zip': zip,
        'city': city,
        'state': state,
        'county': county,
        'areaCode': areaCodes.join(','),
        'region': region.join(','),
        'timezone': timezone,
        'lat': lat,
        'lng': lng,
      };

  factory ZipEntry.fromMap(Map<String, dynamic> map) => ZipEntry(
        id: map['id'] as int?,
        zip: map['zip'] as String,
        city: map['city'] as String,
        state: map['state'] as String,
        county: map['county'] as String?,
        areaCodes: _splitCsv(map['areaCode']),
        region: _splitCsv(map['region']),
        timezone: map['timezone'] as String?,
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
      );

  /// Parses the merged dataset's JSON shape, where `area_code` / `region`
  /// may be a JSON array or a single string.
  factory ZipEntry.fromJson(Map<String, dynamic> json) => ZipEntry(
        zip: json['zip'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        county: json['county'] as String?,
        areaCodes: _toStringList(json['area_code']),
        region: _toStringList(json['region']),
        timezone: json['timezone'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  static List<String> _splitCsv(dynamic value) {
    if (value == null) return const [];
    final s = value as String;
    if (s.isEmpty) return const [];
    return s.split(',');
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    final s = value.toString();
    return s.isEmpty ? const [] : [s];
  }
}
