# Repository Purpose

OmniToolkit is a Flutter app bundling several offline-first utility modules (Weather,
Calendar, Calculator, Radio/TV, ZIP/Area-code Lookup, Clipper) behind a single bottom
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
  `Provider`, `StateProvider`, and `FutureProvider` — no `StatefulWidget` business logic beyond
  local `TextEditingController`/`FocusNode` bookkeeping.
- `assets/data/` — bundled seed datasets (zip/area-code lookup, holidays, radio streams).
- `test/` — widget/unit tests use `sqflite_common_ffi` with `databaseFactoryFfi` for DB-backed
  tests. Widget tests that touch real async I/O (SQLite FFI, `rootBundle`, network) must use
  `tester.runAsync()` — plain `tester.pump()`/`pumpAndSettle()` will hang because the fake-async
  test zone never drains real OS-level async callbacks.

# Development Guidelines

- Run `flutter analyze` and `flutter test` before considering a change done; both must be clean.
- When adding a Riverpod `FutureProvider` that depends on another provider via `ref.watch`,
  keep in mind it recomputes (and briefly shows a loading state) on every dependency change —
  don't rely on it to preserve external mutable state across rebuilds.
- Prefer binding a single `TextEditingController` directly to `Autocomplete`'s
  `textEditingController` parameter over maintaining a second shadow controller — a previous bug
  in the Lookup module came from exactly that duplication (see `lib/modules/lookup/screens/lookup_screen.dart`).
- `AppDatabase` is a process-wide singleton; don't open a second connection to the same file.
