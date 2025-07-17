import "dart:async";

import "query_provider.dart";

abstract class DbService {
  Future<bool> insert(QueryProvider query);
  Future<List<Map<String, Object?>>> retrieve(QueryProvider query);
  Future<bool> update(QueryProvider query);
  Future<bool> delete(QueryProvider query);
  Future<bool> clear(QueryProvider query);
}
