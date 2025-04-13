// import 'package:db_flutter/db.dart';
// import 'package:db_flutter/src/db/db_constants.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//
// void main() {
//   // Initialize FFI for Dart VM
//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;
//
//   group('AppDatabase', () {
//     late AppDatabase dbInstance;
//
//     setUp(() async {
//       dbInstance = AppDatabase();
//       // force reset if needed (e.g., in-memory DB or new db name)
//     });
//
//     test('should create a database instance', () async {
//       final db = await dbInstance.database;
//
//       expect(db, isNotNull);
//       expect(db.isOpen, isTrue);
//     });
//
//     test('should create expected tables', () async {
//       final db = await dbInstance.database;
//
//       // Check if tables exist using SQLite PRAGMA
//       final sampleTable = await db.rawQuery(
//         "SELECT name FROM sqlite_master WHERE type='table' AND name='${DbConstants.tblSample}'",
//       );
//       final sampleRefTable = await db.rawQuery(
//         "SELECT name FROM sqlite_master WHERE type='table' AND name='${DbConstants.tblSampleRef}'",
//       );
//
//       expect(sampleTable.isNotEmpty, isTrue);
//       expect(sampleRefTable.isNotEmpty, isTrue);
//     });
//   });
// }
