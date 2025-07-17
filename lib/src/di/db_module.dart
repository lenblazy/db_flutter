import "package:injectable/injectable.dart";
import "package:path/path.dart";
import "package:sqflite_common/sqflite.dart";

import "../../db.dart";
import "../db/db_constants.dart";
import "../db/sqlite/sqlite_db_service.dart";

// coverage:ignore-file
@module
abstract class DbModule {
  @lazySingleton
  Future<DbService> dbService() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, DbConstants.dbName);
    final Database db = await openDatabase(
      path,
      version: DbConstants.dbVersion,
    );
    return SqliteDbService(db);
  }
}

// coverage:ignore-end
