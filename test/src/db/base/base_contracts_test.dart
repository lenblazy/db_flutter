import "package:db_flutter/db.dart";
import "package:db_flutter/src/db/base/db_constants.dart";
import "package:db_flutter/src/db/base/entity.dart";
import "package:db_flutter/src/db/base/query_provider.dart";
import "package:db_flutter/src/di/injector.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("barrel exports and injector init remain accessible", () {
    DbService? service;

    expect(service, isNull);
    expect(() => initDbPackage(), returnsNormally);
  });

  test("Entity exposes the default primary key column", () {
    final entity = _ExampleEntity();

    expect(entity.primaryKeyColumn, "id");
    expect(entity.primaryKeyValue, 1);
    expect(entity.toMap(), {"id": 1});
  });

  test("QueryProvider exposes the default optional clauses", () {
    final provider = _ExampleQueryProvider();

    expect(provider.table, "Example");
    expect(provider.itemID, 1);
    expect(provider.column, "id");
    expect(provider.conflictColumns, ["id"]);
    expect(provider.where, isNull);
    expect(provider.sql, isNull);
    expect(provider.args, isEmpty);
    expect(provider.whereArgs, isEmpty);
    expect(provider.orderBy, isNull);
    expect(provider.limit, isNull);
    expect(provider.fromMap({"id": 1}), isA<_ExampleEntity>());
  });

  test("DbConstants exposes the configured database metadata", () {
    expect(DbConstants.dbName, "sample_db.db");
    expect(DbConstants.dbVersion, 1);
  });
}

class _ExampleEntity extends Entity {
  @override
  Object get primaryKeyValue => 1;

  @override
  Map<String, Object?> toMap() => {"id": 1};
}

class _ExampleQueryProvider with QueryProvider<_ExampleEntity> {
  @override
  String get table => "Example";

  @override
  Object get itemID => 1;

  @override
  _ExampleEntity fromMap(Map<String, dynamic> map) => _ExampleEntity();
}
