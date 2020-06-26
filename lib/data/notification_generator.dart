import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationGenerator {
    FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings androidNotificationSettings;
    IOSInitializationSettings iosNotificationSettings;
    InitializationSettings notificationInitSettings;

    final DidReceiveLocalNotificationCallback iOSNotificationCallback;
    final SelectNotificationCallback selectNotificationCallback;

    NotificationGenerator({@required this.iOSNotificationCallback, @required this.selectNotificationCallback}) {
        _initializeNotificationPlugins();
    }

    void _initializeNotificationPlugins() async {
        androidNotificationSettings = AndroidInitializationSettings('app_icon');
        iosNotificationSettings = IOSInitializationSettings(onDidReceiveLocalNotification: iOSNotificationCallback);
        notificationInitSettings = InitializationSettings(androidNotificationSettings, iosNotificationSettings);
        await notificationPlugin.initialize(notificationInitSettings, onSelectNotification: selectNotificationCallback);
    }

    void pushNotification(int id, DateTime scheduledDate, String title, String message) async {
//        await _generateNotification(id, title, message);
        await _generateScheduledNotification(id, scheduledDate, title, message);
    }

    void cancelNotification(int id) async {
        await _cancelScheduledNotification(id);
    }

    Future<void> _generateNotification(int id, String title, String message) async {
        NotificationDetails notificationDetails = _generateNotificationDetails();
        await notificationPlugin.show(id, title, message, notificationDetails);
    }

    Future<void> _generateScheduledNotification(int id, DateTime scheduledDate, String title, String message) async {
        NotificationDetails notificationDetails = _generateNotificationDetails();
        await notificationPlugin.schedule(id, title, message, scheduledDate, notificationDetails, androidAllowWhileIdle: true);
    }

    Future<void> _cancelScheduledNotification(int id) async {
        print("notification canceled, with id $id");
        await notificationPlugin.cancel(id);
    }

    NotificationDetails _generateNotificationDetails() {
        AndroidNotificationDetails androidNotificationDetail = AndroidNotificationDetails(
                'FT_CHANNEL_ID',
                'Fluttodo',
                'Your todo list notification',
                priority: Priority.High,
                importance: Importance.High,
                ticker: 'Fluttodo notification'
        );

        IOSNotificationDetails iosNotificationDetail = IOSNotificationDetails();
        NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetail, iosNotificationDetail);
        return notificationDetails;
    }
}