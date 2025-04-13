import 'dart:async';

abstract class DbDao {
  Future<void> insert(Map<String, Object?> data);
  Future<List<Map<String, Object?>>> retrieve(String fromTable);
  Future<void> update(Map<String, Object?>  data);
  Future<void> delete(String fromTable);
}
