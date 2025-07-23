import "entity.dart";

mixin QueryProvider<T extends Entity> {
  /// Table to query
  String get table;

  /// ID to filter on (e.g., for getById)
  Object get itemID;

  /// Column to match itemID against (defaults to primary key)
  String get column => "id";

  /// Converts a row map into an entity
  T fromMap(Map<String, Object?> map);

  /// Optional WHERE clause (e.g., 'isActive = ?')
  String? get where => null;

  /// Optional arguments for [where] clause
  List<Object?>? get whereArgs => null;

  /// Optional ORDER BY clause
  String? get orderBy => null;

  /// Optional LIMIT clause
  int? get limit => null;
}
