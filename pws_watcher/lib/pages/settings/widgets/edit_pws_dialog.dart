import 'package:flutter/material.dart';
import 'package:pws_watcher/model/pws.dart';
import 'package:url_launcher/url_launcher.dart';

class EditPWSDialog extends StatefulWidget {
  EditPWSDialog(this.source, this.context);

  final PWS source;
  final BuildContext context;

  @override
  _EditPWSDialogState createState() => _EditPWSDialogState();
}

class _EditPWSDialogState extends State<EditPWSDialog> {
  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _intervalController = TextEditingController();
  final _snapshotUrlController = TextEditingController();

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _urlFocusNode = FocusNode();
  FocusNode _intervalFocusNode = FocusNode();
  FocusNode _snapshotUrlFocusNode = FocusNode();

  @override
  void initState() {
    _nameController.text = widget.source.name;
    _urlController.text = widget.source.url;
    _intervalController.text = widget.source.autoUpdateInterval.toString();
    _snapshotUrlController.text = widget.source.snapshotUrl ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double inputHeight = 75.0;
    return AlertDialog(
      title: Text("Edit " + widget.source.name),
      content: Form(
        key: _editFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: inputHeight,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _nameController,
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
                focusNode: _nameFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(_urlFocusNode),
              ),
            ),
            Container(
              height: inputHeight,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.url,
                controller: _urlController,
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
                focusNode: _urlFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(_intervalFocusNode),
              ),
            ),
            Container(
              height: inputHeight,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _intervalController,
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
                focusNode: _intervalFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(_snapshotUrlFocusNode),
              ),
            ),
            Container(
              height: inputHeight,
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.url,
                controller: _snapshotUrlController,
                decoration: InputDecoration(
                  labelText: "Webcam snapshot URL (opt.)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
                focusNode: _snapshotUrlFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (text) => _editPWS(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          textColor: Theme.of(widget.context).buttonColor,
          child: Text("Help"),
          onPressed: _openHelp,
        ),
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
          onPressed: _editPWS,
        ),
      ],
    );
  }

  _editPWS() {
    if (_editFormKey.currentState.validate()) {
      _editFormKey.currentState.save();
      widget.source.name = _nameController.text;
      widget.source.url = _urlController.text;
      widget.source.autoUpdateInterval = int.parse(_intervalController.text);
      widget.source.snapshotUrl = _snapshotUrlController.text;
      Navigator.of(widget.context).pop(widget.source);
    }
  }

  _openHelp() async {
    const url = "https://bertolotti.dev/PWSWatcher/compatibilities";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch" + url);
    }
  }
}
