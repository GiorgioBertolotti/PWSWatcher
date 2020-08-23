import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisibilitySettingsCard extends StatefulWidget {
  final ThemeService themeService = getIt<ThemeService>();

  @override
  _VisibilitySettingsCardState createState() => _VisibilitySettingsCardState();
}

class _VisibilitySettingsCardState extends State<VisibilitySettingsCard> {
  var visibilityCurrentWeatherIcon = true;
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
                "Visibility settings",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SwitchListTile(
              title: Text(
                "Current weather icon visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityCurrentWeatherIcon,
              onChanged: (value) async {
                setState(() {
                  visibilityCurrentWeatherIcon = value;
                });

                _setVisibility("visibilityCurrentWeatherIcon", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Update timer visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityUpdateTimer,
              onChanged: (value) async {
                setState(() {
                  visibilityUpdateTimer = value;
                });

                _setVisibility("visibilityUpdateTimer", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Wind speed visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityWindSpeed,
              onChanged: (value) async {
                setState(() {
                  visibilityWindSpeed = value;
                });

                _setVisibility("visibilityWindSpeed", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Pressure visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityPressure,
              onChanged: (value) async {
                setState(() {
                  visibilityPressure = value;
                });

                _setVisibility("visibilityPressure", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Wind direction visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityWindDirection,
              onChanged: (value) async {
                setState(() {
                  visibilityWindDirection = value;
                });

                _setVisibility("visibilityWindDirection", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Humidity visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityHumidity,
              onChanged: (value) async {
                setState(() {
                  visibilityHumidity = value;
                });

                _setVisibility("visibilityHumidity", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Temperature (small) visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityTemperature,
              onChanged: (value) async {
                setState(() {
                  visibilityTemperature = value;
                });

                _setVisibility("visibilityTemperature", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Wind chill visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityWindChill,
              onChanged: (value) async {
                setState(() {
                  visibilityWindChill = value;
                });

                _setVisibility("visibilityWindChill", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Rain visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityRain,
              onChanged: (value) async {
                setState(() {
                  visibilityRain = value;
                });

                _setVisibility("visibilityRain", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Dew visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityDew,
              onChanged: (value) async {
                setState(() {
                  visibilityDew = value;
                });

                _setVisibility("visibilityDew", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Sunrise hour visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilitySunrise,
              onChanged: (value) async {
                setState(() {
                  visibilitySunrise = value;
                });

                _setVisibility("visibilitySunrise", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Sunset hour visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilitySunset,
              onChanged: (value) async {
                setState(() {
                  visibilitySunset = value;
                });

                _setVisibility("visibilitySunset", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Moonrise hour visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityMoonrise,
              onChanged: (value) async {
                setState(() {
                  visibilityMoonrise = value;
                });

                _setVisibility("visibilityMoonrise", value);
              },
            ),
            SwitchListTile(
              title: Text(
                "Moonset hour visibility",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              value: visibilityMoonset,
              onChanged: (value) async {
                setState(() {
                  visibilityMoonset = value;
                });

                _setVisibility("visibilityMoonset", value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _setVisibility(String name, bool value) async {
    Provider.of<ApplicationState>(
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
        visibilityCurrentWeatherIcon =
            prefs.getBool("visibilityCurrentWeatherIcon") ?? true;
        visibilityUpdateTimer = prefs.getBool("visibilityUpdateTimer") ?? true;
        visibilityWindSpeed = prefs.getBool("visibilityWindSpeed") ?? true;
        visibilityPressure = prefs.getBool("visibilityPressure") ?? true;
        visibilityWindDirection =
            prefs.getBool("visibilityWindDirection") ?? true;
        visibilityHumidity = prefs.getBool("visibilityHumidity") ?? true;
        visibilityTemperature = prefs.getBool("visibilityTemperature") ?? true;
        visibilityWindChill = prefs.getBool("visibilityWindChill") ?? true;
        visibilityRain = prefs.getBool("visibilityRain") ?? true;
        visibilityDew = prefs.getBool("visibilityDew") ?? true;
        visibilitySunrise = prefs.getBool("visibilitySunrise") ?? true;
        visibilitySunset = prefs.getBool("visibilitySunset") ?? true;
        visibilityMoonrise = prefs.getBool("visibilityMoonrise") ?? true;
        visibilityMoonset = prefs.getBool("visibilityMoonset") ?? true;
      });
    } catch (e) {
      print(e);
    }
  }
}
