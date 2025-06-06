import "package:db_flutter/src/db/db_constants.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class AppDatabase {
  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, DbConstants.dbName);
    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: (Database db, int version) async {
        await db.execute(DbConstants.queryCreateTblSample);
        await db.execute(DbConstants.queryCreateTblSampleRef);
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     await _migrateToVersion2(db);
      //   }
      // },
    );
  }

  // Future<void> _migrateToVersion2(Database db) async {
  // await db.execute(DbConstants.queryCreateTblUser);
  // }
}
