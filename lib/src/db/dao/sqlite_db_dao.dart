import "package:db_flutter/src/db/app_database.dart";
import "package:db_flutter/src/db/dao/db_dao.dart";
import "package:db_flutter/src/db/db_constants.dart";
import "package:sqflite_common/sqlite_api.dart";

class SqliteDbDao extends DbDao {
  SqliteDbDao({required AppDatabase appDb}) : _appDb = appDb;

  final AppDatabase _appDb;

  @override
  Future<void> delete(String fromTable) async {
    final Database db = await _appDb.database;
    await db.delete(fromTable);
  }

  @override
  Future<void> insert(Map<String, Object?> data) async {
    final Database db = await _appDb.database;
    await db.insert(DbConstants.tblSample, data);
  }

  @override
  Future<void> update(Map<String, Object?> data) async {
    final Database db = await _appDb.database;
    await db.update(DbConstants.tblSample, data);
  }

  @override
  Future<List<Map<String, Object?>>> retrieve(String fromTable) async {
    final Database db = await _appDb.database;
    return db.query(fromTable);
  }
}
