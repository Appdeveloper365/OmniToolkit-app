# Repository Purpose

OmniToolkit is a Flutter app bundling several offline-first utility modules (Calendar & Clock,
Calculator, Radio Explorer, ZIP/Area-code Lookup, Password Generator) behind a single bottom
navigation / navigation rail shell.

# Setup Instructions

```
flutter pub get
flutter analyze
flutter test
flutter run -d windows   # or -d chrome / -d <android-device-id>
```

# Repository Structure

- `lib/main.dart` — app entry point; runs `AssetImporter.importFirstLaunch()` before `runApp`.
- `lib/core/navigation/main_navigation.dart` — root scaffold; switches between module screens
  by index (not `IndexedStack`, so screens rebuild from scratch on tab switch).
- `lib/core/db/app_database.dart` — single shared SQLite database (`AppDatabase.instance`).
  Uses `sqflite_common_ffi` on Windows/Linux/macOS, plain `sqflite` on Android/iOS. Schema
  migrations live in `onUpgrade`; bump `version` when changing table shapes.
- `lib/core/data/asset_importer.dart` — imports bundled JSON/CSV assets (`assets/data/*`) into
  SQLite on first launch / when a table is empty after a migration.
- `lib/modules/<name>/` — each module follows `screens/`, `providers/`, `services/`, `models/`,
  `widgets/` sub-folders. State management is **Riverpod** (`flutter_riverpod`), using
  `Provider`, `StateProvider`, and `FutureProvider`.
- `assets/data/` — bundled seed datasets (zip/area-code lookup, holidays, radio streams).
- `test/` — widget/unit tests use `sqflite_common_ffi` with `databaseFactoryFfi` for DB-backed
  tests.

# Development Guidelines

- Run `flutter analyze` and `flutter test` before considering a change done; both must be clean.
- AppDatabase is a process-wide singleton; don't open a second connection to the same file.
