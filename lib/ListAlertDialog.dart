import 'package:flutter/material.dart';
import 'package:flutter_todo/CustomAlertDialog.dart';

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
        values.forEach((String value) =>
                items.add(ListTile(
                    title: Text(value),
                    onTap: () {
                        Navigator.of(context).pop(value);
                    },
                )));
        return items;
    }

}
