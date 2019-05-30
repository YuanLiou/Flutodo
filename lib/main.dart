import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  List<String> _todoItems = [];

  void _addTodoItem(String task) {
    setState(() {
        if (task.length > 0) {
          _todoItems.add(task);
        }
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      return _todoItems.removeAt(index);
    });
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return new AlertDialog(
          title: Text('Mark ${_todoItems[index]} as done?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                // Dismiss alert dialog
                Navigator.of(dialogContext).pop();
              },
            ),
            FlatButton(
              child: Text('Mark as done'),
              onPressed: () {
                _removeTodoItem(index);
                Navigator.of(dialogContext).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildTodoList() {
    return new ListView.builder(
        itemBuilder: (context, index) {
          if (index < _todoItems.length) {
            return _buildTodoItem(_todoItems[index], index);
          }
        },
    );
  }

  Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
      title: new Text(todoText),
      onTap: () => _promptRemoveTodoItem(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Todo List'),
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'Add Task',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Add a new task')
            ),
            body: new TextField(
              autofocus: false,
              onSubmitted: (val) {
                _addTodoItem(val);
                if (val.length > 0) {
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                    msg: "The test is empty.",
                  );
                }
              },
              decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)
              ),
              textInputAction: TextInputAction.send,
            ),
          );
        }
      )
    );
  }

}

