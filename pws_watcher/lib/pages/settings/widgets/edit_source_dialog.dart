import 'package:flutter/material.dart';
import 'package:pws_watcher/model/source.dart';

class EditSourceDialog extends StatefulWidget {
  EditSourceDialog(this.source, this.context);

  final Source source;
  final BuildContext context;

  @override
  _EditSourceDialogState createState() => _EditSourceDialogState();
}

class _EditSourceDialogState extends State<EditSourceDialog> {
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  final _editNameController = TextEditingController();
  final _editUrlController = TextEditingController();
  final _editIntervalController = TextEditingController();

  @override
  void initState() {
    _editNameController.text = widget.source.name;
    _editUrlController.text = widget.source.url;
    _editIntervalController.text = widget.source.autoUpdateInterval.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit " + widget.source.name),
      content: Form(
        key: _editFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 75.0,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _editNameController,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "You must set a source name.";
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "PWS name",
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
            Container(
              height: 75.0,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.url,
                controller: _editUrlController,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "You must set a source url.";
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Realtime file URL",
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
            Container(
              height: 75.0,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _editIntervalController,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.tryParse(value) < 0)
                    return "Please set a valid interval.";
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Update interval (sec).",
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        /*
        FlatButton(
          textColor: Theme.of(widget.context).buttonColor,
          child: Text("Help"),
          onPressed: () {
            // TODO: Show help
          },
        ),
        */
        FlatButton(
          textColor: Theme.of(widget.context).buttonColor,
          child: Text("Close"),
          onPressed: () {
            Navigator.of(widget.context).pop();
          },
        ),
        FlatButton(
          textColor: Colors.white,
          color: Theme.of(widget.context).buttonColor,
          child: Text("Edit"),
          onPressed: () async {
            if (_editFormKey.currentState.validate()) {
              _editFormKey.currentState.save();
              widget.source.name = _editNameController.text;
              widget.source.url = _editUrlController.text;
              widget.source.autoUpdateInterval =
                  int.parse(_editIntervalController.text);
              Navigator.of(widget.context).pop(widget.source);
            }
          },
        ),
      ],
    );
  }
}
