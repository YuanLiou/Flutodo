import 'package:flutter_todo/DatabaseHelper.dart';

class TodoTask {
    int id;
    String content;
    DateTime timeStamps;

    TodoTask(this.id, this.content, this.timeStamps);

    TodoTask.fromJson(Map<String, dynamic> json) {
        this.id = json[DatabaseHelper.columnId];
        this.content = json[DatabaseHelper.columnContent];

        String rawDateTime = json[DatabaseHelper.columnUpdateTime];
        this.timeStamps = DateTime.parse(rawDateTime);
    }
}