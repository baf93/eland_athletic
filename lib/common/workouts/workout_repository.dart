import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Local storage for custom workouts and history (sqflite).
///
/// Rows hold the JSON of each object: the schema stays trivial and the same
/// JSON is used for the export/import backup file. The database lives in the
/// app "databases" folder, which is included in Android Auto Backup.
class WorkoutRepository {
  static const String dbName = 'eland.db';
  static const int backupVersion = 1;
  static const String backupFormat = 'eland.backup';

  final DatabaseFactory? _factoryOverride;
  final String? _path;
  Database? _db;

  WorkoutRepository({DatabaseFactory? factory, String? path})
      : _factoryOverride = factory,
        _path = path;

  // Resolved lazily: the global sqflite factory is only needed on first use.
  DatabaseFactory get _factory => _factoryOverride ?? databaseFactory;

  Future<Database> get _database async {
    final existing = _db;
    if (existing != null) return existing;

    final path = _path ?? p.join(await _factory.getDatabasesPath(), dbName);
    final db = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE workouts (id TEXT PRIMARY KEY, data TEXT NOT NULL, updated_at INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE history (id TEXT PRIMARY KEY, data TEXT NOT NULL, completed_at INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE INDEX history_completed_at ON history (completed_at)',
          );
        },
      ),
    );
    _db = db;
    return db;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // --- Workouts ------------------------------------------------------------

  Future<List<CustomWorkout>> getWorkouts() async {
    final db = await _database;
    final rows = await db.query('workouts', orderBy: 'updated_at DESC');
    return rows
        .map((r) => CustomWorkout.fromJson(
            jsonDecode(r['data'] as String) as Map<String, dynamic>))
        .toList();
  }

  Future<CustomWorkout?> getWorkout(String id) async {
    final db = await _database;
    final rows = await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return CustomWorkout.fromJson(
        jsonDecode(rows.first['data'] as String) as Map<String, dynamic>);
  }

  Future<void> saveWorkout(CustomWorkout workout) async {
    final db = await _database;
    await db.insert(
      'workouts',
      {
        'id': workout.id,
        'data': jsonEncode(workout.toJson()),
        'updated_at': workout.updatedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWorkout(String id) async {
    final db = await _database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // --- History -------------------------------------------------------------

  Future<List<WorkoutLog>> getHistory() async {
    final db = await _database;
    final rows = await db.query('history', orderBy: 'completed_at DESC');
    return rows
        .map((r) => WorkoutLog.fromJson(
            jsonDecode(r['data'] as String) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLog(WorkoutLog log) async {
    final db = await _database;
    await db.insert(
      'history',
      {
        'id': log.id,
        'data': jsonEncode(log.toJson()),
        'completed_at': log.completedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteLog(String id) async {
    final db = await _database;
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  // --- Backup --------------------------------------------------------------

  /// Full export (workouts, history and the given settings) as JSON.
  Future<Map<String, dynamic>> exportData({
    Map<String, Object?> settings = const {},
  }) async {
    return {
      'format': backupFormat,
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings,
      'workouts': (await getWorkouts()).map((w) => w.toJson()).toList(),
      'history': (await getHistory()).map((l) => l.toJson()).toList(),
    };
  }

  /// Merges a backup into the local data (same id = backup wins).
  /// Throws [FormatException] if the content is not an Eland backup.
  Future<BackupImportResult> importData(Map<String, dynamic> data) async {
    if (data['format'] != backupFormat) {
      throw const FormatException('Not an Eland backup file');
    }
    final version = (data['version'] as num?)?.toInt() ?? 0;
    if (version > backupVersion) {
      throw const FormatException('Backup created by a newer app version');
    }

    final workouts = (data['workouts'] as List? ?? const [])
        .whereType<Map>()
        .map((w) => CustomWorkout.fromJson(Map<String, dynamic>.from(w)))
        .where((w) => w.name.trim().isNotEmpty && w.blocks.isNotEmpty)
        .toList();
    final history = (data['history'] as List? ?? const [])
        .whereType<Map>()
        .map((l) => WorkoutLog.fromJson(Map<String, dynamic>.from(l)))
        .toList();

    final db = await _database;
    await db.transaction((txn) async {
      for (final w in workouts) {
        await txn.insert(
          'workouts',
          {
            'id': w.id,
            'data': jsonEncode(w.toJson()),
            'updated_at': w.updatedAt.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final l in history) {
        await txn.insert(
          'history',
          {
            'id': l.id,
            'data': jsonEncode(l.toJson()),
            'completed_at': l.completedAt.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    final settings = data['settings'] is Map
        ? Map<String, Object?>.from(data['settings'] as Map)
        : <String, Object?>{};

    return BackupImportResult(
      workouts: workouts.length,
      logs: history.length,
      settings: settings,
    );
  }
}

class BackupImportResult {
  final int workouts;
  final int logs;
  final Map<String, Object?> settings;

  const BackupImportResult({
    required this.workouts,
    required this.logs,
    required this.settings,
  });
}
