import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateSettingsCard extends StatefulWidget {
  final ThemeService? themeService = getIt<ThemeService>();

  @override
  _DateSettingsCardState createState() => _DateSettingsCardState();
}

// TODO: Move this in the add PWS dialog
class _DateSettingsCardState extends State<DateSettingsCard> {
  bool _first = true;

  final _parsingDateFormatController = TextEditingController();

  FocusNode _parsingDateFormatFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    if (_first) {
      _first = false;
      ApplicationState appState = provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      );

      if (appState.parsingDateFormat != null) {
        _parsingDateFormatController.text = appState.parsingDateFormat!;
      }
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Dates",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Text(
              "Source date format:",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10.0),
            _dateFormatInput(),
            SizedBox(height: 20.0),
            Text(
              "* You can specify which is the date format in the sources to improve date parsing in app and widget.\ndd = day of month\nMM = month\nyyyy = year\nyy = year (short)",
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(height: 10.0),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateFormatInput() {
    return TextFormField(
      controller: _parsingDateFormatController,
      decoration: InputDecoration(
        labelText: "Date format",
        border: OutlineInputBorder(),
        hintText: "dd/MM/yyyy",
      ),
      maxLines: 1,
      focusNode: _parsingDateFormatFocusNode,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _save(),
    );
  }

  Future<String?> _save() async {
    provider.Provider.of<ApplicationState>(
      context,
      listen: false,
    ).updatePreferences = true;

    var parsingDateFormat = _parsingDateFormatController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (parsingDateFormat.trim().isEmpty) {
      provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      ).parsingDateFormat = null;
      prefs.remove("parsingDateFormat");
    } else {
      provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      ).parsingDateFormat = parsingDateFormat;
      prefs.setString("parsingDateFormat", parsingDateFormat.trim());
    }
    setState(() {});
  }
}
