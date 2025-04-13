class DbConstants {
  static const String dbName = "sample_db.db";
  static const int dbVersion = 1;

  static const String tblSample = "tbl_sample";
  static const String tblSampleRef = "tbl_sample_ref";

  static const String queryCreateTblSample = '''
    CREATE TABLE $tblSample (
            id VARCHAR(20) PRIMARY KEY,
            item_one TEXT,
            ) 
  ''';

  static const String queryCreateTblSampleRef = '''
    CREATE TABLE $tblSampleRef (
            id VARCHAR(20) PRIMARY KEY,
            sample_id VARCHAR(20),
            item_two TEXT,
            FOREIGN KEY (sampleId) REFERENCES $tblSample (id)
          )
  ''';
}
