import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/main.dart';
import 'package:pws_watcher/model/source.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

class AddSourceDialog extends StatefulWidget {
  AddSourceDialog(this.context);

  final BuildContext context;

  @override
  _AddSourceDialogState createState() => _AddSourceDialogState();
}

class _AddSourceDialogState extends State<AddSourceDialog> {
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();
  final GlobalKey _urlKey = GlobalKey();
  final GlobalKey _refreshKey = GlobalKey();

  final _addNameController = TextEditingController();
  final _addUrlController = TextEditingController();
  final _addIntervalController = TextEditingController();

  BuildContext _showCaseContext;

  @override
  void initState() {
    super.initState();
    _shouldShowcase().then((shouldShow) {
      if (shouldShow) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(_showCaseContext)
                .startShowCase([_urlKey, _refreshKey]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(builder: (ctx) {
        _showCaseContext = ctx;
        return AlertDialog(
          title: Text("Add PWS"),
          content: Form(
            key: _addFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 75.0,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _addNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "You must set a PWS name.";
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
                  width: MediaQuery.of(context).size.width,
                  child: Showcase(
                    key: _urlKey,
                    title: "Enter URL",
                    description: "Tap on HELP for more info",
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.url,
                        controller: _addUrlController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "You must set a url.";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Realtime file URL",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 75.0,
                  width: MediaQuery.of(context).size.width,
                  child: Showcase(
                    key: _refreshKey,
                    title: "Update interval in seconds",
                    description: "If it's 0 the update will be manual",
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _addIntervalController,
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
              child: Text("Add"),
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                if (_addFormKey.currentState.validate()) {
                  _addFormKey.currentState.save();
                  Source source = Source(
                      Provider.of<ApplicationState>(
                        context,
                        listen: false,
                      ).countID++,
                      _addNameController.text,
                      _addUrlController.text,
                      autoUpdateInterval:
                          int.parse(_addIntervalController.text));
                  PWSWatcher.navigatorKey.currentState.pop(source);
                }
              },
            ),
          ],
        );
      }),
    );
  }

  _openHelp() async {
    const url = "https://bertolotti.dev/PWSWatcher/compatibilities";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch" + url);
    }
  }

  Future<bool> _shouldShowcase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShow = !(prefs.getBool("showcase_2") ?? false);
    if (shouldShow) {
      prefs.setBool("showcase_2", true);
    }
    return shouldShow;
  }
}
