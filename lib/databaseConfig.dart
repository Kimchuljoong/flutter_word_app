import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _database = DatabaseService._interval();
  late Future<Database> database;

  factory DatabaseService() => _database;

  DatabaseService._interval() {
    databaseConfig();
  }

  Future<bool> databaseConfig() async {
    try {
      database =
          openDatabase(join(await getDatabasesPath(), 'word_database.db'),
              onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE words(id INTEGER PRIMARY KEY, name TEXT, meaning TEXT)',
        );
      }, version: 1);
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }
}
