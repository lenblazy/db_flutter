import "dart:async";

import "package:core_flutter/core.dart" show DBException;
import "package:db_flutter/src/db/base/query_provider.dart";
import "package:db_flutter/src/db/sqlite/sqlite_db_service.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:sqflite/sqflite.dart" show DatabaseException;
import "package:sqflite_common/sqflite.dart";
import "package:sqflite_common/src/exception.dart";
import "package:sqflite_common_ffi/sqflite_ffi.dart";

import "helpers/helpers.dart";

class MockDatabase extends Mock implements Database {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteDbService sut;
  late Database db;

  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 25));

  setUpAll(sqfliteFfiInit);

  setUp(() async {
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

  tearDown(() async {
    await sut.dispose();
    await db.close();
  });

  group("SqliteDbService success paths", () {
    test("insert inserts the entity into the database", () async {
      final entity = TestEntity(id: 1, name: "test");
      final provider = TestQueryProvider(entity.id);

      final result = await sut.insert(provider, entity);

      expect(result, isTrue);
    });

    test("retrieve returns entities mapped from database rows", () async {
      final entity = TestEntity(id: 2, name: "test");
      final provider = TestQueryProvider(entity.id);

      await sut.insert(provider, entity);

      final result = await sut.retrieve(provider);

      expect(result.single.name, "test");
    });

    test("retrieve respects where, orderBy and limit", () async {
      for (final entity in [
        TestEntity(id: 3, name: "b"),
        TestEntity(id: 4, name: "a"),
      ]) {
        await sut.insert(FilteredQueryProvider(entity.id), entity);
      }

      final result = await sut.retrieve(
        FilteredQueryProvider(4, order: "name"),
      );

      expect(result.single.name, "a");
    });

    test("retrieveRaw returns entities mapped from a raw query", () async {
      final entity = TestEntity(id: 5, name: "raw");
      await sut.insert(TestQueryProvider(entity.id), entity);

      final result = await sut.retrieveRaw(
        RawTestQueryProvider(id: entity.id, queryArgs: [entity.id]),
      );

      expect(result.single.name, "raw");
    });

    test("getById returns null when no match is found", () async {
      final result = await sut.getById(TestQueryProvider(404));

      expect(result, isNull);
    });

    test("getById returns the matching record", () async {
      final entity = TestEntity(id: 6, name: "Exact Match");
      final provider = TestQueryProvider(entity.id);
      await sut.insert(provider, entity);

      final result = await sut.getById(provider);

      expect(result?.name, "Exact Match");
    });

    test("update modifies an existing entity in the database", () async {
      final entity = TestEntity(id: 7, name: "old");
      final provider = FilteredQueryProvider(entity.id);
      await sut.insert(provider, entity);

      final updatedEntity = TestEntity(id: 7, name: "updated");
      final success = await sut.update(provider, updatedEntity);
      final result = await sut.retrieve(provider);

      expect(success, isTrue);
      expect(result.single.name, "updated");
    });

    test("update returns false when no record matches", () async {
      final success = await sut.update(
        FilteredQueryProvider(999),
        TestEntity(id: 999, name: "missing"),
      );

      expect(success, isFalse);
    });

    test("delete removes a record from the database", () async {
      final entity = TestEntity(id: 8, name: "to-delete");
      final provider = FilteredQueryProvider(entity.id);
      await sut.insert(provider, entity);

      final deleted = await sut.delete(provider);
      final result = await sut.retrieve(provider);

      expect(deleted, isTrue);
      expect(result, isEmpty);
    });

    test("delete returns false when no record matches", () async {
      final deleted = await sut.delete(FilteredQueryProvider(999));

      expect(deleted, isFalse);
    });

    test("clear deletes all records in the table", () async {
      for (var i = 9; i < 12; i++) {
        await sut.insert(
          FilteredQueryProvider(i),
          TestEntity(id: i, name: "x"),
        );
      }

      final cleared = await sut.clear(TestQueryProvider(9));
      final remaining = await sut.retrieve(TestQueryProvider(9));

      expect(cleared, isTrue);
      expect(remaining, isEmpty);
    });

    test("clear returns false when the table is already empty", () async {
      final cleared = await sut.clear(TestQueryProvider(0));

      expect(cleared, isFalse);
    });

    test("upsert inserts when no existing row matches", () async {
      final success = await sut.upsert(
        TestQueryProvider(12),
        TestEntity(id: 12, name: "inserted"),
      );

      final result = await sut.getById(TestQueryProvider(12));
      expect(success, isTrue);
      expect(result?.name, "inserted");
    });

    test("upsert updates when an existing row matches", () async {
      await sut.insert(TestQueryProvider(13), TestEntity(id: 13, name: "old"));

      final success = await sut.upsert(
        TestQueryProvider(13),
        TestEntity(id: 13, name: "new"),
      );

      final result = await sut.getById(TestQueryProvider(13));
      expect(success, isTrue);
      expect(result?.name, "new");
    });

    test("upsert supports composite conflict columns", () async {
      final provider = CompositeConflictQueryProvider(14);
      await sut.insert(provider, TestEntity(id: 14, name: "same"));

      final success = await sut.upsert(
        provider,
        TestEntity(id: 14, name: "same"),
      );
      final result = await sut.getById(TestQueryProvider(14));

      expect(success, isTrue);
      expect(result?.name, "same");
    });

    test("runInTransaction executes nested database operations", () async {
      await sut.runInTransaction((txn) async {
        await txn.insert(TestQueryProvider(15), TestEntity(id: 15, name: "tx"));
        final retrieved = await txn.retrieve(TestQueryProvider(15));
        expect(retrieved.single.name, "tx");

        final insideTxn = await txn.getById(TestQueryProvider(15));
        expect(insideTxn?.name, "tx");

        final updated = await txn.update(
          TestQueryProvider(15),
          TestEntity(id: 15, name: "updated"),
        );
        expect(updated, isTrue);

        final rawResult = await txn.retrieveRaw(
          RawTestQueryProvider(id: 15, queryArgs: [15]),
        );
        expect(rawResult.single.name, "updated");

        final updatedUpsert = await txn.upsert(
          TestQueryProvider(15),
          TestEntity(id: 15, name: "updated-again"),
        );
        expect(updatedUpsert, isTrue);

        final upserted = await txn.upsert(
          TestQueryProvider(16),
          TestEntity(id: 16, name: "upserted"),
        );
        expect(upserted, isTrue);

        final deleted = await txn.delete(TestQueryProvider(16));
        expect(deleted, isTrue);

        final cleared = await txn.clear(TestQueryProvider(15));
        expect(cleared, isTrue);
      });

      final remaining = await sut.retrieve(TestQueryProvider(15));
      expect(remaining, isEmpty);
    });

    test("runInTransaction supports the inline DbService contract", () async {
      await sut.runInTransaction((txn) async {
        await txn.runInTransaction((nestedTxn) async {
          await nestedTxn.insert(
            TestQueryProvider(17),
            TestEntity(id: 17, name: "nested"),
          );
        });
      });

      final result = await sut.getById(TestQueryProvider(17));
      expect(result?.name, "nested");
    });
  });

  group("SqliteDbService streaming", () {
    test("watchTable emits the initial rows and later updates", () async {
      final events = <List<TestEntity>>[];
      final completer = Completer<void>();
      late StreamSubscription<List<TestEntity>> subscription;

      subscription = sut.watchTable(TestQueryProvider(0)).listen((value) async {
        events.add(value);
        if (events.length == 1) {
          await sut.insert(
            TestQueryProvider(18),
            TestEntity(id: 18, name: "watch"),
          );
        }

        if (events.length == 2 && !completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future.timeout(const Duration(seconds: 2));
      await subscription.cancel();

      expect(events[0], isEmpty);
      expect(events[1].single.name, "watch");
    });

    test("watchRawQuery emits only when the raw result changes", () async {
      final provider = RawTestQueryProvider(id: 19, queryArgs: [19]);
      final events = <List<TestEntity>>[];
      final subscription = sut.watchRawQuery(provider).listen(events.add);

      await sut.insert(
        TestQueryProvider(19),
        TestEntity(id: 19, name: "value"),
      );
      await pump();

      await sut.update(
        TestQueryProvider(19),
        TestEntity(id: 19, name: "value"),
      );
      await pump();

      await subscription.cancel();

      expect(events, hasLength(1));
      expect(events.single.single.name, "value");
    });
  });

  group("SqliteDbService failure mapping", () {
    test(
      "insert maps duplicate database errors to a friendly DBException",
      () async {
        final entity = TestEntity(id: 20, name: "dup");
        final provider = TestQueryProvider(entity.id);
        await sut.insert(provider, entity);

        final future = sut.insert(provider, entity);

        await expectLater(
          future,
          throwsA(
            isA<DBException>().having(
              (error) => error.message,
              "message",
              "A duplicate record already exists.",
            ),
          ),
        );
      },
    );

    test(
      "insert preserves DBException instances from the database layer",
      () async {
        final mockDb = MockDatabase();
        final service = SqliteDbService(mockDb);
        final expected = DBException(message: "db insert failure");

        when(
          () => mockDb.insert(
            any(),
            any(),
            nullColumnHack: any(named: "nullColumnHack"),
            conflictAlgorithm: any(named: "conflictAlgorithm"),
          ),
        ).thenThrow(expected);

        await expectLater(
          () => service.insert(
            TestQueryProvider(21),
            TestEntity(id: 21, name: "x"),
          ),
          throwsA(same(expected)),
        );

        await service.dispose();
      },
    );

    test("insert wraps non-unique DatabaseException failures", () async {
      final mockDb = MockDatabase();
      final service = SqliteDbService(mockDb);

      when(
        () => mockDb.insert(
          any(),
          any(),
          nullColumnHack: any(named: "nullColumnHack"),
          conflictAlgorithm: any(named: "conflictAlgorithm"),
        ),
      ).thenThrow(SqfliteDatabaseException("disk io error", null));

      await expectLater(
        () => service.insert(
          TestQueryProvider(22),
          TestEntity(id: 22, name: "x"),
        ),
        throwsA(
          isA<DBException>().having(
            (error) => error.message,
            "message",
            "Failed to insert data in Test",
          ),
        ),
      );

      await service.dispose();
    });

    test("insert wraps generic errors", () async {
      final mockDb = MockDatabase();
      final service = SqliteDbService(mockDb);

      when(
        () => mockDb.insert(
          any(),
          any(),
          nullColumnHack: any(named: "nullColumnHack"),
          conflictAlgorithm: any(named: "conflictAlgorithm"),
        ),
      ).thenThrow(Exception("boom"));

      await expectLater(
        () => service.insert(
          TestQueryProvider(23),
          TestEntity(id: 23, name: "x"),
        ),
        throwsA(
          isA<DBException>().having(
            (error) => error.message,
            "message",
            "Failed to insert data in Test",
          ),
        ),
      );

      await service.dispose();
    });

    test(
      "retrieve preserves DBException instances from the database layer",
      () async {
        final mockDb = MockDatabase();
        final service = SqliteDbService(mockDb);
        final expected = DBException(message: "db fetch failure");

        when(
          () => mockDb.query(
            any(),
            distinct: any(named: "distinct"),
            columns: any(named: "columns"),
            where: any(named: "where"),
            whereArgs: any(named: "whereArgs"),
            groupBy: any(named: "groupBy"),
            having: any(named: "having"),
            orderBy: any(named: "orderBy"),
            limit: any(named: "limit"),
            offset: any(named: "offset"),
          ),
        ).thenThrow(expected);

        await expectLater(
          () => service.retrieve(TestQueryProvider(24)),
          throwsA(same(expected)),
        );

        await service.dispose();
      },
    );

    test("retrieve wraps DatabaseException failures", () async {
      final mockDb = MockDatabase();
      final service = SqliteDbService(mockDb);

      when(
        () => mockDb.query(
          any(),
          distinct: any(named: "distinct"),
          columns: any(named: "columns"),
          where: any(named: "where"),
          whereArgs: any(named: "whereArgs"),
          groupBy: any(named: "groupBy"),
          having: any(named: "having"),
          orderBy: any(named: "orderBy"),
          limit: any(named: "limit"),
          offset: any(named: "offset"),
        ),
      ).thenThrow(SqfliteDatabaseException("bad query", null));

      await expectLater(
        () => service.retrieve(TestQueryProvider(25)),
        throwsA(
          isA<DBException>().having(
            (error) => error.message,
            "message",
            "Failed to retrieve data from Test",
          ),
        ),
      );

      await service.dispose();
    });

    test("retrieve wraps generic failures", () async {
      final mockDb = MockDatabase();
      final service = SqliteDbService(mockDb);

      when(
        () => mockDb.query(
          any(),
          distinct: any(named: "distinct"),
          columns: any(named: "columns"),
          where: any(named: "where"),
          whereArgs: any(named: "whereArgs"),
          groupBy: any(named: "groupBy"),
          having: any(named: "having"),
          orderBy: any(named: "orderBy"),
          limit: any(named: "limit"),
          offset: any(named: "offset"),
        ),
      ).thenThrow(Exception("boom"));

      await expectLater(
        () => service.retrieve(TestQueryProvider(26)),
        throwsA(
          isA<DBException>().having(
            (error) => error.message,
            "message",
            "Failed to retrieve data from Test",
          ),
        ),
      );

      await service.dispose();
    });

    test("retrieve surfaces mapped fetch errors for missing tables", () async {
      final provider = RawTestQueryProvider(
        id: 27,
        sqlQuery: "SELECT * FROM Missing",
      );

      await expectLater(
        () => sut.retrieveRaw(provider),
        throwsA(isA<DBException>()),
      );
    });

    test("getById surfaces mapped fetch errors for missing tables", () async {
      final provider = _MissingTableQueryProvider(28);

      await expectLater(
        () => sut.getById(provider),
        throwsA(isA<DBException>()),
      );
    });

    test("retrieve surfaces mapped fetch errors for missing tables", () async {
      final provider = _MissingTableQueryProvider(29);

      await expectLater(
        () => sut.retrieve(provider),
        throwsA(isA<DBException>()),
      );
    });

    test(
      "watchTable emits mapped errors when the initial fetch fails",
      () async {
        await expectLater(
          sut.watchTable(_MissingTableQueryProvider(30)),
          emitsError(isA<DBException>()),
        );
      },
    );

    test(
      "watchRawQuery emits mapped errors when the raw fetch fails",
      () async {
        final stream = sut.watchRawQuery(
          RawTestQueryProvider(id: 31, sqlQuery: "SELECT * FROM Missing"),
        );

        final expectation = expectLater(stream, emitsError(isA<DBException>()));
        await sut.insert(TestQueryProvider(31), TestEntity(id: 31, name: "x"));
        await expectation;
      },
    );

    test("transaction insert surfaces mapped write errors", () async {
      await expectLater(
        () => sut.runInTransaction((txn) async {
          await txn.insert(
            TestQueryProvider(32),
            TestEntity(id: 32, name: "x"),
          );
          await txn.insert(
            TestQueryProvider(32),
            TestEntity(id: 32, name: "x"),
          );
        }),
        throwsA(isA<DBException>()),
      );
    });

    test("transaction retrieve surfaces mapped fetch errors", () async {
      await expectLater(
        () => sut.runInTransaction((txn) async {
          await txn.retrieve(_MissingTableQueryProvider(33));
        }),
        throwsA(isA<DBException>()),
      );
    });

    test("transaction getById surfaces mapped fetch errors", () async {
      await expectLater(
        () => sut.runInTransaction((txn) async {
          await txn.getById(_MissingTableQueryProvider(34));
        }),
        throwsA(isA<DBException>()),
      );
    });

    test("transaction retrieveRaw surfaces mapped fetch errors", () async {
      await expectLater(
        () => sut.runInTransaction((txn) async {
          await txn.retrieveRaw(
            RawTestQueryProvider(id: 35, sqlQuery: "SELECT * FROM Missing"),
          );
        }),
        throwsA(isA<DBException>()),
      );
    });

    test("upsert rejects empty conflict column lists", () async {
      await expectLater(
        () => sut.upsert(
          EmptyConflictQueryProvider(36),
          TestEntity(id: 36, name: "bad"),
        ),
        throwsException,
      );
    });

    test("transaction upsert rejects empty conflict column lists", () async {
      await expectLater(
        () => sut.runInTransaction((txn) async {
          await txn.upsert(
            EmptyConflictQueryProvider(37),
            TestEntity(id: 37, name: "bad"),
          );
        }),
        throwsException,
      );
    });

    test("transaction watch methods are unsupported", () async {
      await sut.runInTransaction((txn) async {
        expect(
          () => txn.watchTable(TestQueryProvider(38)),
          throwsA(isA<UnsupportedError>()),
        );
        expect(
          () => txn.watchRawQuery(TestQueryProvider(38)),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}

class _MissingTableQueryProvider with QueryProvider<TestEntity> {
  _MissingTableQueryProvider(this.id);

  final int id;

  @override
  String get table => "Missing";

  @override
  Object get itemID => id;

  @override
  TestEntity fromMap(Map<String, dynamic> map) {
    return TestEntity(id: map["id"], name: map["name"]);
  }
}
