import "dart:async";

import "package:sqflite/sqflite.dart";

import "../db_service.dart";
import "../query_provider.dart";

class SqliteDbService extends DbService {
  SqliteDbService(this.db);

  final Database db;

  @override
  Future<bool> delete(QueryProvider query) async {
    return await db.delete(
          query.table,
          where: "${query.column} = ?",
          whereArgs: <Object?>[query.itemID],
        ) ==
        1;
  }

  @override
  Future<int> insert(QueryProvider query) async {
    return db.insert(query.table, query.data.toMap());
  }

  @override
  Future<bool> update(QueryProvider query) async {
    return await db.update(
          query.table,
          query.data.toMap(),
          where: "${query.column} = ?",
          whereArgs: <Object?>[query.itemID],
        ) ==
        1;
  }

  @override
  Future<List<Map<String, Object?>>> retrieve(QueryProvider query) async {
    return db.query(query.table);
  }

  @override
  Future<bool> clear(QueryProvider query) async {
    return await db.delete(query.table) == 1;
  }
}
