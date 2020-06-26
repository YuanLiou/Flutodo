import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/app_localizations.dart';
import 'package:flutter_todo/data/notification_generator.dart';

class NotificationPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationPostPageState();
  }
}

class _NotificationPostPageState extends State<NotificationPostPage> {
  final int _notificationId = 1776;
  NotificationGenerator notificationGenerator;

  @override
  void initState() {
    super.initState();
    notificationGenerator = new NotificationGenerator(
            iOSNotificationCallback: _onDidReceiveLocalNotification,
            selectNotificationCallback: _onSelectNotification
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = AppLocalizations.of(context).translate("only_for_debug_text");
    return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: SafeArea(
              child: Container(
                margin: EdgeInsets.only(
                        left: 16,
                        right: 16
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "This is notification post page.",
                      style: TextStyle(
                              fontSize: 18
                      ),
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 16
                            ),
                            onPressed: () {
//                                notificationGenerator.pushNotification(_notificationId, "Hello", "This is from my notification generator.");
                            },
                            child: const Text("Push Notification")
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 16
                            ),
                            onPressed: () {
                              notificationGenerator.cancelNotification(_notificationId);
                            },
                            child: const Text("Cancel Notification")
                    )
                  ],
                ),
              ),
            )
    );
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