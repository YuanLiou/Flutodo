import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
    CustomAlertDialog({Key key, this.title, @required this.contentWidget, this.showCancel = false, this.showConfirm = false, this.actionWidgets}) : super(key: key);

    final bool showCancel;
    final bool showConfirm;
    final String title;
    final Widget contentWidget;
    final List<Widget> actionWidgets;

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: title != null ? Text(title) : null,
            elevation: 12.0,
            actions: _buildActionWidget(context),
            content: contentWidget,
        );
    }

    _buildActionWidget(BuildContext context) {
        List<Widget> actionWidgets = this.actionWidgets;
        if (actionWidgets == null) {
          actionWidgets = [];
          if (showConfirm) {
            actionWidgets.add(FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Confirm"),
            ));
          }
          if (showCancel) {
              actionWidgets.add(FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
              ));
          }
        }
        return actionWidgets;
    }
}