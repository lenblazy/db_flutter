import "package:db_flutter/db.dart";
import "package:db_flutter/src/db/sqlite/sqlite_db.dart";
import "package:db_flutter/src/db/sqlite/sqlite_db_service.dart";
import "package:injectable/injectable.dart";

// coverage:ignore-file
@module
abstract class DbModule {
  @lazySingleton
  SqliteDb sqliteDb() => SqliteDb();

  @lazySingleton
  DbService dbService(SqliteDb db) => SqliteDbService(appDb: db);
}

// coverage:ignore-end
