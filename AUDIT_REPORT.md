# OmniToolkit — Code Audit Report

**Date:** 2026-09-28
**Commit audited:** `0f6aeba` (fix: resolve calculator test failure for portrait layout)
**Branch:** `main`, clean tree at audit start
**Toolchain:** Flutter 3.47.5 / Dart 3.13.1, `flutter analyze` + `flutter test`

---

## Summary

| Check | Before | After |
|---|---|---|
| `flutter analyze` | 11 issues (5 warning, 6 info) | **No issues found** |
| `flutter test` | 69 passed, 1 failed | **70 passed, 0 failed** |

Four real bugs found, all in the SQLite schema/migration layer. Three were
shipped-broken; the fourth was masked behind one of them. All four are fixed
and verified against a simulated v3 → v6 upgrade.

---

## Bug 1 — Declared schema version made the v6 migration unreachable

**File:** `lib/core/db/app_database.dart:38`
**Severity:** High — silently breaks the radio directory for every upgrading user

`openDatabase` was called with `version: 5` while `onUpgrade` contained an
`oldVersion < 6` block. SQLite only calls `onUpgrade` when the stored version
differs from the declared version, and only ever migrates *upward to* the
declared value. With `version: 5` declared, no install can ever be in a state
that triggers the v6 repair, so the fix the code intended to ship never ran.

**Fix:** `version: 5` → `version: 6`.

---

## Bug 2 — Migrations referenced a table that has never existed

**File:** `lib/core/db/app_database.dart:139-141` (removed)
**Severity:** High — breaks ZIP/area-code lookup on upgrade

The v3 block ran:

```dart
if (!(await _columnExists(db, 'zip_lookup', 'region'))) {
  await db.execute('ALTER TABLE zip_lookup ADD COLUMN region TEXT');
}
```

`zip_lookup` appears nowhere else in `lib/` and nowhere in the repository's
git history as a created table — the first version of this file already
declared `version: 4` with a `lookup` table. `PRAGMA table_info` on a missing
table returns zero rows rather than erroring, so `_columnExists` returned
`false`, the `ALTER TABLE` targeted a nonexistent table, and the migration
no-opped. `lookup` never received its `region` column.

**Fix:** removed the dead `zip_lookup` branch; the real column creation is
handled by the v4 block (Bug 3), which recreates `lookup` with `region`.

---

## Bug 3 — Migration guards were out of order

**File:** `lib/core/db/app_database.dart` (v4 block relocated)
**Severity:** High — v4 work ran before its own table existed

Guard order was `< 2`, `< 3`, `< 5`, `< 4`, `< 6`. The `< 5` block ran
*before* the `< 4` block, and `< 4` is what creates the `lookup` table. A v1
install therefore performed the v5 calendar work first, then created
`lookup` afterwards — while the v3 block had already tried to alter a
`zip_lookup` table that did not exist. The mismatched indentation on the
`< 4` line shows it was appended later without being placed in sequence.

**Fix:** moved the `< 4` block between `< 3` and `< 5`. Guards are now
monotonic: 2, 3, 4, 5, 6.

---

## Bug 4 — `radio_streams` column names never reconciled across schema versions

**File:** `lib/core/db/app_database.dart` (v6 block rewritten)
**Severity:** High — this is the actual cause of the empty radio directory

`AssetImporter` writes `name`, `url`, `codec`, `country`, `countrycode`, and
`radio_db_service` reads the same names. But a pre-v3 install's table used
`streamUrl` and `category` instead of `url` and `codec`.

The original v6 fix only did:

```dart
if (!(await _columnExists(db, 'radio_streams', 'country'))) { ... ADD COLUMN country ... }
if (!(await _columnExists(db, 'radio_streams', 'countrycode'))) { ... ADD COLUMN countrycode ... }
```

On a v3-era database this added two columns but left the table without `url`,
so `AssetImporter`'s insert failed with *"table radio_streams has no column
named url"*. The exception was swallowed by the `try/catch` in `main.dart:28`,
so the failure was invisible — the app simply had no stations. This is exactly
the symptom the file's own comment describes.

This bug was masked by Bugs 1–3: the v6 block never executed at all.

**Fix:** the v6 block now drops and recreates `radio_streams` in the current
shape. Safe because the table holds only re-importable seed data — the same
reason the v3 and v4 blocks already drop their tables.

---

## Verification

Beyond the 70-test suite, the migration chain was validated with a temporary
integration test that:

1. Creates a genuine v3-schema database (with the legacy `title`/`description`
   note columns and `streamUrl`/`category` radio columns), seeded with a real
   calendar note.
2. Runs the full ordered `onUpgrade` body to v6.
3. Asserts `lookup.zip` and `lookup.region` exist.
4. Performs the exact insert `AssetImporter` performs on every launch.
5. Asserts a pre-existing calendar note survives the title→`note_text` rewrite.

Result: all assertions pass. The probe was removed afterward; it is not part
of the committed change.

---

## Also fixed (lint-level, no behavior change)

- `scientific_keypad.dart:25` — removed unused local helper `f`.
- `weather_service.dart:163` — removed unused `cloud` local.
- `weather_service.dart:282` — removed unused `_getTemperatureAtOffset` method.
- `weather_service.dart:248` — wrapped `else if` body in a block.
- `calendar_grid.dart:112` — removed unused `isToday` local.
- 5 × `withOpacity` → `withValues(alpha:)` in `premium_calculator_button.dart`
  and `calendar_grid.dart`, matching the pattern already used elsewhere in the
  codebase.

## Test fix (not an app bug)

`test/calculator_widget_test.dart` — the scientific calculator test failed for
two test-side reasons:

1. `find.text('0')` matched **two** widgets: the keypad key and the display,
   which renders `"0"` while the expression is empty. Fixed by scoping digit
   lookups with `find.descendant(of: keypad, ...)`.
2. The 1200px surface put the bottom `0` key at y=1204 — just off-screen. The
   scientific keypad stacks 10 rows above the number pad. Surface raised to
   1800px.

The application code was correct in both cases; the assertions were not.
