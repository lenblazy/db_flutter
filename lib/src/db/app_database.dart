import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'db_constants.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.dbName);
    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: (db, version) async {
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