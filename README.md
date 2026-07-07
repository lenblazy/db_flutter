# Flutter Database

A small Flutter database package that wraps common CRUD, transaction, and
watcher flows behind a typed `DbService` and `QueryProvider` contract.

## Features
- Typed CRUD operations through `DbService`
- Reusable query definitions with `QueryProvider<T>`
- Support for raw queries and transactions
- Table and raw-query watchers for reactive updates
- Injectable micro-package setup for dependency registration

## Package API
- `DbService`: the main abstraction for insert, retrieve, update, delete,
  clear, upsert, transactions, and watch operations
- `Entity`: the base model contract for data written to the database
- `QueryProvider<T>`: the query definition used to describe tables, filters,
  mapping, and conflict columns
- `initDbPackage()`: registers the package's dependencies via `injectable`

## Getting started
Add the package to your project, then register the generated micro-package in
your root dependency injection setup.

This package exports:
```dart
export "src/db/service/db_service.dart";
export "src/di/injector.module.dart";
```

If you are using `injectable`, make sure the generated package module is loaded
from your app's DI bootstrap.

## Basic usage
Implement an `Entity` and a matching `QueryProvider<T>`:

```dart
class UserEntity extends Entity {
  UserEntity({required this.id, required this.name});

  final int id;
  final String name;

  @override
  Object get primaryKeyValue => id;

  @override
  Map<String, Object?> toMap() => {
        "id": id,
        "name": name,
      };
}

class UserQueryProvider with QueryProvider<UserEntity> {
  UserQueryProvider(this.id);

  final int id;

  @override
  String get table => "users";

  @override
  Object get itemID => id;

  @override
  UserEntity fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map["id"] as int,
      name: map["name"] as String,
    );
  }
}
```

Then use `DbService`:

```dart
final provider = UserQueryProvider(1);

await dbService.insert(provider, UserEntity(id: 1, name: "Asha"));

final user = await dbService.getById(provider);
final users = await dbService.retrieve(provider);

await dbService.update(provider, UserEntity(id: 1, name: "Updated"));
await dbService.delete(provider);
```

## Transactions
Use `runInTransaction` when a set of operations should succeed together:

```dart
await dbService.runInTransaction((txn) async {
  await txn.insert(provider, UserEntity(id: 1, name: "Asha"));
  await txn.upsert(provider, UserEntity(id: 1, name: "Asha Updated"));
});
```

## Watchers
Use watchers when UI state should react to DB changes:

```dart
final stream = dbService.watchTable(provider);
```

## Running tests
Run the test suite with:

```bash
flutter test
flutter test --coverage
```

The current suite is expected to maintain `100%` line coverage.

## Generating dependencies
The package uses `injectable` for DI. Regenerate code with:

```bash
dart run build_runner build --delete-conflicting-outputs
```
