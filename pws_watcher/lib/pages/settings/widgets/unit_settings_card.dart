import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitSettingsCard extends StatefulWidget {
  final ThemeService? themeService = getIt<ThemeService>();

  @override
  _UnitSettingsCardState createState() => _UnitSettingsCardState();
}

class _UnitSettingsCardState extends State<UnitSettingsCard> {
  bool _first = true;
  var _windUnitSelection = [true, false, false, false];
  var _rainUnitSelection = [true, false];
  var _pressUnitSelection = [true, false, false];
  var _tempUnitSelection = [true, false];
  var _dewUnitSelection = [true, false];

  @override
  Widget build(BuildContext context) {
    if (_first) {
      _first = false;
      ApplicationState appState = provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      );
      _windUnitSelection = [
        appState.prefWindUnit == "km/h",
        appState.prefWindUnit == "mph",
        appState.prefWindUnit == "kts",
        appState.prefWindUnit == "m/s",
      ];
      _rainUnitSelection = [
        appState.prefRainUnit == "mm",
        appState.prefRainUnit == "in",
      ];
      _pressUnitSelection = [
        appState.prefPressUnit == "hPa",
        appState.prefPressUnit == "mb",
        appState.prefPressUnit == "inHg",
      ];
      _tempUnitSelection = [
        appState.prefTempUnit == "°C",
        appState.prefTempUnit == "°F",
      ];
      _dewUnitSelection = [
        appState.prefDewUnit == "°C",
        appState.prefDewUnit == "°F",
      ];
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
                "Units of measure",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Text(
              "Wind speed unit:",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10.0),
            _windSpeedUnitSelector(),
            SizedBox(height: 20.0),
            Text(
              "Rain unit:",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10.0),
            _rainUnitSelector(),
            SizedBox(height: 20.0),
            Text(
              "Pressure unit:",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10.0),
            _pressUnitSelector(),
            SizedBox(height: 20.0),
            Text(
              "Temperature unit:",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10.0),
            _tempUnitSelector(),
            SizedBox(height: 20.0),
            Text(
              "Dew point unit:",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 10.0),
            _dewUnitSelector(),
            SizedBox(height: 20.0),
            Text(
              "* Some input source formats may not guarantee the correct functioning of the unit conversion.",
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _windSpeedUnitSelector() {
    return Container(
      alignment: Alignment.center,
      child: ToggleButtons(
        children: [
          _unitToggleButton("km/h"),
          _unitToggleButton("mph"),
          _unitToggleButton("kts"),
          _unitToggleButton("m/s"),
        ],
        onPressed: (int index) async {
          String? unit = await _unitSelectorCallback(
              index, _windUnitSelection, ["km/h", "mph", "kts", "m/s"]);
          provider.Provider.of<ApplicationState>(
            context,
            listen: false,
          ).prefWindUnit = unit;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (unit == null)
            prefs.remove("prefWindUnit");
          else
            prefs.setString("prefWindUnit", unit);
          setState(() {});
        },
        isSelected: _windUnitSelection,
      ),
    );
  }

  Widget _rainUnitSelector() {
    return Container(
      alignment: Alignment.center,
      child: ToggleButtons(
        children: [
          _unitToggleButton("mm"),
          _unitToggleButton("in"),
        ],
        onPressed: (int index) async {
          String? unit = await _unitSelectorCallback(
              index, _rainUnitSelection, ["mm", "in"]);
          provider.Provider.of<ApplicationState>(
            context,
            listen: false,
          ).prefRainUnit = unit;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (unit == null)
            prefs.remove("prefRainUnit");
          else
            prefs.setString("prefRainUnit", unit);
          setState(() {});
        },
        isSelected: _rainUnitSelection,
      ),
    );
  }

  Widget _pressUnitSelector() {
    return Container(
      alignment: Alignment.center,
      child: ToggleButtons(
        children: [
          _unitToggleButton("hPa"),
          _unitToggleButton("mb"),
          _unitToggleButton("inHg"),
        ],
        onPressed: (int index) async {
          String? unit = await _unitSelectorCallback(
              index, _pressUnitSelection, ["hPa", "mb", "inHg"]);
          provider.Provider.of<ApplicationState>(
            context,
            listen: false,
          ).prefPressUnit = unit;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (unit == null)
            prefs.remove("prefPressUnit");
          else
            prefs.setString("prefPressUnit", unit);
          setState(() {});
        },
        isSelected: _pressUnitSelection,
      ),
    );
  }

  Widget _tempUnitSelector() {
    return Container(
      alignment: Alignment.center,
      child: ToggleButtons(
        children: [
          _unitToggleButton("°C"),
          _unitToggleButton("°F"),
        ],
        onPressed: (int index) async {
          String? unit = await _unitSelectorCallback(
              index, _tempUnitSelection, ["°C", "°F"]);
          provider.Provider.of<ApplicationState>(
            context,
            listen: false,
          ).prefTempUnit = unit;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (unit == null)
            prefs.remove("prefTempUnit");
          else
            prefs.setString("prefTempUnit", unit);
          setState(() {});
        },
        isSelected: _tempUnitSelection,
      ),
    );
  }

  Widget _dewUnitSelector() {
    return Container(
      alignment: Alignment.center,
      child: ToggleButtons(
        children: [
          _unitToggleButton("°C"),
          _unitToggleButton("°F"),
        ],
        onPressed: (int index) async {
          String? unit = await _unitSelectorCallback(
              index, _dewUnitSelection, ["°C", "°F"]);
          provider.Provider.of<ApplicationState>(
            context,
            listen: false,
          ).prefDewUnit = unit;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (unit == null)
            prefs.remove("prefDewUnit");
          else
            prefs.setString("prefDewUnit", unit);
          setState(() {});
        },
        isSelected: _dewUnitSelection,
      ),
    );
  }

  Future<String?> _unitSelectorCallback(
    int index,
    List<bool> selectionList,
    List<String> units,
  ) async {
    provider.Provider.of<ApplicationState>(
      context,
      listen: false,
    ).updatePreferences = true;

    if (selectionList[index]) {
      // deselect
      for (int buttonIndex = 0;
          buttonIndex < selectionList.length;
          buttonIndex++) {
        selectionList[buttonIndex] = false;
      }
      return null;
    } else {
      // select
      for (int buttonIndex = 0;
          buttonIndex < selectionList.length;
          buttonIndex++) {
        if (buttonIndex == index) {
          selectionList[buttonIndex] = true;
        } else {
          selectionList[buttonIndex] = false;
        }
      }
      String unit = units[index];
      return unit;
    }
  }

  Widget _unitToggleButton(String unit) {
    ThemeData theme = widget.themeService!.themeSubject.value;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        unit,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: theme != null && theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
      ),
    );
  }
}
