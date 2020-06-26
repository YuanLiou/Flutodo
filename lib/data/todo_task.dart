import 'package:flutter_todo/data/database_helper.dart';

class TodoTask {
    int id;
    String content;
    DateTime timeStamps;

    int notificationId;
    DateTime notificationDateTime;

    TodoTask(this.id, this.content, this.timeStamps);

    TodoTask.fromJson(Map<String, dynamic> json) {
        this.id = json[DatabaseHelper.columnId];
        this.content = json[DatabaseHelper.columnContent];

        String rawDateTime = json[DatabaseHelper.columnUpdateTime];
        this.timeStamps = DateTime.parse(rawDateTime);
    }

    void setNotification(int id, DateTime dateTime) {
      this.notificationId = notificationId;
      this.notificationDateTime = dateTime;
    }
}