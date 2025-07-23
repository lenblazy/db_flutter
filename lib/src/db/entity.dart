abstract class Entity {
  /// Serialize the entity to a map for DB operations
  Map<String, Object?> toMap();

  /// Return the primary key value (used for get/update/delete)
  Object get primaryKeyValue;

  /// Default primary key column name
  String get primaryKeyColumn => "id";
}
