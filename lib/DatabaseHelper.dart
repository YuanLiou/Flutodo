import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'TodoTask.dart';

class DatabaseHelper {

  static final _databaseName = "TodoListDatabase.db";
  static final _databaseVersion = 1;

  static const table = 'todo_list_table';

  static const columnId = '_id';
  static const columnContent = '_content';
  static const columnUpdateTime = '_update_time';

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

  Future<List<TodoTask>> queryAllRows() async {
    Database database = await instance.database;
    final rows = await database.query(table);
    List<TodoTask> tasks = List();

    for (final node in rows) {
      final todoTask = TodoTask.fromJson(node);
      tasks.add(todoTask);
    }
    return tasks;
  }

  Future<TodoTask> queryItem(int id) async {
    Database database = await instance.database;
    final String sql = '''
      SELECT * FROM $table
      WHERE $columnId = $id
    ''';
    final data = await database.rawQuery(sql);
    final todoTask = TodoTask.fromJson(data[0]);
    return todoTask;
  }

  Future<TodoTask> queryLastItem() async {
    Database database = await instance.database;
    final String sql = '''
      SELECt * FROM $table
      ORDER BY $columnId DESC LIMIT 1
    ''';
    final data = await database.rawQuery(sql);
    final todoTask = TodoTask.fromJson(data[0]);
    return todoTask;
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

