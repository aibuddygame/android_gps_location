import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/mock_location_session.dart';
import '../models/location_history_model.dart';

class HistoryRepository {
  HistoryRepository();

  late final _HistoryDatabase _database;

  Future<void> init() async {
    _database = _HistoryDatabase(_openConnection());
    await _createTables();
  }

  Future<List<LocationHistoryModel>> loadHistory({int limit = 100}) async {
    final rows = await _database.customSelect(
      '''
          SELECT id, coordinate_key, latitude, longitude, location_name,
                 first_used_at, last_used_at, use_count
          FROM location_history
          ORDER BY last_used_at DESC
          LIMIT ?
          ''',
      variables: [Variable.withInt(limit)],
    ).get();

    return rows.map((row) => LocationHistoryModel.fromRow(row.data)).toList();
  }

  Future<LocationHistoryModel?> findLocation(
    double latitude,
    double longitude,
  ) async {
    final key = LocationHistoryModel.coordinateKeyFor(latitude, longitude);
    final rows = await _database.customSelect(
      '''
          SELECT id, coordinate_key, latitude, longitude, location_name,
                 first_used_at, last_used_at, use_count
          FROM location_history
          WHERE coordinate_key = ?
          LIMIT 1
          ''',
      variables: [Variable.withString(key)],
    ).get();
    if (rows.isEmpty) return null;
    return LocationHistoryModel.fromRow(rows.first.data);
  }

  Future<LocationHistoryModel> recordLocation(
    MockLocationSession session, {
    String? locationName,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final key = LocationHistoryModel.coordinateKeyFor(
      session.latitude,
      session.longitude,
    );

    await _database.customStatement(
      '''
      INSERT INTO location_history (
        coordinate_key, latitude, longitude, location_name,
        first_used_at, last_used_at, use_count
      )
      VALUES (?, ?, ?, ?, ?, ?, 1)
      ON CONFLICT(coordinate_key) DO UPDATE SET
        latitude = excluded.latitude,
        longitude = excluded.longitude,
        location_name = COALESCE(excluded.location_name, location_name),
        last_used_at = excluded.last_used_at,
        use_count = use_count + 1
      ''',
      [
        key,
        session.latitude,
        session.longitude,
        _blankToNull(locationName),
        now,
        now,
      ],
    );

    final saved = await findLocation(session.latitude, session.longitude);
    return saved!;
  }

  Future<String?> getCachedLocationName(
    double latitude,
    double longitude,
  ) async {
    final key = LocationHistoryModel.coordinateKeyFor(latitude, longitude);
    final rows = await _database.customSelect(
      '''
          SELECT location_name
          FROM geocoding_cache
          WHERE coordinate_key = ?
          LIMIT 1
          ''',
      variables: [Variable.withString(key)],
    ).get();
    if (rows.isEmpty) return null;
    return rows.first.data['location_name'] as String?;
  }

  Future<void> cacheLocationName({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    final name = _blankToNull(locationName);
    if (name == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final key = LocationHistoryModel.coordinateKeyFor(latitude, longitude);

    await _database.customStatement(
      '''
      INSERT INTO geocoding_cache (
        coordinate_key, latitude, longitude, location_name, updated_at
      )
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(coordinate_key) DO UPDATE SET
        latitude = excluded.latitude,
        longitude = excluded.longitude,
        location_name = excluded.location_name,
        updated_at = excluded.updated_at
      ''',
      [key, latitude, longitude, name, now],
    );

    await _database.customStatement(
      '''
      UPDATE location_history
      SET location_name = ?
      WHERE coordinate_key = ? AND (location_name IS NULL OR location_name = '')
      ''',
      [name, key],
    );
  }

  Future<void> clearHistory() async {
    await _database.customStatement('DELETE FROM location_history');
  }

  Future<void> close() {
    return _database.close();
  }

  Future<void> _createTables() async {
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS location_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coordinate_key TEXT NOT NULL UNIQUE,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        location_name TEXT,
        first_used_at INTEGER NOT NULL,
        last_used_at INTEGER NOT NULL,
        use_count INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS geocoding_cache (
        coordinate_key TEXT PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        location_name TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'location_history.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class _HistoryDatabase extends GeneratedDatabase {
  _HistoryDatabase(QueryExecutor executor) : super(executor);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  int get schemaVersion => 1;
}
