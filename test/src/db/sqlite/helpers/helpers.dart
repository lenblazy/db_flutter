import "package:db_flutter/src/db/entity.dart";
import "package:db_flutter/src/db/query_provider.dart";

class TestEntity extends Entity {
  TestEntity({required this.id, required this.name});
  final int id;
  final String name;

  @override
  Map<String, Object?> toMap() => {"id": id, "name": name};

  @override
  int get primaryKeyValue => id;
}

class TestQueryProvider with QueryProvider<TestEntity> {
  TestQueryProvider(this.id);
  final int id;

  @override
  String get table => "Test";

  @override
  Object get itemID => id;

  @override
  TestEntity fromMap(Map<String, dynamic> map) {
    return TestEntity(id: map["id"], name: map["name"]);
  }
}

class FilteredQueryProvider with QueryProvider<TestEntity> {
  FilteredQueryProvider(this.id, {this.order});
  final int id;
  final String? order;

  @override
  String get table => "Test";

  @override
  Object get itemID => id;

  @override
  String get column => "id";

  @override
  String? get orderBy => order;

  @override
  int? get limit => 1;

  @override
  String? get where => "id = ?";

  @override
  List<Object?>? get whereArgs => [id];

  @override
  TestEntity fromMap(Map<String, dynamic> map) {
    return TestEntity(id: map["id"], name: map["name"]);
  }
}
