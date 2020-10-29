import 'package:flutter/material.dart';
import 'package:pws_watcher/model/custom_data.dart';

class DeleteCustomDataDialog extends StatelessWidget {
  DeleteCustomDataDialog(this.customData, this.context);

  final CustomData customData;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete " + customData.name + "?"),
      content: Text(
          "This operation is irreversible, if you press Yes this custom variable will be deleted. You really want to delete it?"),
      actions: <Widget>[
        FlatButton(
          textColor: Theme.of(context).buttonColor,
          child: Text("Yes"),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        FlatButton(
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
