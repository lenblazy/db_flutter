import "entity.dart";

mixin QueryProvider {
  String get table;
  Entity get data;
  QueryMethod get httpMethod;
  String get column;
  String get itemID;
}

enum QueryMethod { insert, update, delete, clear }
