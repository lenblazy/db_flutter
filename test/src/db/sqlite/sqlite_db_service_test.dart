import "package:db_flutter/src/db/sqlite/sqlite_db_service.dart";
import "package:flutter_test/flutter_test.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

import "helpers/helpers.dart";

void main() {
  late SqliteDbService sut;
  late Database db;

  setUpAll(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)",
          );
        },
      ),
    );

    sut = SqliteDbService(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  group("SqliteDbService Tests", () {
    test("insert inserts the entity into the database", () async {
      final entity = TestEntity(id: 1, name: "test");
      final provider = TestQueryProvider(entity.id);

      final result = await sut.insert(provider, entity);
      expect(result, 1);
    });

    test("retrieve returns entities mapped from database rows", () async {
      final entity = TestEntity(id: 2, name: "test");
      final provider = TestQueryProvider(entity.id);

      await sut.insert(provider, entity);

      final result = await sut.retrieve(provider);
      expect(result.first.name, "test");
    });

    test("update modifies an existing entity in the database", () async {
      final entity = TestEntity(id: 3, name: "old");
      final provider = FilteredQueryProvider(entity.id);
      await sut.insert(provider, entity);

      final updatedEntity = TestEntity(id: 3, name: "updated");
      final success = await sut.update(provider, updatedEntity);
      expect(success, isTrue);

      final result = await sut.retrieve(provider);
      expect(result.first.name, "updated");
    });

    test("delete removes a record from the database", () async {
      final entity = TestEntity(id: 4, name: "to-delete");
      final provider = FilteredQueryProvider(entity.id);
      await sut.insert(provider, entity);

      final deleted = await sut.delete(provider);
      expect(deleted, isTrue);

      final result = await sut.retrieve(provider);
      expect(result.isEmpty, true);
    });

    test("clear deletes all records in the table", () async {
      for (var i = 5; i < 8; i++) {
        final entity = TestEntity(id: i, name: "bulk");
        final provider = FilteredQueryProvider(i);
        await sut.insert(provider, entity);
      }

      final provider = TestQueryProvider(5); // Just to get `table` value
      final cleared = await sut.clear(provider);
      expect(cleared, isTrue);

      final remaining = await sut.retrieve(provider);
      expect(remaining.isEmpty, true);
    });

    test("retrieve returns empty list if no match found", () async {
      final provider = FilteredQueryProvider(999); // ID that doesn't exist
      final result = await sut.retrieve(provider);
      expect(result, isEmpty);
    });

    test("getById returns correct record using QueryProvider.column", () async {
      final entity = TestEntity(id: 100, name: "Exact Match");
      final provider = TestQueryProvider(100);
      await sut.insert(provider, entity);

      final result = await sut.getById(provider);
      expect(result?.name, "Exact Match");
    });

    test("insert and retrieve with different QueryProvider column", () async {
      final entity = TestEntity(id: 101, name: "Column Test");
      final provider = FilteredQueryProvider(101);
      await sut.insert(provider, entity);

      final result = await sut.retrieve(provider);
      expect(result.first.name, "Column Test");
    });
  });
}
