import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/main.dart';
import 'package:pws_watcher/model/source.dart';
import 'package:pws_watcher/model/state.dart';

class AddSourceDialog extends StatefulWidget {
  AddSourceDialog(this.context);

  final BuildContext context;

  @override
  _AddSourceDialogState createState() => _AddSourceDialogState();
}

class _AddSourceDialogState extends State<AddSourceDialog> {
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();

  final _addNameController = TextEditingController();
  final _addUrlController = TextEditingController();
  final _addIntervalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add source"),
      content: Form(
        key: _addFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _addNameController,
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
                controller: _addUrlController,
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
                    border: UnderlineInputBorder()),
                maxLines: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _addIntervalController,
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
          child: Text("Add"),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            if (_addFormKey.currentState.validate()) {
              _addFormKey.currentState.save();
              Source source = Source(
                  Provider.of<ApplicationState>(context).countID++,
                  _addNameController.text,
                  _addUrlController.text,
                  autoUpdateInterval: int.parse(_addIntervalController.text));
              PWSWatcher.navigatorKey.currentState.pop(source);
            }
          },
        ),
      ],
    );
  }
}
