mixin QueryProvider {
  String get table;
  Map<String, Object?> get data;
  QueryMethod get httpMethod;
  String get column;
  String get itemID;
}

enum QueryMethod { insert, update, delete, clear }
