import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  static final _databaseName = "TodoListDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'todo_list_table';

  static final columnId = '_id';
  static final columnContent = '_content';
  static final columnUpdateTime = '_update_time';

  // singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databaseName);
    return await openDatabase(path,
            version: _databaseVersion,
            onCreate: _onCreate);
  }

  Future _onCreate(Database database, int version) async {
    await database.execute('''
     CREATE TABLE $table (
       $columnId INTEGER PRIMARY KEY,
       $columnContent TEXT,
       $columnUpdateTime TEXT NOT NULL
     )
    ''');
  }

  // Helper methods
  Future<int> insert(Map<String, dynamic> row) async {
    Database database = await instance.database;
    return await database.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database database = await instance.database;
    return await database.query(table);
  }

  Future<int> queryRowCount() async {
    Database database = await instance.database;
    return Sqflite.firstIntValue(await database.rawQuery('''
     SELECT COUNT(*) FROM $table
    '''));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database database = await instance.database;
    int id = row[columnId];
    return await database.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database database = await instance.database;
    return await database.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}

