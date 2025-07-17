import "package:db_flutter/src/db/query_provider.dart";
import "package:db_flutter/src/db/sqlite/sqlite_db_service.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

class MockQueryProvider extends Mock implements QueryProvider {}

void main() {
  late SqliteDbService sut;
  late Database db;
  late MockQueryProvider mockQuery;

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

    mockQuery = MockQueryProvider();
    sut = SqliteDbService(db);
  });

  tearDownAll(() async {
    db.close();
  });

  group("SqliteDbService Tests", () {
    test("insert calls insert on the database", () async {
      when(() => mockQuery.table).thenReturn("Test");
      when(() => mockQuery.data).thenReturn(<String, String>{"name": "test"});

      bool result = await sut.insert(mockQuery);
      expect(result, true);
    });

    test("retrieve returns data from the database", () async {
      when(() => mockQuery.table).thenReturn("Test");
      when(() => mockQuery.data).thenReturn(<String, String>{"name": "test"});

      await sut.insert(mockQuery);
      final List<Map<String, Object?>> result = await sut.retrieve(mockQuery);

      expect(result.isNotEmpty, true);
    });

    test("update makes changes on a record on the database", () async {
      when(() => mockQuery.table).thenReturn("Test");
      when(() => mockQuery.data).thenReturn(<String, String>{"name": "test"});
      when(() => mockQuery.column).thenReturn("id");
      when(() => mockQuery.itemID).thenReturn("1");

      await sut.insert(mockQuery);
      await sut.insert(mockQuery);
      await sut.insert(mockQuery);
      List<Map<String, Object?>> oldResult = await sut.retrieve(mockQuery);
      expect(oldResult.first["name"], "test");

      when(
        () => mockQuery.data,
      ).thenReturn(<String, String>{"name": "updatedtest"});

      await sut.update(mockQuery);

      List<Map<String, Object?>> newResult = await sut.retrieve(mockQuery);
      expect(newResult.first["name"], "updatedtest");
    });

    test("delete removes a record on the database", () async {
      when(() => mockQuery.table).thenReturn("Test");
      when(() => mockQuery.data).thenReturn(<String, String>{"name": "test"});
      when(() => mockQuery.column).thenReturn("id");
      when(() => mockQuery.itemID).thenReturn("1");

      await sut.insert(mockQuery);
      await sut.insert(mockQuery);
      await sut.insert(mockQuery);
      List<Map<String, Object?>> oldResult = await sut.retrieve(mockQuery);

      expect(oldResult.first.values.contains(1), true);

      sut.delete(mockQuery);

      List<Map<String, Object?>> newResult = await sut.retrieve(mockQuery);
      expect(newResult.first.values.contains(1), false);
    });

    test("clear deletes all records on the database table", () async {
      when(() => mockQuery.table).thenReturn("Test");
      when(() => mockQuery.data).thenReturn(<String, String>{"name": "test"});

      await sut.insert(mockQuery);
      await sut.insert(mockQuery);
      await sut.insert(mockQuery);
      List<Map<String, Object?>> oldResult = await sut.retrieve(mockQuery);

      expect(oldResult.isNotEmpty, true);

      sut.clear(mockQuery);

      List<Map<String, Object?>> newResult = await sut.retrieve(mockQuery);
      expect(newResult.isEmpty, true);
    });
  });
}
