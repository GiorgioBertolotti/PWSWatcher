import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/main.dart';
import 'package:pws_watcher/model/pws.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

class AddPWSDialog extends StatefulWidget {
  AddPWSDialog(this.context);

  final BuildContext context;

  @override
  _AddPWSDialogState createState() => _AddPWSDialogState();
}

class _AddPWSDialogState extends State<AddPWSDialog> {
  final GlobalKey<FormState> _addFormKey = GlobalKey<FormState>();
  final GlobalKey _urlKey = GlobalKey();
  final GlobalKey _refreshKey = GlobalKey();
  final GlobalKey _snapshotUrlKey = GlobalKey();

  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _intervalController = TextEditingController();
  final _snapshotUrlController = TextEditingController();

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _urlFocusNode = FocusNode();
  FocusNode _intervalFocusNode = FocusNode();
  FocusNode _snapshotUrlFocusNode = FocusNode();

  BuildContext _showCaseContext;

  @override
  void initState() {
    super.initState();
    _shouldShowcase().then((shouldShow) {
      if (shouldShow) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(_showCaseContext)
                .startShowCase([_urlKey, _refreshKey, _snapshotUrlKey]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double inputHeight = 75.0;
    double screenWidth = MediaQuery.of(context).size.width;
    return ShowCaseWidget(
      builder: Builder(builder: (ctx) {
        _showCaseContext = ctx;
        return AlertDialog(
          title: Text("Add PWS"),
          content: Form(
            key: _addFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _nameController,
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
                      focusNode: _nameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) =>
                          FocusScope.of(context).requestFocus(_urlFocusNode),
                    ),
                  ),
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    child: Showcase(
                      key: _urlKey,
                      title: "Enter URL",
                      description: "Tap on HELP for more info",
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.url,
                          controller: _urlController,
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
                          focusNode: _urlFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) => FocusScope.of(context)
                              .requestFocus(_intervalFocusNode),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    child: Showcase(
                      key: _refreshKey,
                      title: "Update interval in seconds",
                      description: "If it's 0 the update will be manual",
                      child: Padding(
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
                          onFieldSubmitted: (value) => FocusScope.of(context)
                              .requestFocus(_snapshotUrlFocusNode),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    child: Showcase(
                      key: _snapshotUrlKey,
                      title: "Webcam snapshot",
                      description: "Enter the URL of a webcam",
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                          onFieldSubmitted: (text) => _addPWS(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
              color: Theme.of(widget.context).primaryColor,
              child: Text("Add"),
              onPressed: _addPWS,
            ),
          ],
        );
      }),
    );
  }

  _addPWS() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_addFormKey.currentState.validate()) {
      _addFormKey.currentState.save();
      PWS source = PWS(
        Provider.of<ApplicationState>(
          context,
          listen: false,
        ).countID++,
        _nameController.text,
        _urlController.text,
        autoUpdateInterval: int.parse(_intervalController.text),
        snapshotUrl: _snapshotUrlController.text,
      );
      PWSWatcher.navigatorKey.currentState.pop(source);
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

  Future<bool> _shouldShowcase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShow = !(prefs.getBool("showcase_2") ?? false);
    if (shouldShow) {
      prefs.setBool("showcase_2", true);
    }
    return shouldShow;
  }
}
