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
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: Text(
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
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
                Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ).updatePreferences = true;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("visibilityMoonset", value);
              },
            ),
          ],
        ),
      ),
    );
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
    });
  }
}
