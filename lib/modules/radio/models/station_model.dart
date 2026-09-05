/// FILE: lib/modules/radio/models/station_model.dart

/// A radio audio station details model.
class StationModel {
  const StationModel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.category,
    required this.country,
    this.countryCode,
    this.city,
    this.language,
    this.bitrate,
    this.codec,
    this.favicon,
  });

  final String id;
  final String name;
  final String streamUrl;
  final String category;
  final String country;
  final String? countryCode;
  final String? city;
  final String? language;
  final int? bitrate;
  final String? codec;
  final String? favicon;

  factory StationModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'] as String? ?? json['category'] as String? ?? '';
    final tagList = rawTags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final firstTag = tagList.isNotEmpty ? tagList.first : 'General';
    final formattedCategory = firstTag[0].toUpperCase() + (firstTag.length > 1 ? firstTag.substring(1) : '');

    final rawBitrate = json['bitrate'];
    int? parsedBitrate;
    if (rawBitrate is int) {
      parsedBitrate = rawBitrate > 0 ? rawBitrate : null;
    } else if (rawBitrate is String) {
      parsedBitrate = int.tryParse(rawBitrate);
    }

    final rawFavicon = json['favicon'] as String?;
    final cleanFavicon = (rawFavicon != null && rawFavicon.trim().isNotEmpty) ? rawFavicon.trim() : null;

    return StationModel(
      id: json['stationuuid'] as String? ?? json['id'] as String? ?? json['name'] as String? ?? 'unknown',
      name: (json['name'] as String? ?? 'Unknown station').trim(),
      streamUrl: json['url_resolved'] as String? ?? json['url'] as String? ?? json['streamUrl'] as String? ?? '',
      category: formattedCategory,
      country: (json['country'] as String? ?? '').trim(),
      countryCode: (json['countrycode'] as String? ?? json['countryCode'] as String?)?.trim(),
      city: (json['state'] as String? ?? json['city'] as String?)?.trim(),
      language: (json['language'] as String?)?.trim(),
      bitrate: parsedBitrate,
      codec: (json['codec'] as String?)?.trim(),
      favicon: cleanFavicon,
    );
  }

  Map<String, dynamic> toJson() => {
        'stationuuid': id,
        'id': id,
        'name': name,
        'url_resolved': streamUrl,
        'streamUrl': streamUrl,
        'tags': category,
        'category': category,
        'country': country,
        'countrycode': countryCode,
        'city': city,
        'language': language,
        'bitrate': bitrate,
        'codec': codec,
        'favicon': favicon,
      };
}
