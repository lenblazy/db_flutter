import "dart:async";

import "../base/entity.dart";
import "../base/query_provider.dart";

abstract class DbService {
  /// Inserts an entity using its provider
  Future<bool> insert<T extends Entity>(QueryProvider<T> query, T entity);

  /// Retrieves a list of entities based on provider constraints
  Future<List<T>> retrieve<T extends Entity>(QueryProvider<T> query);

  Future<List<T>> retrieveRaw<T extends Entity>(QueryProvider<T> query);

  /// Retrieves a list of entities based on provider constraints
  Future<T?> getById<T extends Entity>(QueryProvider<T> query);

  /// Updates an entity using its primary key from the provider
  Future<bool> update<T extends Entity>(QueryProvider<T> query, T entity);

  /// Deletes an entity by ID from the provider
  Future<bool> delete<T extends Entity>(QueryProvider<T> query);

  /// Clears all rows matching a given query (or full table)
  Future<bool> clear<T extends Entity>(QueryProvider<T> query);

  /// Allow transaction processing
  Future<void> runInTransaction(Future<void> Function(DbService txn) action);

  /// Preventive insert to prevent duplication errors
  Future<bool> upsert<T extends Entity>(QueryProvider<T> query, T entity);

  /// Watch a table for changes and emit the current data whenever it changes
  Stream<List<T>> watchTable<T extends Entity>(QueryProvider<T> query);

  /// Watch a raw query for changes
  Stream<List<T>> watchRawQuery<T extends Entity>(QueryProvider<T> query);
}
