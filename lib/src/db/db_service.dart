import "dart:async";

import "entity.dart";
import "query_provider.dart";

abstract class DbService {
  /// Inserts an entity using its provider
  Future<int> insert<T extends Entity>(QueryProvider<T> query, T entity);

  /// Retrieves a list of entities based on provider constraints
  Future<List<T>> retrieve<T extends Entity>(QueryProvider<T> query);

  /// Retrieves a list of entities based on provider constraints
  Future<T?> getById<T extends Entity>(QueryProvider<T> query);

  /// Updates an entity using its primary key from the provider
  Future<bool> update<T extends Entity>(QueryProvider<T> query, T entity);

  /// Deletes an entity by ID from the provider
  Future<bool> delete<T extends Entity>(QueryProvider<T> query);

  /// Clears all rows matching a given query (or full table)
  Future<bool> clear<T extends Entity>(QueryProvider<T> query);
}
