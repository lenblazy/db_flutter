import "dart:async";

import "package:core_flutter/core.dart" show AppLogger, DBException;
import "package:sqflite/sqflite.dart";

import "../base/entity.dart";
import "../base/query_provider.dart";
import "../service/db_service.dart";

class SqliteDbService implements DbService {
  SqliteDbService(this.db);

  final Database db;

  // Stream controller for broadcasting table changes
  final _changeController = StreamController<String>.broadcast();

  // Cache of last known results to prevent duplicate emissions
  final _lastResults = <String, List<Map<String, dynamic>>>{};

  @override
  Future<bool> insert<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    try {
      final isSuccessful = await db.insert(query.table, entity.toMap()) > 0;
      if (isSuccessful) _changeController.add(query.table);
      return isSuccessful;
    } catch (e, stackTrace) {
      await AppLogger.logError(error: e, stackTrace: stackTrace);
      throw _mapDbWriteException(
        e,
        stackTrace,
        table: query.table,
        action: "insert",
      );
    }
  }

  @override
  Future<List<T>> retrieve<T extends Entity>(QueryProvider<T> query) async {
    try {
      final result = await db.query(
        query.table,
        where: query.where,
        whereArgs: query.whereArgs,
        orderBy: query.orderBy,
        limit: query.limit,
      );
      return result.map(query.fromMap).toList();
    } catch (e, stackTrace) {
      await AppLogger.logError(error: e, stackTrace: stackTrace);
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to retrieve data from ${query.table}",
      );
    }
  }

  @override
  Future<List<T>> retrieveRaw<T extends Entity>(QueryProvider<T> query) async {
    try {
      final result = await db.rawQuery(query.sql!, query.args);
      return result.map(query.fromMap).toList();
    } catch (e, stackTrace) {
      await AppLogger.logError(error: e, stackTrace: stackTrace);
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to retrieve raw data from ${query.table}",
      );
    }
  }

  @override
  Future<T?> getById<T extends Entity>(QueryProvider<T> query) async {
    try {
      final result = await db.query(
        query.table,
        where: "${query.column} = ?",
        whereArgs: [query.itemID],
        limit: 1,
      );
      return result.isEmpty ? null : query.fromMap(result.first);
    } catch (e, stackTrace) {
      await AppLogger.logError(error: e, stackTrace: stackTrace);
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to retrieve ${query.table} by id",
      );
    }
  }

  @override
  Future<bool> update<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    final isSuccessful =
        await db.update(
          query.table,
          entity.toMap(),
          where: "${entity.primaryKeyColumn} = ?",
          whereArgs: [entity.primaryKeyValue],
        ) >
        0;

    if (isSuccessful) _notifyTableChange(query.table);
    return isSuccessful;
  }

  @override
  Future<bool> delete<T extends Entity>(QueryProvider<T> query) async {
    final isDeleted =
        await db.delete(
          query.table,
          where: "${query.column} = ?",
          whereArgs: [query.itemID],
        ) >
        0;
    if (isDeleted) _notifyTableChange(query.table);
    return isDeleted;
  }

  @override
  Future<bool> clear<T extends Entity>(QueryProvider<T> query) async {
    final isCleared = await db.delete(query.table) > 0;
    if (isCleared) _notifyTableChange(query.table);
    return isCleared;
  }

  @override
  Future<void> runInTransaction(
    Future<void> Function(DbService txn) action,
  ) async {
    final changedTables = <String>{};

    await db.transaction((txnDb) async {
      await action(_TxnInline(txnDb, changedTables.add));
    });

    // Notify after transaction completes
    for (final table in changedTables) {
      _notifyTableChange(table);
    }
  }

  @override
  Future<bool> upsert<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    return db.transaction((txn) async {
      final map = entity.toMap();
      final conflictColumns = query.conflictColumns;

      if (conflictColumns.isEmpty) {
        throw Exception(
          "conflictColumns cannot be empty for table ${query.table}",
        );
      }

      final whereClause = conflictColumns
          .map((column) => "$column = ?")
          .join(" AND ");

      final whereArgs = conflictColumns.map((column) => map[column]).toList();

      final exists =
          await txn.update(
            query.table,
            map,
            where: whereClause,
            whereArgs: whereArgs,
          ) >
          0;

      if (exists) {
        _notifyTableChange(query.table);
        return true;
      }

      final isInserted = await txn.insert(query.table, map) > 0;
      if (isInserted) _notifyTableChange(query.table);
      return isInserted;
    });
  }

  @override
  Stream<List<T>> watchRawQuery<T extends Entity>(QueryProvider<T> query) {
    // Create a unique key for raw query caching
    final cacheKey = 'raw_${query.sql}_${query.args.join(',')}';

    return _changeController.stream
        .asyncMap((_) => _rawQueryWithCache(query, cacheKey))
        .where((results) => results.isNotEmpty)
        .map((results) => results.map(query.fromMap).toList())
        .asBroadcastStream();
  }

  @override
  Stream<List<T>> watchTable<T extends Entity>(QueryProvider<T> query) async* {
    AppLogger.log("📺 Starting watchTable for ${query.table}");

    final initialData = await _fetchTableRows(query);

    AppLogger.log("📺 Initial data: ${initialData.length} rows");
    yield initialData.map(query.fromMap).toList();

    await for (final table in _changeController.stream) {
      AppLogger.log("📺 Table changed: $table");
      if (table == query.table) {
        final newData = await _fetchTableRows(query);

        AppLogger.log("📺 Emitting new data: ${newData.length} rows");
        yield newData.map(query.fromMap).toList();
      }
    }
  }

  Future<List<Map<String, Object?>>> _fetchTableRows<T extends Entity>(
    QueryProvider<T> query,
  ) async {
    try {
      return await db.query(
        query.table,
        where: query.where,
        whereArgs: query.whereArgs,
        orderBy: query.orderBy,
        limit: query.limit,
      );
    } catch (e, stackTrace) {
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to watch data from ${query.table}",
      );
    }
  }

  // Helper methods
  void _notifyTableChange(String tableName) {
    _changeController.add(tableName);
    AppLogger.log("_notifyTableChange $tableName");
  }

  Future<List<Map<String, dynamic>>> _rawQueryWithCache<T extends Entity>(
    QueryProvider<T> query,
    String cacheKey,
  ) async {
    final results = await _fetchRawRows(query);

    if (_hasDataChanged(cacheKey, results)) {
      _lastResults[cacheKey] = results;
      return results;
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchRawRows<T extends Entity>(
    QueryProvider<T> query,
  ) async {
    try {
      return await db.rawQuery(query.sql!, query.args);
    } catch (e, stackTrace) {
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to watch raw data from ${query.table}",
      );
    }
  }

  bool _hasDataChanged(String cacheKey, List<Map<String, dynamic>> newResults) {
    final lastResult = _lastResults[cacheKey];
    if (lastResult == null) return true;

    // Simple comparison - you might want more sophisticated change detection
    if (lastResult.length != newResults.length) return true;

    // Compare each row (simplified)
    for (var i = 0; i < newResults.length; i++) {
      if (!_mapsEqual(lastResult[i], newResults[i])) {
        return true;
      }
    }

    return false;
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  Future<void> dispose() async {
    await _changeController.close();
  }
}

/// Minimal inline transaction handler
class _TxnInline implements DbService {
  _TxnInline(this.txnDb, this.onTableChanged);

  final DatabaseExecutor txnDb;
  final void Function(String table) onTableChanged;

  @override
  Future<void> runInTransaction(
    Future<void> Function(DbService txn) action,
  ) async {
    await action(this);
  }

  @override
  Future<bool> insert<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    try {
      final isSuccessful = await txnDb.insert(query.table, entity.toMap()) > 0;
      if (isSuccessful) onTableChanged(query.table);
      return isSuccessful;
    } catch (e, stackTrace) {
      throw _mapDbWriteException(
        e,
        stackTrace,
        table: query.table,
        action: "insert",
      );
    }
  }

  @override
  Future<bool> update<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    final isSuccessful =
        await txnDb.update(
          query.table,
          entity.toMap(),
          where: "${entity.primaryKeyColumn} = ?",
          whereArgs: [entity.primaryKeyValue],
        ) >
        0;
    if (isSuccessful) onTableChanged(query.table);
    return isSuccessful;
  }

  @override
  Future<List<T>> retrieve<T extends Entity>(QueryProvider<T> query) async {
    try {
      final result = await txnDb.query(
        query.table,
        where: query.where,
        whereArgs: query.whereArgs,
        orderBy: query.orderBy,
        limit: query.limit,
      );
      return result.map(query.fromMap).toList();
    } catch (e, stackTrace) {
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to retrieve data from ${query.table}",
      );
    }
  }

  @override
  Future<T?> getById<T extends Entity>(QueryProvider<T> query) async {
    try {
      final result = await txnDb.query(
        query.table,
        where: "${query.column} = ?",
        whereArgs: [query.itemID],
        limit: 1,
      );
      return result.isEmpty ? null : query.fromMap(result.first);
    } catch (e, stackTrace) {
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to retrieve ${query.table} by id",
      );
    }
  }

  @override
  Future<bool> delete<T extends Entity>(QueryProvider<T> query) async {
    final isDeleted =
        await txnDb.delete(
          query.table,
          where: "${query.column} = ?",
          whereArgs: [query.itemID],
        ) >
        0;
    if (isDeleted) onTableChanged(query.table);
    return isDeleted;
  }

  @override
  Future<bool> clear<T extends Entity>(QueryProvider<T> query) async {
    final isCleared = await txnDb.delete(query.table) > 0;
    if (isCleared) onTableChanged(query.table);
    return isCleared;
  }

  @override
  Future<List<T>> retrieveRaw<T extends Entity>(QueryProvider<T> query) async {
    try {
      final result = await txnDb.rawQuery(query.sql!, query.args);
      return result.map(query.fromMap).toList();
    } catch (e, stackTrace) {
      throw _mapDbFetchException(
        e,
        stackTrace,
        message: "Failed to retrieve raw data from ${query.table}",
      );
    }
  }

  @override
  Future<bool> upsert<T extends Entity>(
    QueryProvider<T> query,
    T entity,
  ) async {
    final map = entity.toMap();
    final conflictColumns = query.conflictColumns;

    if (conflictColumns.isEmpty) {
      throw Exception(
        "conflictColumns cannot be empty for table ${query.table}",
      );
    }

    final whereClause = conflictColumns
        .map((column) => "$column = ?")
        .join(" AND ");

    final whereArgs = conflictColumns.map((column) => map[column]).toList();

    final updateCount = await txnDb.update(
      query.table,
      map,
      where: whereClause,
      whereArgs: whereArgs,
    );

    if (updateCount > 0) {
      onTableChanged(query.table);
      return true;
    }

    final id = await txnDb.insert(query.table, map);
    if (id > 0) {
      onTableChanged(query.table);
    }
    return id > 0;
  }

  @override
  Stream<List<T>> watchRawQuery<T extends Entity>(QueryProvider<T> query) {
    throw UnsupportedError("Streaming not supported in transactions");
  }

  @override
  Stream<List<T>> watchTable<T extends Entity>(QueryProvider<T> query) {
    throw UnsupportedError("Streaming not supported in transactions");
  }
}

/// Util functions

DBException _mapDbFetchException(
  Object error,
  StackTrace stackTrace, {
  required String message,
}) {
  if (error case final DBException exception) {
    return exception;
  }

  if (error case final DatabaseException exception) {
    return DBException(
      message: message,
      cause: exception,
      stackTrace: stackTrace,
    );
  }

  return DBException(message: message, cause: error, stackTrace: stackTrace);
}

DBException _mapDbWriteException(
  Object error,
  StackTrace stackTrace, {
  required String table,
  required String action,
}) {
  if (error case final DBException exception) {
    return exception;
  }

  if (error case final DatabaseException exception) {
    final message = exception.toString();
    if (message.contains("UNIQUE constraint failed: ")) {
      return DBException(
        message: "A duplicate record already exists.",
        cause: exception,
        stackTrace: stackTrace,
      );
    }

    return DBException(
      message: "Failed to $action data in $table",
      cause: exception,
      stackTrace: stackTrace,
    );
  }

  return DBException(
    message: "Failed to $action data in $table",
    cause: error,
    stackTrace: stackTrace,
  );
}
