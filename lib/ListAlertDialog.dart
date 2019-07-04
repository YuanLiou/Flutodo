import 'package:flutter/material.dart';
import 'package:flutter_todo/CustomAlertDialog.dart';
import 'package:flutter_todo/pair.dart';

class ListAlertDialog extends StatelessWidget {
    ListAlertDialog({Key key, @required this.values}) : super(key: key);

    final List<String> values;

    @override
    Widget build(BuildContext context) {
        return CustomAlertDialog(
            contentWidget: Container(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildListItems(context),
                ),
            ),
        );
    }

    _buildListItems(BuildContext context) {
        List<Widget> items = [];
        for (int i = 0; i < values.length; i++) {
            var value = values[i];
            items.add(ListTile(
                    title: Text(value),
                    onTap: () {
                        Navigator.of(context).pop(Pair(i, value));
                    }
            )
            );
        }
        return items;
    }

}
