import '../app_database.dart';
import '../db_constants.dart';
import 'db_dao.dart';

class SqliteDbDao extends DbDao {
  SqliteDbDao({required AppDatabase appDb}) : _appDb = appDb;

  final AppDatabase _appDb;

  @override
  Future<void> delete(String fromTable) async {
    final db = await _appDb.database;
    await db.delete(fromTable);
  }

  @override
  Future<void> insert(Map<String, Object?> data) async {
    final db = await _appDb.database;
    await db.insert(DbConstants.tblSample, data);
  }

  @override
  Future<void> update(Map<String, Object?> data) async {
    final db = await _appDb.database;
    await db.update(DbConstants.tblSample, data);
  }

  @override
  Future<List<Map<String, Object?>>> retrieve(String fromTable) async {
    final db = await _appDb.database;
    return await db.query(fromTable);
  }
}
