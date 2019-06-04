import 'package:flutter/material.dart';
import 'package:flutter_todo/DatabaseHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'TodoTask.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Todo List',
      home: TodoList(),
    );
  }

}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State<TodoList> {

  final databaseHelper = DatabaseHelper.instance;
  List<TodoTask> _todoItems = [];

  Widget _buildTodoList() {
    _queryAll();
    return new ListView.separated(
            separatorBuilder: (context, index) =>
                    Divider(
                      color: Colors.grey,
                    )
            ,
            itemCount: _todoItems.length,
            itemBuilder: (context, index) {
              if (index < _todoItems.length) {
                return _buildTodoItem(_todoItems[index]);
              }
            }
    );
  }

  Widget _buildTodoItem(TodoTask todoItem) {
    return new ListTile(
      title: new Text(todoItem.content),
      onTap: () => _promptRemoveTodoTask(todoItem),
    );
  }

  _promptRemoveTodoTask(TodoTask todoItem) {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              return new AlertDialog(
                title: new Text('Mark ${todoItem.content} as done?'),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  new FlatButton(
                    child: new Text('DELETE'),
                    onPressed: () {
                      _delete(todoItem);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Flutter Todo")
      ),
      body: new Container(
        child: RefreshIndicator(
          child: _buildTodoList(),
          onRefresh: _refreshList,
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _openAddTodoScreen,
        tooltip: 'add Task',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _openAddTodoScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Add new task"),
            ),
            body: new TextField(
              autofocus: true,
              decoration: new InputDecoration(
                hintText: 'Enter task to save',
                contentPadding: const EdgeInsets.all(16.0)
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  await _insert(value);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(msg: "Your task is empty.");
                }
              },
            ),
          );
        }
      )
    );
  }

  // Database related methods
  Future<void> _insert(String content) async {
    final rowsCounts = await databaseHelper.queryRowCount();
    int index = rowsCounts;

    if (rowsCounts > 0) {
      final lastInsertOne = await databaseHelper.queryLastItem();
      index = lastInsertOne.id;
    }

    DateTime now = DateTime.now();
    String timestamps = now.toIso8601String();

    Map<String, dynamic> row = {
      DatabaseHelper.columnId : (index + 1),
      DatabaseHelper.columnContent : content,
      DatabaseHelper.columnUpdateTime : timestamps
    };
    final id = await databaseHelper.insert(row);
    print('inserted row id: $id');
  }

  Future<bool> _shouldRefreshInfo() async {
    final rowsCounts = await databaseHelper.queryRowCount();
    return (rowsCounts > _todoItems.length);
  }

  Future<void> _refreshList() async {
    _queryAll();
  }

  void _queryAll() async {
    final shouldRefresh = await _shouldRefreshInfo();
    if (!shouldRefresh) {
      return;
    }

    final allRows = await databaseHelper.queryAllRows();
    print('query all rows');
    setState(() {
      if (_todoItems.isNotEmpty) {
        _todoItems.clear();
      }

      _todoItems.addAll(allRows);
    });
  }

  void _delete(TodoTask todoTask) async {
    final deletedRow = await databaseHelper.delete(todoTask.id);
    print('deleted id is $deletedRow');
    setState(() {
      _todoItems.remove(todoTask);
    });
  }

}

