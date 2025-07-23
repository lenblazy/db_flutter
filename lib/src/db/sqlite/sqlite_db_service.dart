import "dart:async";

import "package:sqflite/sqflite.dart";

import "../db_service.dart";
import "../entity.dart";
import "../query_provider.dart";

class SqliteDbService implements DbService {
  const SqliteDbService(this.db);
  final Database db;

  @override
  Future<int> insert<T extends Entity>(QueryProvider<T> query, T entity) async {
    return db.insert(query.table, entity.toMap());
  }

  @override
  Future<List<T>> retrieve<T extends Entity>(QueryProvider<T> query) async {
    final result = await db.query(
      query.table,
      where: query.where,
      whereArgs: query.whereArgs,
      orderBy: query.orderBy,
      limit: query.limit,
    );
    return result.map(query.fromMap).toList();
  }

  @override
  Future<T?> getById<T extends Entity>(QueryProvider<T> query) async {
    final result = await db.query(
      query.table,
      where: "${query.column} = ?",
      whereArgs: [query.itemID],
      limit: 1,
    );
    return result.isEmpty ? null : query.fromMap(result.first);
  }

  @override
  Future<bool> update<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    final count = await db.update(
      query.table,
      entity.toMap(),
      where: "${entity.primaryKeyColumn} = ?",
      whereArgs: [entity.primaryKeyValue],
    );
    return count > 0;
  }

  @override
  Future<bool> delete<T extends Entity>(QueryProvider<T> query) async {
    final count = await db.delete(
      query.table,
      where: "${query.column} = ?",
      whereArgs: [query.itemID],
    );
    return count > 0;
  }

  @override
  Future<bool> clear<T extends Entity>(QueryProvider<T> query) async {
    return await db.delete(query.table) > 0;
  }
}
