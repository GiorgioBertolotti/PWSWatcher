import 'package:flutter/material.dart';
import 'package:pws_watcher/model/pws.dart';

class DeletePWSDialog extends StatelessWidget {
  DeletePWSDialog(this.source, this.context);

  final PWS source;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete " + source.name! + "?"),
      content: Text(
          "This operation is irreversible, if you press Yes this source will be deleted. You really want to delete it?"),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(textStyle: TextStyle(color: Theme.of(context).buttonTheme.colorScheme?.primary)),
          child: Text("Yes"),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
