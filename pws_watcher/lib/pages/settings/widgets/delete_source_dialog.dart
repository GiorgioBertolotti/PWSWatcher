import 'package:flutter/material.dart';
import 'package:pws_watcher/model/source.dart';

class DeleteSourceDialog extends StatelessWidget {
  DeleteSourceDialog(this.source, this.context);

  final Source source;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete " + source.name + "?"),
      content: Text(
          "This operation is irreversible, if you press Yes this source will be deleted. You really want to delete it?"),
      actions: <Widget>[
        FlatButton(
          textColor: Theme.of(context).buttonColor,
          child: Text("Yes"),
          onPressed: () async {
            Navigator.of(context).pop(true);
          },
        ),
        FlatButton(
          textColor: Colors.white,
          color: Theme.of(context).buttonColor,
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
