import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_todo/DatabaseHelper.dart';
import 'app_localizations.dart';
import 'TodoTask.dart';

class AddTaskPage extends StatefulWidget {
  final TodoTask todoTask;

  AddTaskPage({@required this.todoTask});

  @override
  State<StatefulWidget> createState() {
    return _AddTaskState(todoTask);
  }
}

class _AddTaskState extends State<AddTaskPage> {
  final databaseHelper = DatabaseHelper.instance;
  final TodoTask todoTask;
  String title;
  String hint;
  String emptyErrorMessage;
  TextEditingController textEditingController;

  _AddTaskState(this.todoTask);

  @override
  void dispose() {
    textEditingController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _prepareInformation(context);
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

  _prepareInformation(BuildContext context) {
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

    this.title = title;
    this.hint = hint;
    this.emptyErrorMessage = emptyErrorMessage;
    this.textEditingController = textEditingController;
  }

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
}
