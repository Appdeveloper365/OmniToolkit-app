/// FILE: lib/modules/clipper/services/clipper_db_service.dart
import '../../../core/db/app_database.dart';
import '../models/clip_model.dart';

/// CRUD + search access to the `clips` SQLite table.
class ClipperDbService {
  Future<int> insertClip(ClipModel clip) async {
    final db = await AppDatabase.instance.database;
    return db.insert('clips', clip.toMap());
  }

  Future<int> updateClip(ClipModel clip) async {
    final db = await AppDatabase.instance.database;
    return db.update('clips', clip.toMap(), where: 'id = ?', whereArgs: [clip.id]);
  }

  Future<int> deleteClip(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('clips', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ClipModel>> allClips() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('clips', orderBy: 'createdAt DESC');
    return rows.map(ClipModel.fromMap).toList();
  }

  Future<List<ClipModel>> search(String query) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'clips',
      where: 'text LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return rows.map(ClipModel.fromMap).toList();
  }
}
