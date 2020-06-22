import 'package:flutter/material.dart';
import 'package:flutter_todo/DatabaseHelper.dart';
import 'package:flutter_todo/ListAlertDialog.dart';
import 'package:flutter_todo/add_task.dart';
import 'package:flutter_todo/pair.dart';
import 'app_localizations.dart';
import 'TodoTask.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoListState();
  }
}

class _TodoListState extends State<TodoList> {
  final databaseHelper = DatabaseHelper.instance;
  List<TodoTask> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _queryAllTodoItems();
  }

  Widget _buildTodoList() {
    return new ListView.separated(
            separatorBuilder: (context, index) =>
                    Divider(
                      color: Colors.grey,
                    )
            ,
            itemCount: _todoItems.length,
            itemBuilder: (context, index) {
              if (index < _todoItems.length) {
                return _buildTodoItem(index, _todoItems[index]);
              }
            }
    );
  }

  Widget _buildTodoItem(int index, TodoTask todoItem) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(todoItem.id.toString()),
      onDismissed: (direction) {
        setState(() {
          _todoItems.remove(todoItem);
        });
        _promptRemoveTodoTask(index, todoItem);
      },
      child: new ListTile(
        title: new Text(todoItem.content),
        onTap: () {
          showDialog(
                  context: context,
                  builder: (context) {
                    String editTitle = AppLocalizations.of(context).translate("action_edit");
                    String doneTitle = AppLocalizations.of(context).translate("action_done");
                    String cancelTitle = AppLocalizations.of(context).translate("action_cancel");
                    List<String> values = [editTitle, doneTitle, cancelTitle];
                    return ListAlertDialog(values: values);
                  }).then((callbackValue) {
            var pair = callbackValue as Pair;
            var dialogMenuIndex = pair.left as int;

            switch (dialogMenuIndex) {
              case 0:
                _openEditTodoScreen(todoItem);
                break;
              case 1:
                _promptRemoveTodoTask(index, todoItem);
                break;
              case 2:
                break;
            }
          });
        },
      ),
    );
  }

  _promptRemoveTodoTask(int index, TodoTask todoItem) {
    showDialog(
            context: context,
            builder: (BuildContext context) {
              String message = AppLocalizations.of(context).translate("message_done_task");
              message = message.replaceFirst("{placeholder01}", todoItem.content);
              return new AlertDialog(
                title: new Text(message),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(AppLocalizations.of(context).translate("action_cancel")),
                    onPressed: () {
                      setState(() {
                        if (!_todoItems.contains(todoItem)) {
                          _todoItems.insert(index, todoItem);
                        }
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text(AppLocalizations.of(context).translate("action_done")),
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
    String appTitle = AppLocalizations.of(context).translate("app_name");
    String toolTipAddItem = AppLocalizations.of(context).translate("tooltip_add_task");
    return new Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(appTitle),
                centerTitle: true,
                background: Image.asset(
                  "assets/images/watercolour.jpg",
                  fit: BoxFit.cover
                ),
              ),
            )
          ];
        },
        body: new Container(
          child: RefreshIndicator(
            child: _buildTodoList(),
            onRefresh: _refreshList,
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _openEditTodoScreen(null);
        },
        tooltip: toolTipAddItem,
        child: new Icon(Icons.add),
      ),
    );
  }

  void _openEditTodoScreen(TodoTask todoTask) {
    Navigator.of(context).push(
            new MaterialPageRoute(
                    builder: (context) {
                      return new AddTaskPage(todoTask: todoTask);
                    }
            )
    ).then((value) => _queryAllTodoItems());
  }

  // Database related methods

  Future<void> _refreshList() async {
    _queryAllTodoItems();
  }

  Future<void> _queryAllTodoItems() async {
    final allRows = await databaseHelper.queryAllRows();
    print('query all rows');
    setState(() {
      if (_todoItems.isNotEmpty) {
        _todoItems.clear();
      }

      _todoItems.addAll(allRows);
    });
  }

  Future<void> _delete(TodoTask todoTask) async {
    final deletedRow = await databaseHelper.delete(todoTask.id);
    print('deleted id is $deletedRow');
    setState(() {
      _todoItems.remove(todoTask);
    });
  }
}