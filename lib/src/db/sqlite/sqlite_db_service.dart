import "dart:async";

import "package:db_flutter/src/db/db_service.dart";
import "package:db_flutter/src/db/sqlite/sqlite_db.dart";
import "package:sqflite_common/sqlite_api.dart";

class SqliteDbService extends DbService {
  SqliteDbService({required SqliteDb appDb}) : _appDb = appDb;

  final SqliteDb _appDb;

  @override
  Future<void> delete(String itemID, String fromTable) async {
    final Database db = await _appDb.database;
    await db.delete(fromTable, where: "columnId = ?", whereArgs: [itemID]);
  }

  @override
  Future<void> insert(String table, Map<String, Object?> data) async {
    final Database db = await _appDb.database;
    await db.insert(table, data);
  }

  @override
  Future<void> update(String table, Map<String, Object?> data) async {
    final Database db = await _appDb.database;
    await db.update(table, data);
  }

  @override
  Future<List<Map<String, Object?>>> retrieve(String fromTable) async {
    final Database db = await _appDb.database;
    return db.query(fromTable);
  }

  @override
  Future<int> clear(String table) async {
    final Database db = await _appDb.database;
    return db.delete(table);
  }
}
