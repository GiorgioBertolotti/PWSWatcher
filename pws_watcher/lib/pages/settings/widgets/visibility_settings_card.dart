import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/custom_data.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:pws_watcher/pages/settings/widgets/custom_data_dialog.dart';
import 'package:pws_watcher/pages/settings/widgets/delete_custom_data_dialog.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisibilitySettingsCard extends StatefulWidget {
  final ThemeService? themeService = getIt<ThemeService>();

  @override
  _VisibilitySettingsCardState createState() => _VisibilitySettingsCardState();
}

class _VisibilitySettingsCardState extends State<VisibilitySettingsCard> {
  bool _visibilityCurrentWeatherIcon = true;
  bool _visibilityUpdateTimer = true;
  bool _visibilityWindSpeed = true;
  bool _visibilityPressure = true;
  bool _visibilityWindDirection = true;
  bool _visibilityHumidity = true;
  bool _visibilityTemperature = true;
  bool _visibilityWindChill = true;
  bool _visibilityRain = true;
  bool _visibilityDew = true;
  bool _visibilitySunrise = true;
  bool _visibilitySunset = true;
  bool _visibilityMoonrise = true;
  bool _visibilityMoonset = true;
  List<CustomData> _customData = [];

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 24.0),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Visibility",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Current weather icon visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityCurrentWeatherIcon,
            onChanged: (value) async {
              setState(() {
                _visibilityCurrentWeatherIcon = value;
              });

              _setVisibility("visibilityCurrentWeatherIcon", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Update timer visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityUpdateTimer,
            onChanged: (value) async {
              setState(() {
                _visibilityUpdateTimer = value;
              });

              _setVisibility("visibilityUpdateTimer", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Wind speed visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityWindSpeed,
            onChanged: (value) async {
              setState(() {
                _visibilityWindSpeed = value;
              });

              _setVisibility("visibilityWindSpeed", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Pressure visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityPressure,
            onChanged: (value) async {
              setState(() {
                _visibilityPressure = value;
              });

              _setVisibility("visibilityPressure", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Wind direction visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityWindDirection,
            onChanged: (value) async {
              setState(() {
                _visibilityWindDirection = value;
              });

              _setVisibility("visibilityWindDirection", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Humidity visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityHumidity,
            onChanged: (value) async {
              setState(() {
                _visibilityHumidity = value;
              });

              _setVisibility("visibilityHumidity", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Temperature (small) visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityTemperature,
            onChanged: (value) async {
              setState(() {
                _visibilityTemperature = value;
              });

              _setVisibility("visibilityTemperature", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Wind chill visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityWindChill,
            onChanged: (value) async {
              setState(() {
                _visibilityWindChill = value;
              });

              _setVisibility("visibilityWindChill", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Rain visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityRain,
            onChanged: (value) async {
              setState(() {
                _visibilityRain = value;
              });

              _setVisibility("visibilityRain", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Dew visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityDew,
            onChanged: (value) async {
              setState(() {
                _visibilityDew = value;
              });

              _setVisibility("visibilityDew", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Sunrise hour visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilitySunrise,
            onChanged: (value) async {
              setState(() {
                _visibilitySunrise = value;
              });

              _setVisibility("visibilitySunrise", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Sunset hour visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilitySunset,
            onChanged: (value) async {
              setState(() {
                _visibilitySunset = value;
              });

              _setVisibility("visibilitySunset", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Moonrise hour visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityMoonrise,
            onChanged: (value) async {
              setState(() {
                _visibilityMoonrise = value;
              });

              _setVisibility("visibilityMoonrise", value);
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(
              "Moonset hour visibility",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            value: _visibilityMoonset,
            onChanged: (value) async {
              setState(() {
                _visibilityMoonset = value;
              });

              _setVisibility("visibilityMoonset", value);
            },
          ),
          _buildCustomDataList(),
          _buildAddCustomDataButton(),
        ],
      ),
    );
  }

  // FUNCTIONS

  Future<Null> _setVisibility(String name, bool value) async {
    provider.Provider.of<ApplicationState>(
      context,
      listen: false,
    ).updatePreferences = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(name, value);
  }

  Future<Null> _getSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _visibilityCurrentWeatherIcon =
            prefs.getBool("visibilityCurrentWeatherIcon") ?? true;
        _visibilityUpdateTimer = prefs.getBool("visibilityUpdateTimer") ?? true;
        _visibilityWindSpeed = prefs.getBool("visibilityWindSpeed") ?? true;
        _visibilityPressure = prefs.getBool("visibilityPressure") ?? true;
        _visibilityWindDirection =
            prefs.getBool("visibilityWindDirection") ?? true;
        _visibilityHumidity = prefs.getBool("visibilityHumidity") ?? true;
        _visibilityTemperature = prefs.getBool("visibilityTemperature") ?? true;
        _visibilityWindChill = prefs.getBool("visibilityWindChill") ?? true;
        _visibilityRain = prefs.getBool("visibilityRain") ?? true;
        _visibilityDew = prefs.getBool("visibilityDew") ?? true;
        _visibilitySunrise = prefs.getBool("visibilitySunrise") ?? true;
        _visibilitySunset = prefs.getBool("visibilitySunset") ?? true;
        _visibilityMoonrise = prefs.getBool("visibilityMoonrise") ?? true;
        _visibilityMoonset = prefs.getBool("visibilityMoonset") ?? true;

        try {
          _customData.clear();
          List<String> customDataJSON = prefs.getStringList("customData") ?? [];

          // Populate CustomData list from a list of JSONs stored in shared prefs
          for (String dataJSON in customDataJSON) {
            dynamic data = jsonDecode(dataJSON);
            IconData? icon = data["icon"] != null
                ? IconData(
                    data["icon"]["codePoint"],
                    fontFamily: data["icon"]["fontFamily"],
                    fontPackage: data["icon"]["fontPackage"],
                    matchTextDirection: data["icon"]["matchTextDirection"],
                  )
                : null;

            _customData.add(CustomData(
              name: data["name"],
              unit: data["unit"],
              icon: icon,
            ));
          }
        } catch (e) {
          _customData.clear();

          // If there's an exception clear the settings in preferences
          prefs.remove("customData");
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _addCustomData() async {
    CustomData? customData = await showDialog(
      context: context,
      builder: (ctx) => CustomDataDialog(
        mode: CustomDataDialogMode.ADD,
        theme: Theme.of(context),
      ),
    );

    if (customData != null) {
      setState(() {
        _customData.add(customData);
      });

      provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      ).updatePreferences = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("customData", _encodeCustomData());
    }
  }

  _editCustomData(int index) async {
    CustomData? customData = await showDialog(
      context: context,
      builder: (BuildContext ctx) => CustomDataDialog(
        mode: CustomDataDialogMode.EDIT,
        original: _customData[index],
        theme: Theme.of(context),
      ),
    );

    if (customData != null) {
      setState(() {
        _customData[index].name = customData.name;
        _customData[index].unit = customData.unit;
        _customData[index].icon = customData.icon;
      });

      provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      ).updatePreferences = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("customData", _encodeCustomData());
    }
  }

  _removeCustomData(int index) async {
    bool? delete = await showDialog(
      context: context,
      builder: (BuildContext ctx) => DeleteCustomDataDialog(
        _customData[index],
        context,
      ),
    );

    if (delete != null && delete) {
      setState(() {
        _customData.removeAt(index);
      });

      provider.Provider.of<ApplicationState>(
        context,
        listen: false,
      ).updatePreferences = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList("customData", _encodeCustomData());
    }
  }

  List<String> _encodeCustomData() {
    List<String> customDataJSON = <String>[];

    for (CustomData customData in _customData) {
      String dataJSON = jsonEncode(customData);
      customDataJSON.add(dataJSON);
    }

    return customDataJSON;
  }

  // WIDGETS

  Widget _buildCustomDataList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _customData.length,
      itemBuilder: (ctx, index) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        title: Text(
          _customData[index].name!,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        trailing: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                ),
                onPressed: () => _editCustomData(index),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[700],
                ),
                onPressed: () => _removeCustomData(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCustomDataButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
          bottom: Radius.circular(4.0),
        ),
        color: Theme.of(context).primaryColor,
      ),
      height: 40.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.vertical(
            top: Radius.zero,
            bottom: Radius.circular(4.0),
          ),
          onTap: _addCustomData,
          child: Center(
            child: Text(
              'Add custom data',
              style: Theme.of(context).textTheme.button!.copyWith(
                    color: Theme.of(context).accentColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
