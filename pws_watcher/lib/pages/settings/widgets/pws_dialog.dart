import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/model/pws.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

enum PWSDialogMode { ADD, EDIT }

const double inputHeight = 59.0;

class PWSDialog extends StatefulWidget {
  final PWSDialogMode mode;
  final PWS? source;
  final ThemeData? theme;

  PWSDialog({
    required this.mode,
    this.source,
    this.theme,
  }) {
    if (this.mode == PWSDialogMode.EDIT && this.source == null) {
      throw Exception('If the mode is EDIT you should set the original source');
    }
  }

  @override
  _PWSDialogState createState() => _PWSDialogState();
}

class _PWSDialogState extends State<PWSDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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

  late BuildContext _showCaseContext;

  @override
  void initState() {
    if (widget.mode == PWSDialogMode.EDIT) {
      _nameController.text = widget.source!.name!;
      _urlController.text = widget.source!.url!;
      _intervalController.text = widget.source!.autoUpdateInterval.toString();
      _snapshotUrlController.text = widget.source!.snapshotUrl ?? "";
    }

    _shouldShowcase().then((shouldShow) {
      if (shouldShow) {
        WidgetsBinding.instance!.addPostFrameCallback(
            (_) => ShowCaseWidget.of(_showCaseContext)!.startShowCase([_urlKey, _refreshKey, _snapshotUrlKey]));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final PWSDialogMode mode = widget.mode;

    return ShowCaseWidget(
      builder: Builder(builder: (ctx) {
        _showCaseContext = ctx;
        return AlertDialog(
          title: Text(mode == PWSDialogMode.ADD ? "Add PWS" : "Edit ${widget.source!.name}"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "You must set a PWS name.";
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Name *",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                      focusNode: _nameFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_urlFocusNode),
                    ),
                  ),
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: Showcase(
                      key: _urlKey,
                      title: "Enter URL",
                      description: "Tap on HELP for more info",
                      child: TextFormField(
                        keyboardType: TextInputType.url,
                        controller: _urlController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "You must set a url.";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Realtime file URL *",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                        focusNode: _urlFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_intervalFocusNode),
                      ),
                    ),
                  ),
                  Container(
                    height: inputHeight,
                    width: screenWidth,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: Showcase(
                      key: _refreshKey,
                      title: "Update interval in seconds",
                      description: "If it's 0 the update will be manual",
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _intervalController,
                        validator: (value) {
                          if (value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! < 0)
                            return "Please set a valid interval.";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Update interval (sec.) *",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                        focusNode: _intervalFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_snapshotUrlFocusNode),
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
                      child: TextFormField(
                        keyboardType: TextInputType.url,
                        controller: _snapshotUrlController,
                        decoration: InputDecoration(
                          labelText: "Webcam snapshot URL",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 1,
                        focusNode: _snapshotUrlFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (text) => _save(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).buttonTheme.colorScheme?.primary,
              child: Text("Help"),
              onPressed: _openHelp,
            ),
            FlatButton(
              textColor: Theme.of(context).buttonTheme.colorScheme?.primary,
              child: Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              textColor: Colors.white,
              color: widget.theme!.primaryColor,
              child: Text(mode == PWSDialogMode.ADD ? "Add" : "Edit"),
              onPressed: _save,
            ),
          ],
        );
      }),
    );
  }

  _save() {
    // Closes keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      PWS? source;

      if (widget.mode == PWSDialogMode.ADD) {
        source = PWS(
          provider.Provider.of<ApplicationState>(
            context,
            listen: false,
          ).countID++,
          _nameController.text,
          _urlController.text,
          autoUpdateInterval: int.parse(_intervalController.text),
          snapshotUrl: _snapshotUrlController.text,
        );
      } else {
        source = widget.source;

        source!.name = _nameController.text;
        source.url = _urlController.text;
        source.autoUpdateInterval = int.parse(_intervalController.text);
        source.snapshotUrl = _snapshotUrlController.text;
      }

      Navigator.of(context).pop(source);
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
    // showcase_2 indicates whether the showcase in the PWSDialog should be shown
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShow = !(prefs.getBool("showcase_2") ?? false);

    if (shouldShow) {
      prefs.setBool("showcase_2", true);
    }

    return shouldShow;
  }
}
