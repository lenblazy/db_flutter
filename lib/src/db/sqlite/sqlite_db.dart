import "package:db_flutter/src/db/db_constants.dart";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class SqliteDb {
  factory SqliteDb() {
    return _instance;
  }

  SqliteDb._internal();

  static final SqliteDb _instance = SqliteDb._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, DbConstants.dbName);
    return openDatabase(path, version: DbConstants.dbVersion);
  }
}
