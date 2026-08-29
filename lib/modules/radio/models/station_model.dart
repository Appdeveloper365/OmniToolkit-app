/// FILE: lib/modules/radio/models/station_model.dart

/// A radio/TV audio station as returned by the Radio Browser API.
class StationModel {
  const StationModel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.category,
    required this.country,
    this.favicon,
  });

  final String id;
  final String name;
  final String streamUrl;
  final String category;
  final String country;
  final String? favicon;

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['stationuuid'] as String? ?? json['name'] as String,
      name: json['name'] as String? ?? 'Unknown station',
      streamUrl: json['url_resolved'] as String? ?? json['url'] as String? ?? '',
      category: (json['tags'] as String? ?? '').split(',').firstWhere(
            (t) => t.trim().isNotEmpty,
            orElse: () => 'general',
          ),
      country: json['country'] as String? ?? '',
      favicon: (json['favicon'] as String?)?.isEmpty ?? true ? null : json['favicon'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'stationuuid': id,
        'name': name,
        'url_resolved': streamUrl,
        'tags': category,
        'country': country,
        'favicon': favicon,
      };
}
