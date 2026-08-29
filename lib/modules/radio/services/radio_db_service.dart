/// FILE: lib/modules/radio/services/radio_db_service.dart
import '../../../core/db/app_database.dart';
import '../models/station_model.dart';

/// Reads the offline `radio_streams` table (populated by `AssetImporter`
/// from assets/data/radio_streams.json) used when the live Radio Browser
/// API is unreachable.
class RadioDbService {
  Future<List<StationModel>> loadStreams() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('radio_streams');
    return rows
        .map((row) => StationModel(
              id: row['name'] as String,
              name: row['name'] as String,
              streamUrl: row['url'] as String,
              category: (row['codec'] as String?) ?? 'MP3',
              country: '',
            ))
        .where((s) => s.streamUrl.startsWith('https://'))
        .toList();
  }
}
