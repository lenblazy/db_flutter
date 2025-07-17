import "package:db_flutter/src/db/sqlite/sqlite_db_service.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  late SqliteDbService sut;
  // late MockAppDatabase mockAppDatabase;
  // late MockDatabase mockDatabase;

  setUp(() {
    // mockAppDatabase = MockAppDatabase();
    // mockDatabase = MockDatabase();
    // when(mockAppDatabase.database).thenAnswer((_) async => mockDatabase);
    // sut = SqliteDbDao(appDb: mockAppDatabase);
  });

  group("SqliteDbDao", () {
    //   test("insert() inserts data into tblSample", () async {
    //     final Map<String, Object> sampleData = <String, Object>{
    //       "id": 1,
    //       "name": "Test",
    //     };
    //     when(
    //       mockDatabase.insert(DbConstants.tblSample, sampleData),
    //     ).thenAnswer((_) async => 1);
    //
    //     await sut.insert(sampleData);
    //
    //     verify(mockDatabase.insert(DbConstants.tblSample, sampleData)).called(1);
    //   });
    //
    //   test("update() updates data in tblSample", () async {
    //     final Map<String, Object> updatedData = <String, Object>{
    //       "id": 1,
    //       "name": "Updated",
    //     };
    //     when(
    //       mockDatabase.update(DbConstants.tblSample, updatedData),
    //     ).thenAnswer((_) async => 1);
    //
    //     await sut.update(updatedData);
    //
    //     verify(mockDatabase.update(DbConstants.tblSample, updatedData)).called(1);
    //   });
    //
    //   test("delete() deletes data from specified table", () async {
    //     const String tableName = "test_table";
    //     when(mockDatabase.delete(tableName)).thenAnswer((_) async => 1);
    //
    //     await sut.delete(tableName);
    //
    //     verify(mockDatabase.delete(tableName)).called(1);
    //   });
    //
    //   test("retrieve() queries and returns data from specified table", () async {
    //     const String tableName = "test_table";
    //     final List<Map<String, Object>> queryResult = <Map<String, Object>>[
    //       <String, Object>{"id": 1, "name": "Item1"},
    //     ];
    //
    //     when(mockDatabase.query(tableName)).thenAnswer((_) async => queryResult);
    //
    //     final List<Map<String, Object?>> result = await sut.retrieve(tableName);
    //
    //     expect(result, queryResult);
    //     verify(mockDatabase.query(tableName)).called(1);
    //   });
  });
}
