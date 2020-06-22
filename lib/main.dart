import 'package:flutter/material.dart';
import 'package:flutter_todo/DatabaseHelper.dart';
import 'package:flutter_todo/ListAlertDialog.dart';
import 'package:flutter_todo/pair.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'TodoTask.dart';
import 'app_localizations.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutodo',
      supportedLocales: [
        Locale('en', 'US'),
        Locale('zh', 'TW'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }

        for (var supportLocale in supportedLocales) {
          if (supportLocale.languageCode == locale.languageCode &&
                  supportLocale.countryCode == locale.countryCode) {
            return supportLocale;
          }
        }
        // fallback to first supported language
        return supportedLocales.first;
      },
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
      appBar: new AppBar(
        title: Text(appTitle)
      ),
      body: new Container(
        child: RefreshIndicator(
          child: _buildTodoList(),
          onRefresh: _refreshList,
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
    TextEditingController textEditingController;
    String title;
    String hint = AppLocalizations.of(context).translate("hint_task_name_edit_text");
    String emptyErrorMessage = AppLocalizations.of(context).translate("toast_task_is_empty");
    if (todoTask != null) {
      textEditingController = new TextEditingController(text: todoTask.content);
      title = AppLocalizations.of(context).translate("title_edit_task");
    } else {
      textEditingController = new TextEditingController();
      title = AppLocalizations.of(context).translate("title_add_task");
    }

    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: new TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: new InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.all(16.0)
              ),
              onSubmitted: (value) async {
                if (value.isEmpty) {
                  Fluttertoast.showToast(msg: emptyErrorMessage);
                  return;
                }

                if (todoTask == null) {
                  await _insert(value);
                } else {
                  await _update(todoTask, value);
                }
                Navigator.pop(context);
              },
            ),
          );
        }
      )
    ).then((value) => _queryAllTodoItems());
  }

  // Database related methods
  Future<void> _insert(String content) async {
    final rowsCounts = await databaseHelper.queryRowCount();
    int index = rowsCounts;

    if (rowsCounts > 0) {
      final lastInsertOne = await databaseHelper.queryLastItem();
      index = lastInsertOne.id;
    }

    Map<String, dynamic> row = {
      DatabaseHelper.columnId : (index + 1),
      DatabaseHelper.columnContent : content,
      DatabaseHelper.columnUpdateTime : _getCurrentTimeStamp()
    };
    final id = await databaseHelper.insert(row);
    print('inserted row id: $id');
  }

  Future<void> _update(TodoTask todoTask, String updateContent) async {
    Map<String, dynamic> updateItem = {
      DatabaseHelper.columnId : todoTask.id,
      DatabaseHelper.columnUpdateTime : _getCurrentTimeStamp(),
      DatabaseHelper.columnContent : updateContent
    };

    final updateItemId = await databaseHelper.update(updateItem);
    print('updated item id: $updateItemId');
  }

  String _getCurrentTimeStamp() {
    DateTime now = DateTime.now();
    return now.toIso8601String();
  }

  Future<void> _refreshList() async {
    _queryAllTodoItems();
  }

  void _queryAllTodoItems() async {
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
