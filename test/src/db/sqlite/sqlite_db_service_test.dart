import "package:db_flutter/src/db/sqlite/sqlite_db.dart";
import "package:db_flutter/src/db/sqlite/sqlite_db_service.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:sqflite_common/sqlite_api.dart";

class MockSqliteDb extends Mock implements SqliteDb {}

class MockDatabase extends Mock implements Database {}

void main() {
  late SqliteDbService sut;
  late MockSqliteDb mockSqliteDb;
  late MockDatabase mockDatabase;

  setUp(() {
    mockSqliteDb = MockSqliteDb();
    mockDatabase = MockDatabase();
    sut = SqliteDbService(appDb: mockSqliteDb);

    when(() => mockSqliteDb.database).thenAnswer((_) async => mockDatabase);
  });

  group("SqliteDbDao", () {
    test("insert calls insert on the database", () async {
      const table = "test_table";
      final data = {"key": "value"};

      when(() => mockDatabase.insert(table, data)).thenAnswer((_) async => 1);

      await sut.insert(table, data);

      verify(() => mockDatabase.insert(table, data)).called(1);
    });

    test("update calls update on the database", () async {
      const table = "test_table";
      final data = {"key": "updatedValue"};

      when(() => mockDatabase.update(table, data)).thenAnswer((_) async => 1);

      await sut.update(table, data);

      verify(() => mockDatabase.update(table, data)).called(1);
    });

    test("delete calls delete on the database with correct args", () async {
      const table = "test_table";
      const id = "123";

      when(
        () =>
            mockDatabase.delete(table, where: "columnId = ?", whereArgs: [id]),
      ).thenAnswer((_) async => 1);

      await sut.delete(id, table);

      verify(
        () =>
            mockDatabase.delete(table, where: "columnId = ?", whereArgs: [id]),
      ).called(1);
    });

    test("retrieve calls query on the database", () async {
      const table = "test_table";
      final fakeData = [
        {"key": "value"},
      ];

      when(() => mockDatabase.query(table)).thenAnswer((_) async => fakeData);

      final result = await sut.retrieve(table);

      expect(result, fakeData);
      verify(() => mockDatabase.query(table)).called(1);
    });

    test("clear calls delete on the database without where clause", () async {
      const table = "test_table";

      when(() => mockDatabase.delete(table)).thenAnswer((_) async => 1);

      final result = await sut.clear(table);

      expect(result, 1);
      verify(() => mockDatabase.delete(table)).called(1);
    });
  });
}
