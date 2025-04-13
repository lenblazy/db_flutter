import 'package:db_flutter/db.dart';
import 'package:db_flutter/src/db/dao/sqlite_db_dao.dart';
import 'package:injectable/injectable.dart';

import '../db/dao/db_dao.dart';

@module
abstract class DbModule {
  @lazySingleton
  AppDatabase appDatabase() => AppDatabase();

  @lazySingleton
  DbDao dao(AppDatabase appDb) => SqliteDbDao(appDb: appDb);
}
