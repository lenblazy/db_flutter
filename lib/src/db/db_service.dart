import "dart:async";

abstract class DbService {
  Future<void> insert(String table, Map<String, Object?> data);
  Future<List<Map<String, Object?>>> retrieve(String fromTable);
  Future<void> update(String table, Map<String, Object?> data);
  Future<void> delete(String itemID, String table);
  Future<void> clear(String table);
}
