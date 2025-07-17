import "package:injectable/injectable.dart";

import "../../db.dart";
import "../db/sqlite/sqlite_db.dart";
import "../db/sqlite/sqlite_db_service.dart";

// coverage:ignore-file
@module
abstract class DbModule {
  @lazySingleton
  SqliteDb sqliteDb() => SqliteDb();

  @lazySingleton
  DbService dbService(SqliteDb db) => SqliteDbService(appDb: db);
}

// coverage:ignore-end
