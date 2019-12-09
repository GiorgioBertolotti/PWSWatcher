import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/settings/widgets/add_source_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/delete_source_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/edit_source_dialog.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:pws_watcher/model/source.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

class SettingsPage extends StatefulWidget {
  final ThemeService themeService = getIt<ThemeService>();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _fabKey = GlobalKey<FormState>();

  var visibilityUpdateTimer = true;
  var visibilityWindSpeed = true;
  var visibilityPressure = true;
  var visibilityWindDirection = true;
  var visibilityHumidity = true;
  var visibilityTemperature = true;
  var visibilityWindChill = true;
  var visibilityRain = true;
  var visibilityDew = true;
  var visibilitySunrise = true;
  var visibilitySunset = true;
  var visibilityMoonrise = true;
  var visibilityMoonset = true;
  double refreshInterval = 15;
  bool _first = true;

  List<Source> _sources = List();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var _themeSelection = [true, false, false, false, false];
  var _windUnitSelection = [true, false, false, false];
  var _rainUnitSelection = [true, false];
  var _pressUnitSelection = [true, false, false];
  var _tempUnitSelection = [true, false];
  var _dewUnitSelection = [true, false];

  @override
  void initState() {
    super.initState();
    _getSettings();
    _retrieveSources();
  }

  Future<bool> _onWillPop() async {
    //triggered on device's back button click
    if (_sources.length == 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            "You should add a source in order to navigate to the home page."),
      ));
      return false;
    }
    Provider.of<ApplicationState>(context).settingsOpen = false;
    setState(() {
      Provider.of<ApplicationState>(context).updateSources = true;
    });
    return true;
  }

  void closeSettings() {
    if (_sources.length == 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            "You should add a source in order to navigate to the home page."),
      ));
      return;
    }
    //triggered on AppBar back button click
    Provider.of<ApplicationState>(context).settingsOpen = false;
    Navigator.of(context).pop(false);
    setState(() {
      Provider.of<ApplicationState>(context).updateSources = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_first) {
      _first = false;
      setState(() {
        _themeSelection = [
          widget.themeService.activeTheme == "day",
          widget.themeService.activeTheme == "evening",
          widget.themeService.activeTheme == "night",
          widget.themeService.activeTheme == "grey",
          widget.themeService.activeTheme == "blacked",
        ];
        _windUnitSelection = [
          Provider.of<ApplicationState>(context).prefWindUnit == "km/h",
          Provider.of<ApplicationState>(context).prefWindUnit == "mph",
          Provider.of<ApplicationState>(context).prefWindUnit == "kts",
          Provider.of<ApplicationState>(context).prefWindUnit == "m/s",
        ];
        _rainUnitSelection = [
          Provider.of<ApplicationState>(context).prefRainUnit == "mm",
          Provider.of<ApplicationState>(context).prefRainUnit == "in",
        ];
        _pressUnitSelection = [
          Provider.of<ApplicationState>(context).prefPressUnit == "hPa",
          Provider.of<ApplicationState>(context).prefPressUnit == "mb",
          Provider.of<ApplicationState>(context).prefPressUnit == "inHg",
        ];
        _tempUnitSelection = [
          Provider.of<ApplicationState>(context).prefTempUnit == "°C",
          Provider.of<ApplicationState>(context).prefTempUnit == "°F",
        ];
        _dewUnitSelection = [
          Provider.of<ApplicationState>(context).prefDewUnit == "°C",
          Provider.of<ApplicationState>(context).prefDewUnit == "°F",
        ];
      });
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ListTileTheme(
        iconColor: Theme.of(context).iconTheme.color,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            brightness: Brightness.dark,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => closeSettings(),
            ),
            title: Text(
              "Settings",
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addSource,
            elevation: 2,
            icon: Icon(
              Icons.add,
            ),
            label: Text(
              "add",
            ),
            key: _fabKey,
          ),
          body: Builder(
            builder: (context) => ListView(
              children: <Widget>[
                Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const ListTile(
                          title: Text(
                            'Theme settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              ToggleButtons(
                                children: [
                                  _themeToggleButton("Day", Colors.lightBlue),
                                  _themeToggleButton(
                                      "Evening", Colors.deepOrange),
                                  _themeToggleButton(
                                      "Night", Colors.deepPurple),
                                  _themeToggleButton("Grey", Colors.blueGrey),
                                  _themeToggleButton("Blacked", Colors.black),
                                ],
                                onPressed: (int index) async {
                                  for (int buttonIndex = 0;
                                      buttonIndex < _themeSelection.length;
                                      buttonIndex++) {
                                    if (buttonIndex == index) {
                                      _themeSelection[buttonIndex] = true;
                                    } else {
                                      _themeSelection[buttonIndex] = false;
                                    }
                                  }
                                  switch (index) {
                                    case 0:
                                      widget.themeService.setTheme("day");
                                      break;
                                    case 1:
                                      widget.themeService.setTheme("evening");
                                      break;
                                    case 2:
                                      widget.themeService.setTheme("night");
                                      break;
                                    case 3:
                                      widget.themeService.setTheme("grey");
                                      break;
                                    case 4:
                                      widget.themeService.setTheme("blacked");
                                      break;
                                  }
                                  setState(() {});
                                },
                                isSelected: _themeSelection,
                              ),
                            ],
                          ),
                        ),
                        const ListTile(
                          title: Text(
                            'Units settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text("Wind speed unit",
                            style: TextStyle(fontSize: 16.0)),
                        SizedBox(height: 10.0),
                        _windSpeedUnitSelector(),
                        SizedBox(height: 20.0),
                        Text("Rain unit", style: TextStyle(fontSize: 16.0)),
                        SizedBox(height: 10.0),
                        _rainUnitSelector(),
                        SizedBox(height: 20.0),
                        Text("Pressure unit", style: TextStyle(fontSize: 16.0)),
                        SizedBox(height: 10.0),
                        _pressUnitSelector(),
                        SizedBox(height: 20.0),
                        Text("Temperature unit",
                            style: TextStyle(fontSize: 16.0)),
                        SizedBox(height: 10.0),
                        _tempUnitSelector(),
                        SizedBox(height: 20.0),
                        Text("Dew point unit",
                            style: TextStyle(fontSize: 16.0)),
                        SizedBox(height: 10.0),
                        _dewUnitSelector(),
                        SizedBox(height: 20.0),
                        Text(
                            "* Some input source formats may not guarantee the correct functioning of the unit conversion.",
                            style: TextStyle(color: Colors.grey)),
                        const ListTile(
                          title: Text(
                            'Visibility settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SwitchListTile(
                          title: Text("Update timer visibility"),
                          value: visibilityUpdateTimer,
                          onChanged: (value) async {
                            setState(() {
                              visibilityUpdateTimer = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityUpdateTimer", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Wind speed visibility"),
                          value: visibilityWindSpeed,
                          onChanged: (value) async {
                            setState(() {
                              visibilityWindSpeed = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityWindSpeed", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Pressure visibility"),
                          value: visibilityPressure,
                          onChanged: (value) async {
                            setState(() {
                              visibilityPressure = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityPressure", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Wind direction visibility"),
                          value: visibilityWindDirection,
                          onChanged: (value) async {
                            setState(() {
                              visibilityWindDirection = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityWindDirection", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Humidity visibility"),
                          value: visibilityHumidity,
                          onChanged: (value) async {
                            setState(() {
                              visibilityHumidity = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityHumidity", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Temperature (small) visibility"),
                          value: visibilityTemperature,
                          onChanged: (value) async {
                            setState(() {
                              visibilityTemperature = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityTemperature", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Wind chill visibility"),
                          value: visibilityWindChill,
                          onChanged: (value) async {
                            setState(() {
                              visibilityWindChill = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityWindChill", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Rain visibility"),
                          value: visibilityRain,
                          onChanged: (value) async {
                            setState(() {
                              visibilityRain = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityRain", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Dew visibility"),
                          value: visibilityDew,
                          onChanged: (value) async {
                            setState(() {
                              visibilityDew = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityDew", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Sunrise hour visibility"),
                          value: visibilitySunrise,
                          onChanged: (value) async {
                            setState(() {
                              visibilitySunrise = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilitySunrise", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Sunset hour visibility"),
                          value: visibilitySunset,
                          onChanged: (value) async {
                            setState(() {
                              visibilitySunset = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilitySunset", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Moonrise hour visibility"),
                          value: visibilityMoonrise,
                          onChanged: (value) async {
                            setState(() {
                              visibilityMoonrise = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityMoonrise", value);
                          },
                        ),
                        SwitchListTile(
                          title: Text("Moonset hour visibility"),
                          value: visibilityMoonset,
                          onChanged: (value) async {
                            setState(() {
                              visibilityMoonset = value;
                            });
                            Provider.of<ApplicationState>(context)
                                .updatePreferences = true;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool("visibilityMoonset", value);
                          },
                        ),
                        const ListTile(
                          title: Text(
                            'Widget settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Widget refresh interval (min):",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                '${refreshInterval.toInt()}',
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Slider(
                                value: refreshInterval,
                                onChanged: (value) async {
                                  setState(() => refreshInterval = value);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setInt(
                                      "widget_refresh_interval", value.toInt());
                                },
                                min: 1,
                                max: 60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.only(bottom: 65),
                  child: ListView.builder(
                    physics: ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _sources.length,
                    itemBuilder: (context, position) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        child: ListTile(
                            title: Text(
                              _sources[position].name,
                              style: TextStyle(fontSize: 20.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _sources[position].url,
                              style: TextStyle(fontSize: 12.0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                    ),
                                    onPressed: () {
                                      _editSource(position);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red[700],
                                    ),
                                    onPressed: () {
                                      _deleteSource(position);
                                    },
                                  ),
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _windSpeedUnitSelector() {
    return Container(
      height: 60,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ToggleButtons(
              children: [
                _unitToggleButton("km/h"),
                _unitToggleButton("mph"),
                _unitToggleButton("kts"),
                _unitToggleButton("m/s"),
              ],
              onPressed: (int index) async {
                String unit = await _unitSelectorCallback(
                    index, _windUnitSelection, ["km/h", "mph", "kts", "m/s"]);
                Provider.of<ApplicationState>(context).prefWindUnit = unit;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (unit == null)
                  prefs.remove("prefWindUnit");
                else
                  prefs.setString("prefWindUnit", unit);
                setState(() {});
              },
              isSelected: _windUnitSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rainUnitSelector() {
    return Container(
      height: 60,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ToggleButtons(
              children: [
                _unitToggleButton("mm"),
                _unitToggleButton("in"),
              ],
              onPressed: (int index) async {
                String unit = await _unitSelectorCallback(
                    index, _rainUnitSelection, ["mm", "in"]);
                Provider.of<ApplicationState>(context).prefRainUnit = unit;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (unit == null)
                  prefs.remove("prefRainUnit");
                else
                  prefs.setString("prefRainUnit", unit);
                setState(() {});
              },
              isSelected: _rainUnitSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pressUnitSelector() {
    return Container(
      height: 60,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ToggleButtons(
              children: [
                _unitToggleButton("hPa"),
                _unitToggleButton("mb"),
                _unitToggleButton("inHg"),
              ],
              onPressed: (int index) async {
                String unit = await _unitSelectorCallback(
                    index, _pressUnitSelection, ["hPa", "mb", "inHg"]);
                Provider.of<ApplicationState>(context).prefPressUnit = unit;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (unit == null)
                  prefs.remove("prefPressUnit");
                else
                  prefs.setString("prefPressUnit", unit);
                setState(() {});
              },
              isSelected: _pressUnitSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tempUnitSelector() {
    return Container(
      height: 60,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ToggleButtons(
              children: [
                _unitToggleButton("°C"),
                _unitToggleButton("°F"),
              ],
              onPressed: (int index) async {
                String unit = await _unitSelectorCallback(
                    index, _tempUnitSelection, ["°C", "°F"]);
                Provider.of<ApplicationState>(context).prefTempUnit = unit;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (unit == null)
                  prefs.remove("prefTempUnit");
                else
                  prefs.setString("prefTempUnit", unit);
                setState(() {});
              },
              isSelected: _tempUnitSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dewUnitSelector() {
    return Container(
      height: 60,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ToggleButtons(
              children: [
                _unitToggleButton("°C"),
                _unitToggleButton("°F"),
              ],
              onPressed: (int index) async {
                String unit = await _unitSelectorCallback(
                    index, _dewUnitSelection, ["°C", "°F"]);
                Provider.of<ApplicationState>(context).prefDewUnit = unit;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (unit == null)
                  prefs.remove("prefDewUnit");
                else
                  prefs.setString("prefDewUnit", unit);
                setState(() {});
              },
              isSelected: _dewUnitSelection,
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _unitSelectorCallback(
      int index, List<bool> selectionList, List<String> units) async {
    Provider.of<ApplicationState>(context).updatePreferences = true;
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

  Widget _themeToggleButton(String tooltip, Color color) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: EdgeInsets.all(8.0),
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _unitToggleButton(String unit) {
    return Text(
      unit,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        color:
            widget.themeService.themeSubject.value.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
      ),
    );
  }

  _addSource() async {
    var source = await showDialog(
      context: context,
      builder: (ctx) => Provider<ApplicationState>.value(
        value: Provider.of<ApplicationState>(context),
        child: AddSourceDialog(context),
      ),
    );
    if (source != null && source is Source) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sources.add(source);
      List<String> sourcesJSON = List();
      for (Source source in _sources) {
        String sourceJSON = jsonEncode(source);
        sourcesJSON.add(sourceJSON);
      }
      prefs.setStringList("sources", sourcesJSON);
      prefs.setInt("count_id", Provider.of<ApplicationState>(context).countID);
      _retrieveSources();
    }
  }

  _editSource(int position) async {
    var source = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return EditSourceDialog(_sources[position], context);
        });
    if (source != null && source is Source) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sources[position].name = source.name;
      _sources[position].url = source.url;
      _sources[position].autoUpdateInterval = source.autoUpdateInterval;
      List<String> sourcesJSON = List();
      for (Source source in _sources) {
        String sourceJSON = jsonEncode(source);
        sourcesJSON.add(sourceJSON);
      }
      prefs.setStringList("sources", sourcesJSON);
      _retrieveSources();
    }
  }

  _deleteSource(int position) async {
    var delete = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return DeleteSourceDialog(_sources[position], context);
      },
    );
    if (delete != null && delete is bool && delete) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> sourcesJSON = List();
      int index = prefs.getInt("last_used_source") ?? -1;
      if (index == _sources[position].id) prefs.remove("last_used_source");
      _sources.removeAt(position);
      for (Source source in _sources) {
        String sourceJSON = jsonEncode(source);
        sourcesJSON.add(sourceJSON);
      }
      prefs.setStringList("sources", sourcesJSON);
      _retrieveSources();
    }
  }

  Future<Null> _getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      visibilityUpdateTimer = prefs.getBool("visibilityUpdateTimer");
      visibilityWindSpeed = prefs.getBool("visibilityWindSpeed");
      visibilityPressure = prefs.getBool("visibilityPressure");
      visibilityWindDirection = prefs.getBool("visibilityWindDirection");
      visibilityHumidity = prefs.getBool("visibilityHumidity");
      visibilityTemperature = prefs.getBool("visibilityTemperature");
      visibilityWindChill = prefs.getBool("visibilityWindChill");
      visibilityRain = prefs.getBool("visibilityRain");
      visibilityDew = prefs.getBool("visibilityDew");
      visibilitySunrise = prefs.getBool("visibilitySunrise");
      visibilitySunset = prefs.getBool("visibilitySunset");
      visibilityMoonrise = prefs.getBool("visibilityMoonrise");
      visibilityMoonset = prefs.getBool("visibilityMoonset");
      visibilityUpdateTimer ??= true;
      visibilityWindSpeed ??= true;
      visibilityPressure ??= true;
      visibilityWindDirection ??= true;
      visibilityHumidity ??= true;
      visibilityTemperature ??= true;
      visibilityWindChill ??= true;
      visibilityRain ??= true;
      visibilityDew ??= true;
      visibilitySunrise ??= true;
      visibilitySunset ??= true;
      visibilityMoonrise ??= true;
      visibilityMoonset ??= true;
      refreshInterval = prefs.getInt("widget_refresh_interval").toDouble();
    });
  }

  _retrieveSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sources = List();
      List<String> sources = prefs.getStringList("sources");
      if (sources == null || sources.length == 0) {
        _showCoachMarkFAB();
      } else
        for (String sourceJSON in sources) {
          try {
            dynamic source = jsonDecode(sourceJSON);
            _sources.add(Source(source["id"], source["name"], source["url"],
                autoUpdateInterval: (source["autoUpdateInterval"] != null)
                    ? source["autoUpdateInterval"]
                    : 0));
          } catch (Exception) {
            prefs.setStringList("sources", null);
          }
        }
    });
  }

  _showCoachMarkFAB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool("coach_mark_shown") ?? false)) {
      CoachMark coachMarkFAB = CoachMark();
      RenderBox target = _fabKey.currentContext.findRenderObject();
      Rect markRect = target.localToGlobal(Offset.zero) & target.size;
      markRect = Rect.fromCircle(
          center: markRect.center, radius: markRect.longestSide * 0.6);
      coachMarkFAB.show(
          targetContext: _fabKey.currentContext,
          markRect: markRect,
          children: [
            Center(
                child: Text("Tap here\nto add a source",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    )))
          ],
          duration: null,
          onClose: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("coach_mark_shown", true);
          });
    }
  }
}
