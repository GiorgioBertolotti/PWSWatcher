import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/model/parsing_utilities.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/detail/detail.dart';
import 'package:pws_watcher/pages/home/widgets/pws_state_header.dart';
import 'package:pws_watcher/pages/home/widgets/update_timer.dart';
import 'package:pws_watcher/pages/home/widgets/variable_row.dart';
import 'package:pws_watcher/services/parsing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/model/pws.dart';
import 'dart:async';

import 'pws_temperature_row.dart';
import 'snapshot_preview.dart';

class PWSStatePage extends StatefulWidget {
  PWSStatePage(this.source);

  final PWS source;

  @override
  _PWSStatePageState createState() => _PWSStatePageState();
}

class _PWSStatePageState extends State<PWSStatePage> {
  GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  ParsingService _parsingService;

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

    _updatePreferences();

    _parsingService = ParsingService(
      widget.source,
      Provider.of<ApplicationState>(context, listen: false),
    );
  }

  @override
  void didUpdateWidget(PWSStatePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.source != widget.source) {
      _parsingService.setSource(widget.source);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ApplicationState>(context, listen: false)
        .updatePreferences) {
      Provider.of<ApplicationState>(context, listen: false).updatePreferences =
          false;

      _updatePreferences();

      _parsingService.setApplicationState(
          Provider.of<ApplicationState>(context, listen: false));
    }

    return StreamBuilder<Object>(
        stream: _parsingService.variables$,
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
                  _buildUpdateIndicator(widget.source),
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

          var currentConditionIndex =
              (int.parse(data["currentConditionIndex"] ?? "-1"));
          String currentConditionAsset;
          if (currentConditionIndex >= 0 &&
              currentConditionIndex < currentConditionDesc.length &&
              currentConditionMapping
                  .containsKey(currentConditionDesc[currentConditionIndex]))
            currentConditionAsset = getCurrentConditionAsset(
                currentConditionMapping[
                    currentConditionDesc[currentConditionIndex]]);

          bool thereIsSnapshot = widget.source.snapshotUrl != null &&
              widget.source.snapshotUrl.trim().isNotEmpty;

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
                _buildUpdateIndicator(widget.source),
                SizedBox(height: 20.0),
                PWSStateHeader(
                  location,
                  datetime,
                ),
                SizedBox(height: 30.0),
                PWSTemperatureRow(
                  temperature + tempUnit,
                  asset: visibilityCurrentWeatherIcon
                      ? currentConditionAsset
                      : null,
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
                thereIsSnapshot ? SizedBox(height: 30) : Container(),
                thereIsSnapshot ? SnapshotPreview(widget.source) : Container(),
                SizedBox(height: thereIsSnapshot ? 20.0 : 40.0),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "SEE ALL",
                        maxLines: 1,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Theme.of(context).accentColor),
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

    await _parsingService.updateData(force: true);
  }

  dynamic _buildUpdateIndicator(PWS source) {
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
              () => _parsingService.setSource(widget.source),
            ),
          ),
        );
      } else
        return Container(height: 40.0);
    } else
      return Container(height: 40.0);
  }

  _openDetailPage() async {
    if (_parsingService.allDataSubject.value != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Provider<ApplicationState>.value(
            value: Provider.of<ApplicationState>(context, listen: false),
            child: DetailPage(_parsingService.allDataSubject.value),
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
    } catch (Exception) {}
  }
}
