/// FILE: lib/core/db/app_database.dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Single shared SQLite database used by every module that needs
/// persistent storage (Calendar, Clipper, Lookup).
class AppDatabase {
  AppDatabase._internal() {
    // The plain sqflite plugin only ships Android/iOS implementations, so
    // desktop platforms must use the FFI-based factory instead.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
  static final AppDatabase instance = AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'omnitoolkit.db');
    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calendar_notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            reminderTime TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE clips (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            tags TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE lookup (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            zip TEXT NOT NULL,
            city TEXT NOT NULL,
            state TEXT NOT NULL,
            county TEXT,
            areaCode TEXT,
            region TEXT,
            timezone TEXT,
            lat REAL,
            lng REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE holidays (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            name TEXT NOT NULL,
            country TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE radio_streams (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            url TEXT NOT NULL,
            codec TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_notes_date ON calendar_notes(date)');
        await db.execute('CREATE INDEX idx_zip ON lookup(zip)');
        await db.execute('CREATE INDEX idx_city ON lookup(city)');
        await db.execute('CREATE INDEX idx_area ON lookup(areaCode)');
        await db.execute('CREATE INDEX idx_holiday_date ON holidays(date)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE holidays (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              month INTEGER NOT NULL,
              day INTEGER NOT NULL,
              description TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE radio_streams (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              stationId TEXT NOT NULL,
              name TEXT NOT NULL,
              streamUrl TEXT NOT NULL,
              category TEXT,
              country TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          // Schema for holidays/radio_streams/zip_lookup changed shape; these
          // tables only hold re-importable seed data, so recreate them fresh.
          await db.execute('DROP TABLE IF EXISTS holidays');
          await db.execute('DROP TABLE IF EXISTS radio_streams');
          await db.execute('''
            CREATE TABLE holidays (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              name TEXT NOT NULL,
              country TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE radio_streams (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              url TEXT NOT NULL,
              codec TEXT
            )
          ''');
          await db.execute('CREATE INDEX idx_holiday_date ON holidays(date)');
          if (!(await _columnExists(db, 'zip_lookup', 'region'))) {
            await db.execute('ALTER TABLE zip_lookup ADD COLUMN region TEXT');
          }
        }
        if (oldVersion < 4) {
          // Merged dataset adds county/timezone/lat/lng and renames the
          // table; re-importable seed data, so drop and recreate fresh.
          await db.execute('DROP TABLE IF EXISTS zip_lookup');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS lookup (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              zip TEXT NOT NULL,
              city TEXT NOT NULL,
              state TEXT NOT NULL,
              county TEXT,
              areaCode TEXT,
              region TEXT,
              timezone TEXT,
              lat REAL,
              lng REAL
            )
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_zip ON lookup(zip)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_city ON lookup(city)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_area ON lookup(areaCode)');
        }
      },
    );
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    return columns.any((c) => c['name'] == column);
  }
}

