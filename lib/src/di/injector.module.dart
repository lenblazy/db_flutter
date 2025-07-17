//@GeneratedMicroModule;DbFlutterPackageModule;package:db_flutter/src/di/injector.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:db_flutter/db.dart' as _i344;
import 'package:db_flutter/src/db/sqlite/sqlite_db.dart' as _i975;
import 'package:db_flutter/src/di/db_module.dart' as _i793;
import 'package:injectable/injectable.dart' as _i526;

class DbFlutterPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final dbModule = _$DbModule();
    gh.lazySingleton<_i975.SqliteDb>(() => dbModule.sqliteDb());
    gh.lazySingleton<_i344.DbService>(
      () => dbModule.dbService(gh<_i975.SqliteDb>()),
    );
  }
}

class _$DbModule extends _i793.DbModule {}
