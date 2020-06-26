import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/data/notification_generator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_todo/data/database_helper.dart';
import 'app_localizations.dart';
import 'data/todo_task.dart';
import 'package:intl/intl.dart';

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
  NotificationGenerator _notificationGenerator;
  final TodoTask todoTask;
  String title;
  String hint;
  String emptyErrorMessage;
  TextEditingController textEditingController;
  DateTime notificationDateTime;
  final DateFormat dateFormat = new DateFormat("yyyy-MM-dd HH:mm");
  bool canRemoveNotification = false;

  _AddTaskState(this.todoTask);

  @override
  void dispose() {
    textEditingController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    _notificationGenerator = new NotificationGenerator(
            iOSNotificationCallback: _onDidReceiveLocalNotification,
            selectNotificationCallback: _onSelectNotification
    );

    if (todoTask != null) {
      DateTime notificationDateTime = todoTask.notificationDateTime;
      if (notificationDateTime != null) {
        this.notificationDateTime = notificationDateTime;
        this.canRemoveNotification = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _prepareInformation(context);
    String addNewTaskTitle = AppLocalizations.of(context).translate("add_new_task");
    String setupNotificationTitle = AppLocalizations.of(context).translate("setup_notification");
    String setupNotificationDateTime = AppLocalizations.of(context).translate("setup_notification_datetime");
    String cancelNotification = AppLocalizations.of(context).translate("cancel_notification");
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              String result = textEditingController?.text ?? "";
              _doResultHandling(context, result);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  addNewTaskTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextField(
                  controller: textEditingController,
                  autofocus: false,
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: hint,
                    contentPadding: const EdgeInsets.all(16.0))),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  setupNotificationTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                )
              ),
              SizedBox(height: 24),
              Text("Result is ${notificationDateTime != null ? dateFormat.format(notificationDateTime) : "not set"}"),
              SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    onPressed: () async {
                      final result = await _showDateSelector(context);
                      if (result == null) {
                          return;
                      }
                      print("You select date it $result");

                      final timeOfDayResult = await _showTimeSelector(context);
                      if (timeOfDayResult == null) {
                        return;
                      }
                      print("You select time is $timeOfDayResult");

                      DateTime resultDateTime = DateTime(
                        result.year,
                        result.month,
                        result.day,
                        timeOfDayResult.hour,
                        timeOfDayResult.minute
                      );

                      setState(() {
                        // set state to refresh the widget
                        this.notificationDateTime = resultDateTime;
                        this.canRemoveNotification = true;
                      });
                    },
                    child: Text(setupNotificationDateTime)),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: RaisedButton(
                    color: canRemoveNotification ? Colors.blue : Colors.grey,
                    textColor: Colors.white,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    onPressed: () {
                      if (!canRemoveNotification) {
                        return;
                      }
                      _notificationGenerator.cancelNotification(todoTask.notificationId);

                      setState(() {
                        notificationDateTime = null;
                        canRemoveNotification = false;
                      });
                    },
                    child: Text(cancelNotification)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime> _showDateSelector(BuildContext context) {
    return showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2070)
    );
  }

  Future<TimeOfDay> _showTimeSelector(BuildContext context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now()
    );
  }

  void _prepareInformation(BuildContext context) {
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

  // Database related APIs

  Future<void> _insert(BuildContext context, String content) async {
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

    if (notificationDateTime != null) {
      int notificationId = _generateNotificationId();
      String appName = AppLocalizations.of(context).translate("app_name");
      _notificationGenerator.pushNotification(
          notificationId,
          notificationDateTime,
          appName,
          content
      );

      Map<String, dynamic> additionalRows = {
        DatabaseHelper.columnNotificationId : notificationId,
        DatabaseHelper.columnNotificationDateTime : notificationDateTime.toIso8601String()
      };
      row.addAll(additionalRows);
    }
    final id = await databaseHelper.insert(row);
    print('inserted row id: $id');
  }

  Future<void> _updateContent(TodoTask todoTask, String updateContent) async {
    Map<String, dynamic> updateItem = {
      DatabaseHelper.columnId : todoTask.id,
      DatabaseHelper.columnUpdateTime : _getCurrentTimeStamp(),
      DatabaseHelper.columnContent : updateContent
    };

    bool updateNotificationTime = todoTask.notificationDateTime != notificationDateTime;
    if (updateNotificationTime) {
      if (notificationDateTime != null) {
        _notificationGenerator.cancelNotification(todoTask.notificationId);
        int notificationId = _generateNotificationId();
        String appName = AppLocalizations.of(context).translate("app_name");
        _notificationGenerator.pushNotification(
                notificationId,
                notificationDateTime,
                appName,
                updateContent
        );

        Map<String, dynamic> additionalRows = {
          DatabaseHelper.columnNotificationId : notificationId,
          DatabaseHelper.columnNotificationDateTime : notificationDateTime.toIso8601String()
        };
        updateItem.addAll(additionalRows);
      } else {
        Map<String, dynamic> additionalRows = {
          DatabaseHelper.columnNotificationId : -1,
          DatabaseHelper.columnNotificationDateTime : "null"
        };
        updateItem.addAll(additionalRows);
      }
    }
    final updateItemId = await databaseHelper.update(updateItem);
    print('updated item id: $updateItemId');
  }

  _doResultHandling(BuildContext context, String value) async {
    if (value.isEmpty) {
      Fluttertoast.showToast(msg: emptyErrorMessage);
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode()); // hide keyboard
    if (todoTask == null) {
      await _insert(context, value);
    } else {
      if (todoTask.content != value ||
          todoTask.notificationDateTime != notificationDateTime) {
        await _updateContent(todoTask, value);
      }
    }
    Navigator.pop(context);
  }

  String _getCurrentTimeStamp() {
    DateTime now = DateTime.now();
    return now.toIso8601String();
  }

  // generate random 6 digits
  int _generateNotificationId() {
    Random random = Random();
    return random.nextInt(900000) + 100000;
  }

  Future _onSelectNotification(String payload) {
    // We can use payload to Navigate to another screen
    print("enter from notification");
    if (payload != null) {
      print(payload);
    }
  }

  Future _onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text("OK"),
          isDefaultAction: true,
          onPressed: () {
            print("Clicked OK in iOS notification");
          },
        )
      ],
    );
  }
}
