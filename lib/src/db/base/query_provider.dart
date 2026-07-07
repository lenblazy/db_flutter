import "entity.dart";

mixin QueryProvider<T extends Entity> {
  /// Table to query
  String get table;

  /// ID to filter on (e.g., for getById)
  Object get itemID;

  /// Column to match itemID against (defaults to primary key)
  String get column => "id";

  /// Composite conflict keys
  List<String> get conflictColumns => [column];

  /// Converts a row map into an entity
  T fromMap(Map<String, dynamic> map);

  /// Optional WHERE clause (e.g., 'isActive = ?')
  String? get where => null;

  String? get sql => null;

  List<Object?> get args => [];

  /// Optional arguments for [where] clause
  List<Object?> get whereArgs => [];

  /// Optional ORDER BY clause
  String? get orderBy => null;

  /// Optional LIMIT clause
  int? get limit => null;
}
