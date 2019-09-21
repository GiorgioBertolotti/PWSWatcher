import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/resources/dots_indicator.dart';
import 'package:pws_watcher/resources/state.dart';
import 'package:pws_watcher/ui/detail.dart';
import 'package:pws_watcher/ui/settings.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/model/source.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pws_watcher/resources/connection_status.dart';
import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

class PWSStatePage extends StatefulWidget {
  PWSStatePage(this.source);

  final Source source;

  @override
  _PWSStatePageState createState() => _PWSStatePageState();
}

class _PWSStatePageState extends State<PWSStatePage> {
  Map<String, String> _sourceData;

  var location = "Location";
  var datetime = "--/--/---- --:--:--";

  var windspeed = "-";
  var bar = "-";
  var winddir = "-";
  var humidity = "-";
  var temperature = "-";
  var windchill = "-";
  var rain = "-";
  var dew = "-";
  var sunrise = "--:--";
  var sunset = "--:--";
  var moonrise = "--:--";
  var moonset = "--:--";

  var windunit = "km/h";
  var rainunit = "mm";
  var barunit = "mb";
  var tempunit = "°C";
  var degunit = "°";
  var humunit = "%";

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
    _setVisibilities();
    _retrieveData(widget.source.url);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ApplicationState>(context).updateVisibilities) {
      Provider.of<ApplicationState>(context).updateVisibilities = false;
      _setVisibilities();
    }
    return Container(
      padding: EdgeInsets.all(20),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 50.0,
            right: 0.0,
            left: 0.0,
            child: Column(
              children: <Widget>[
                Text(
                  "$location",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "$datetime",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "$temperature$tempunit",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Tooltip(
                    message: "Wind speed",
                    child: visibilityWindSpeed
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/windspeed.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Wind speed'),
                              ),
                              Text(
                                "$windspeed",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$windunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Tooltip(
                    message: "Pressure",
                    child: visibilityPressure
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "$bar",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$barunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: SvgPicture.asset(
                                    'assets/images/barometer.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Barometer'),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Tooltip(
                    message: "Wind direction",
                    child: visibilityWindDirection
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/winddir.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Wind dir'),
                              ),
                              Text(
                                "$winddir",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Tooltip(
                    message: "Humidity",
                    child: visibilityHumidity
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "$humidity",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$humunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: SvgPicture.asset(
                                    'assets/images/humidity.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Humidity'),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Tooltip(
                    message: "Temperature",
                    child: visibilityTemperature
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/temperature.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Temperature'),
                              ),
                              Text(
                                "$temperature",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$tempunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Tooltip(
                    message: "Wind chill",
                    child: visibilityWindChill
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "$windchill",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$degunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: SvgPicture.asset(
                                    'assets/images/windchill.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Wind chill'),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Tooltip(
                    message: "Rain",
                    child: visibilityRain
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/rain.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Rain'),
                              ),
                              Text(
                                "$rain",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$rainunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Tooltip(
                    message: "Dew",
                    child: visibilityDew
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "$dew",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$degunit",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: SvgPicture.asset('assets/images/dew.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Dew point'),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Tooltip(
                    message: "Sunrise",
                    child: visibilitySunrise
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/sunrise.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Sunrise'),
                              ),
                              Text(
                                "$sunrise",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Tooltip(
                    message: "Moonrise",
                    child: visibilityMoonrise
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/moonrise.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Moonrise'),
                              ),
                              Text(
                                "$moonrise",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Tooltip(
                    message: "Sunset",
                    child: visibilitySunset
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/sunset.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Sunset'),
                              ),
                              Text(
                                "$sunset",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Tooltip(
                    message: "Moonset",
                    child: visibilityMoonset
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    'assets/images/moonset.svg',
                                    color: Colors.white,
                                    width: 30,
                                    height: 30,
                                    semanticsLabel: 'Moonset'),
                              ),
                              Text(
                                "$moonset",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 10.0,
            right: 0.0,
            left: 0.0,
            child: Column(
              children: <Widget>[
                Text(
                  "More info",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  onPressed: _openDetailPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _openDetailPage() async {
    if (_sourceData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Provider<ApplicationState>.value(
            value: Provider.of<ApplicationState>(context),
            child: DetailPage(_sourceData),
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

  Future<Null> _setVisibilities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
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

  Future<Null> _retrieveData(String url) async {
    if (url == null) return null;
    if (url.endsWith("xml")) {
      // parsing and variables assignment with realtime.xml
      _sourceData = await _parseRealtimeXML(url);
      if (_sourceData == null) return null;
      _visualizeRealtimeXML(_sourceData);
    } else if (url.endsWith("txt")) {
      // parsing and variables assignment with realtime.txt
      _sourceData = await _parseRealtimeTXT(url);
      if (_sourceData == null) return null;
      _visualizeRealtimeTXT(_sourceData);
    } else {
      _retrieveData(url + "/realtime.xml");
      return _retrieveData(url + "/realtime.txt");
    }
  }

  Future<Map<String, String>> _parseRealtimeXML(String url) async {
    try {
      var rawResponse = await http.get(url);
      var response = rawResponse.body;
      xml.XmlDocument document = xml.parse(response);
      var pwsInfo = <String, String>{};
      document.findAllElements("misc").forEach((elem) {
        if (elem.attributes
                .where((attr) =>
                    attr.name.toString() == "data" &&
                    attr.value == "station_location")
                .length >
            0) {
          pwsInfo['station_location'] = elem.text;
        }
      });
      document.findAllElements("data").forEach((elem) {
        var variable;
        try {
          variable = elem.attributes
              .firstWhere((attr) => [
                    "misc",
                    "realtime",
                    "today",
                    "yesterday",
                    "record",
                  ].contains(attr.name.toString()))
              .value;
        } catch (Exception) {}
        if (variable != null) {
          pwsInfo[variable] = elem.text;
        }
      });
      return pwsInfo;
    } catch (Exception) {
      return null;
    }
  }

  Future<Map<String, String>> _parseRealtimeTXT(String url) async {
    try {
      var rawResponse = await http.get(url);
      var response = rawResponse.body;
      // split values by space
      List properties = [
        "date",
        "timehhmmss",
        "temp",
        "hum",
        "dew",
        "wspeed",
        "wlatest",
        "bearing",
        "rrate",
        "rfall",
        "press",
        "currentwdir",
        "beaufortnumber",
        "windunit",
        "tempunitnodeg",
        "pressunit",
        "rainunit",
        "windrun",
        "presstrendval",
        "rmonth",
        "ryear",
        "rfallY",
        "intemp",
        "inhum",
        "wchill",
        "temptrend",
        "tempTH",
        "TtempTH",
        "tempTL",
        "TtempTL",
        "windTM",
        "TwindTM",
        "wgustTM",
        "TwgustTM",
        "pressTH",
        "TpressTH",
        "pressTL",
        "TpressTL",
        "version",
        "build",
        "wgust",
        "heatindex",
        "humidex",
        "UV",
        "ET",
        "SolarRad",
        "avgbearing",
        "rhour",
        "forecastnumber",
        "isdaylight",
        "SensorContactLost",
        "wdir",
        "cloudbasevalue",
        "cloudbaseunit",
        "apptemp",
        "SunshineHours",
        "CurrentSolarMax",
        "IsSunny"
      ];
      List values = response.trim().split(' ');
      var pwsInfo = <String, String>{};
      for (var counter = 0; counter < properties.length; counter++) {
        if (counter < values.length)
          pwsInfo[properties[counter]] = values[counter];
      }
      return pwsInfo;
    } catch (Exception) {
      return null;
    }
  }

  _visualizeRealtimeXML(map) {
    setState(() {
      if (map.containsKey("station_location"))
        location = map["station_location"];
      else if (map.containsKey("location"))
        location = map["location"];
      else if (widget.source != null) location = widget.source.name;
      try {
        var tmpDatetime = "";
        if (map.containsKey("station_date"))
          tmpDatetime += " " + map["station_date"];
        else if (map.containsKey("refresh_time"))
          tmpDatetime += " " + map["refresh_time"].substring(0, 10);
        if (map.containsKey("station_time"))
          tmpDatetime = " " + map["station_time"];
        else if (map.containsKey("refresh_time"))
          tmpDatetime = " " + map["refresh_time"].substring(12);
        tmpDatetime =
            tmpDatetime.trim().replaceAll("/", "-").replaceAll(".", "-");
        datetime = DateTime.parse(tmpDatetime)
            .toLocal()
            .toString()
            .replaceAll(".000", "");
      } catch (Exception) {
        datetime = (((map.containsKey("station_date"))
                    ? map["station_date"].trim() + " "
                    : ((map.containsKey("refresh_time"))
                        ? map["refresh_time"].substring(0, 10).trim() + " "
                        : "--/--/-- ")) +
                ((map.containsKey("station_time"))
                    ? map["station_time"].trim()
                    : ((map.containsKey("refresh_time"))
                        ? map["refresh_time"].substring(12).trim()
                        : "--:--:--")))
            .replaceAll("/", "-")
            .replaceAll(".", "-");
      }
      if (map.containsKey("windspeed"))
        windspeed = map["windspeed"];
      else if (map.containsKey("avg_windspeed"))
        windspeed = map["avg_windspeed"];
      if (map.containsKey("barometer"))
        bar = map["barometer"];
      else if (map.containsKey("press")) bar = map["press"];
      if (map.containsKey("winddir")) winddir = map["winddir"];
      if (map.containsKey("hum")) humidity = map["hum"];
      if (map.containsKey("temp")) temperature = map["temp"];
      if (map.containsKey("windchill"))
        windchill = map["windchill"];
      else if (map.containsKey("wchill")) windchill = map["wchill"];
      if (map.containsKey("todaysrain"))
        rain = map["todaysrain"];
      else if (map.containsKey("today_rainfall")) rain = map["today_rainfall"];
      if (map.containsKey("dew")) dew = map["dew"];
      if (map.containsKey("sunrise")) sunrise = map["sunrise"];
      if (map.containsKey("sunset")) sunset = map["sunset"];
      if (map.containsKey("moonrise")) moonrise = map["moonrise"];
      if (map.containsKey("moonset")) moonset = map["moonset"];
      if (_isNumeric(windspeed)) {
        if (map.containsKey("windunit")) windunit = map["windunit"];
      } else
        windunit = "";
      if (_isNumeric(rain)) {
        if (map.containsKey("rainunit")) rainunit = map["rainunit"];
      } else
        rainunit = "";
      if (_isNumeric(bar)) {
        if (map.containsKey("barunit")) barunit = map["barunit"];
      } else
        barunit = "";
      if (_isNumeric(temperature)) {
        if (map.containsKey("tempunit")) tempunit = map["tempunit"];
      } else
        tempunit = "";
      if (_isNumeric(humidity)) {
        if (map.containsKey("humunit")) humunit = map["humunit"];
      } else
        humunit = "";
      degunit = (_isNumeric(dew) ? "°" : "");
    });
  }

  _visualizeRealtimeTXT(map) {
    setState(() {
      if (widget.source != null) location = widget.source.name;
      try {
        var tmpDatetime = "";
        if (map.containsKey("date")) tmpDatetime += " " + map["date"];
        if (map.containsKey("timehhmmss"))
          tmpDatetime += " " + map["timehhmmss"];
        tmpDatetime =
            tmpDatetime.trim().replaceAll("/", "-").replaceAll(".", "-");
        tmpDatetime = tmpDatetime.substring(0, 6) +
            DateTime.now().year.toString().substring(0, 2) +
            tmpDatetime.substring(6);
        tmpDatetime = tmpDatetime.substring(6, 10) +
            "-" +
            tmpDatetime.substring(3, 5) +
            "-" +
            tmpDatetime.substring(0, 2) +
            " " +
            tmpDatetime.substring(11);
        datetime = DateTime.parse(tmpDatetime)
            .toLocal()
            .toString()
            .replaceAll(".000", "");
      } catch (Exception) {
        datetime = (((map.containsKey("date"))
                    ? map["date"].trim() + " "
                    : "--/--/-- ") +
                ((map.containsKey("timehhmmss"))
                    ? map["timehhmmss"].trim()
                    : "--:--:--"))
            .replaceAll("/", "-")
            .replaceAll(".", "-");
      }
      if (map.containsKey("wspeed")) windspeed = map["wspeed"];
      if (map.containsKey("press")) bar = map["press"];
      if (map.containsKey("currentwdir")) winddir = map["currentwdir"];
      if (map.containsKey("hum")) humidity = map["hum"];
      if (map.containsKey("temp")) temperature = map["temp"];
      if (map.containsKey("wchill")) windchill = map["wchill"];
      if (map.containsKey("rfall")) rain = map["rfall"];
      if (map.containsKey("dew")) dew = map["dew"];
      // data about sunrise, sunset, moonrise and moonset cannot be retrieved from realtime.txt
      if (_isNumeric(windspeed)) {
        if (map.containsKey("windunit")) windunit = map["windunit"];
      } else
        windunit = "";
      if (_isNumeric(rain)) {
        if (map.containsKey("rainunit")) rainunit = map["rainunit"];
      } else
        rainunit = "";
      if (_isNumeric(bar)) {
        if (map.containsKey("pressunit")) barunit = map["pressunit"];
      } else
        barunit = "";
      if (_isNumeric(temperature)) {
        if (map.containsKey("tempunitnodeg")) tempunit = map["tempunitnodeg"];
      } else
        tempunit = "";
      if (_isNumeric(humidity)) {
        if (map.containsKey("humunit")) humunit = map["humunit"];
      } else
        humunit = "";
      degunit = (_isNumeric(dew) ? "°" : "");
    });
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
