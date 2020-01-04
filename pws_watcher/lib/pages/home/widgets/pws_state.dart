import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/detail/detail.dart';
import 'package:pws_watcher/pages/home/widgets/update_timer.dart';
import 'package:pws_watcher/pages/home/widgets/variable_row.dart';
import 'package:pws_watcher/services/parsing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/model/source.dart';
import 'dart:async';

class PWSStatePage extends StatefulWidget {
  PWSStatePage(this.source);

  final Source source;

  @override
  _PWSStatePageState createState() => _PWSStatePageState();
}

class _PWSStatePageState extends State<PWSStatePage> {
  GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  ParsingService parsingService;
  Source _source;

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

  bool _first = true;

  @override
  void initState() {
    super.initState();
    _source = widget.source;
    _updatePreferences();
  }

  @override
  Widget build(BuildContext context) {
    if (_first) {
      _first = false;
      parsingService = ParsingService(
          _source, Provider.of<ApplicationState>(context, listen: false));
    }
    if (Provider.of<ApplicationState>(context, listen: false)
        .updatePreferences) {
      Provider.of<ApplicationState>(context, listen: false).updatePreferences =
          false;
      _updatePreferences();
      parsingService.setApplicationState(
          Provider.of<ApplicationState>(context, listen: false));
    }
    if (_source != widget.source) {
      _source = widget.source;
      parsingService.setSource(_source);
    }
    return StreamBuilder<Object>(
        stream: parsingService.variables$,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).accentColor,
              key: _refreshKey,
              onRefresh: _refresh,
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                shrinkWrap: true,
                children: <Widget>[
                  _buildUpdateIndicator(_source),
                  SizedBox(height: 50.0),
                  Center(
                    child: Container(
                      height: 100.0,
                      width: 100.0,
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ),
            );
          }
          Map<String, String> data = snapshot.data as Map<String, String>;
          var location = data["location"] ?? "Location";
          var datetime = data["datetime"] ?? "--/--/---- --:--:--";

          var windspeed = data["windspeed"] ?? "-";
          var press = data["press"] ?? "-";
          var winddir = data["winddir"] ?? "-";
          var humidity = data["humidity"] ?? "-";
          var temperature = data["temperature"] ?? "-";
          var windchill = data["windchill"] ?? "-";
          var rain = data["rain"] ?? "-";
          var dew = data["dew"] ?? "-";
          var sunrise = data["sunrise"] ?? "--:--";
          var sunset = data["sunset"] ?? "--:--";
          var moonrise = data["moonrise"] ?? "--:--";
          var moonset = data["moonset"] ?? "--:--";

          var windUnit = data["windUnit"] ?? "km/h";
          var rainUnit = data["rainUnit"] ?? "mm";
          var pressUnit = data["pressUnit"] ?? "mb";
          var tempUnit = data["tempUnit"] ?? "°C";
          var dewUnit = data["dewUnit"] ?? "°";
          var humUnit = data["humUnit"] ?? "%";
          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).accentColor,
            key: _refreshKey,
            onRefresh: _refresh,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              shrinkWrap: true,
              children: <Widget>[
                _buildUpdateIndicator(_source),
                SizedBox(height: 20.0),
                Center(
                  child: Text(
                    "$location",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "$datetime",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                SizedBox(height: 50.0),
                Center(
                  child: Text(
                    "$temperature$tempUnit",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                SizedBox(height: 50.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DoubleVariableRow(
                    "Wind speed",
                    "assets/images/windspeed.svg",
                    windspeed,
                    windUnit,
                    "Pressure",
                    "assets/images/barometer.svg",
                    press,
                    pressUnit,
                    visibilityLeft: visibilityWindSpeed,
                    visibilityRight: visibilityPressure,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DoubleVariableRow(
                    "Wind direction",
                    "assets/images/winddir.svg",
                    winddir,
                    "",
                    "Humidity",
                    "assets/images/humidity.svg",
                    humidity,
                    humUnit,
                    visibilityLeft: visibilityWindDirection,
                    visibilityRight: visibilityHumidity,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DoubleVariableRow(
                    "Temperature",
                    "assets/images/temperature.svg",
                    temperature,
                    tempUnit,
                    "Wind chill",
                    "assets/images/windchill.svg",
                    windchill,
                    tempUnit,
                    visibilityLeft: visibilityTemperature,
                    visibilityRight: visibilityWindChill,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DoubleVariableRow(
                    "Rain",
                    "assets/images/rain.svg",
                    rain,
                    rainUnit,
                    "Dew",
                    "assets/images/dew.svg",
                    dew,
                    dewUnit,
                    visibilityLeft: visibilityRain,
                    visibilityRight: visibilityDew,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DoubleVariableRow(
                    "Sunrise",
                    "assets/images/sunrise.svg",
                    sunrise,
                    "",
                    "Moonrise",
                    "assets/images/moonrise.svg",
                    moonrise,
                    "",
                    visibilityLeft: visibilitySunrise,
                    visibilityRight: visibilityMoonrise,
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DoubleVariableRow(
                    "Sunset",
                    "assets/images/sunset.svg",
                    sunset,
                    "",
                    "Moonset",
                    "assets/images/moonset.svg",
                    moonset,
                    "",
                    visibilityLeft: visibilitySunset,
                    visibilityRight: visibilityMoonset,
                  ),
                ),
                SizedBox(height: 40.0),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "SEE ALL",
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: _openDetailPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _refresh() async {
    _refreshKey.currentState.show();
    parsingService.setSource(_source);
    await Future.delayed(Duration(milliseconds: Random().nextInt(1000) + 500));
  }

  dynamic _buildUpdateIndicator(Source source) {
    if (source.autoUpdateInterval != null) {
      if (source.autoUpdateInterval == 0) {
        return Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            tooltip: "Update",
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).accentColor,
            ),
            padding: EdgeInsets.all(0),
            onPressed: _refresh,
          ),
        );
      } else if (visibilityUpdateTimer) {
        return Align(
          alignment: Alignment.topLeft,
          child: Tooltip(
            message: "Update timer",
            child: UpdateTimer(
              Duration(seconds: source.autoUpdateInterval),
              () => parsingService.setSource(_source),
            ),
          ),
        );
      } else
        return Container();
    } else
      return Container();
  }

  _openDetailPage() async {
    if (parsingService.allDataSubject.value != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Provider<ApplicationState>.value(
            value: Provider.of<ApplicationState>(context, listen: false),
            child: DetailPage(parsingService.allDataSubject.value),
          ),
        ),
      );
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Can't show more informations."),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.deepOrange,
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<Null> _updatePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    try {
      setState(() {});
    } catch (Exception) {}
  }
}
