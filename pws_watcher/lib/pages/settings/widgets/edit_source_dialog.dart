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
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _editNameController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "You must set a source name.";
                  return null;
                },
                decoration: InputDecoration.collapsed(
                    hintText: "Source name", border: UnderlineInputBorder()),
                maxLines: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.url,
                controller: _editUrlController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "You must set a source url.";
                  return null;
                },
                decoration: InputDecoration.collapsed(
                  hintText: "Realtime file URL",
                  border: UnderlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _editIntervalController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.tryParse(value) < 0)
                    return "Please set a valid interval.";
                  return null;
                },
                decoration: InputDecoration.collapsed(
                    hintText: "Refresh interval (sec).",
                    border: UnderlineInputBorder()),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
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
