import "package:db_flutter/db.dart";
import "package:db_flutter/src/db/dao/sqlite_db_dao.dart";
import "package:db_flutter/src/db/db_constants.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:sqflite/sqflite.dart";

import "sqlite_db_dao_test.mocks.dart";

@GenerateMocks(<Type>[AppDatabase, Database])
void main() {
  late SqliteDbDao sut;
  late MockAppDatabase mockAppDatabase;
  late MockDatabase mockDatabase;

  setUp(() {
    mockAppDatabase = MockAppDatabase();
    mockDatabase = MockDatabase();
    when(mockAppDatabase.database).thenAnswer((_) async => mockDatabase);
    sut = SqliteDbDao(appDb: mockAppDatabase);
  });

  group("SqliteDbDao", () {
    test("insert() inserts data into tblSample", () async {
      final Map<String, Object> sampleData = <String, Object>{
        "id": 1,
        "name": "Test",
      };
      when(
        mockDatabase.insert(DbConstants.tblSample, sampleData),
      ).thenAnswer((_) async => 1);

      await sut.insert(sampleData);

      verify(mockDatabase.insert(DbConstants.tblSample, sampleData)).called(1);
    });

    test("update() updates data in tblSample", () async {
      final Map<String, Object> updatedData = <String, Object>{
        "id": 1,
        "name": "Updated",
      };
      when(
        mockDatabase.update(DbConstants.tblSample, updatedData),
      ).thenAnswer((_) async => 1);

      await sut.update(updatedData);

      verify(mockDatabase.update(DbConstants.tblSample, updatedData)).called(1);
    });

    test("delete() deletes data from specified table", () async {
      const String tableName = "test_table";
      when(mockDatabase.delete(tableName)).thenAnswer((_) async => 1);

      await sut.delete(tableName);

      verify(mockDatabase.delete(tableName)).called(1);
    });

    test("retrieve() queries and returns data from specified table", () async {
      const String tableName = "test_table";
      final List<Map<String, Object>> queryResult = <Map<String, Object>>[
        <String, Object>{"id": 1, "name": "Item1"},
      ];

      when(mockDatabase.query(tableName)).thenAnswer((_) async => queryResult);

      final List<Map<String, Object?>> result = await sut.retrieve(tableName);

      expect(result, queryResult);
      verify(mockDatabase.query(tableName)).called(1);
    });
  });
}
