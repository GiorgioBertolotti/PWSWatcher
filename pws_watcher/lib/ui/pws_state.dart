import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/resources/parsing_properties.dart';
import 'package:pws_watcher/resources/state.dart';
import 'package:pws_watcher/ui/detail.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/model/source.dart';
import 'dart:async';

class PWSStatePage extends StatefulWidget {
  PWSStatePage(this.source);

  final Source source;

  @override
  _PWSStatePageState createState() => _PWSStatePageState();
}

class _PWSStatePageState extends State<PWSStatePage>
    with TickerProviderStateMixin {
  Map<String, String> _sourceData;
  AnimationController _controller;
  Source _source;

  var location = "Location";
  var datetime = "--/--/---- --:--:--";

  var windspeed = "-";
  var press = "-";
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

  var windUnit = "km/h";
  var rainUnit = "mm";
  var pressUnit = "mb";
  var tempUnit = "°C";
  var dewUnit = "°";
  var humUnit = "%";

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
    _source = widget.source;
    _updatePreferences();
    _retrieveData(_source.url);
    if (_source.autoUpdateInterval != null && _source.autoUpdateInterval != 0) {
      startTimer();
    }
  }

  void startTimer() {
    _controller = AnimationController(
      duration: Duration(seconds: _source.autoUpdateInterval),
      vsync: this,
    );
    _controller.addListener(() {
      if (_controller.value > 0.99) {
        _retrieveData(_source.url);
      }
    });
    _controller.repeat();
  }

  void restartTimer() {
    if (_controller != null) {
      _controller.stop();
      _controller.dispose();
    }
    _controller = AnimationController(
      duration: Duration(seconds: _source.autoUpdateInterval),
      vsync: this,
    );
    _controller.addListener(() {
      if (_controller.value > 0.99) {
        _retrieveData(_source.url);
      }
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ApplicationState>(context).updatePreferences) {
      Provider.of<ApplicationState>(context).updatePreferences = false;
      _updatePreferences();
      _convertToPrefUnits();
    }
    if (!this._source.isEqual(widget.source)) {
      this._source = widget.source;
      if (this._source.autoUpdateInterval != null &&
          this._source.autoUpdateInterval != 0) {
        restartTimer();
      }
    }
    return Stack(
      children: <Widget>[
        (_source.autoUpdateInterval != null && _source.autoUpdateInterval == 0)
            ? Positioned(
                top: 0.0,
                left: 0.0,
                child: IconButton(
                  tooltip: "Update",
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    _retrieveData(_source.url);
                  },
                ),
              )
            : visibilityUpdateTimer
                ? Positioned(
                    top: 0.0,
                    left: 0.0,
                    child: Tooltip(
                      message: "Update timer",
                      child: Container(
                        margin: EdgeInsets.all(16.0),
                        width: 16.0,
                        height: 16.0,
                        child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, snapshot) {
                              return Theme(
                                data: ThemeData(
                                  primarySwatch:
                                      Provider.of<ApplicationState>(context)
                                          .mainColor,
                                ),
                                child: CircularProgressIndicator(
                                  value: _controller.value,
                                  strokeWidth: 2.5,
                                  backgroundColor: Colors.white,
                                ),
                              );
                            }),
                      ),
                    ),
                  )
                : Container(),
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
        Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: ListView(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "$temperature$tempUnit",
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
                                  "$windUnit",
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
                                  "$press",
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "$pressUnit",
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
                                  "$humUnit",
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
                                  "$tempUnit",
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
                                  "$dewUnit",
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
                                  "$rainUnit",
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
                                  "$dewUnit",
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
                                      'assets/images/dew.svg',
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
          ),
        ),
        Positioned(
          bottom: 10.0,
          right: 0.0,
          left: 0.0,
          child: Container(
            padding: EdgeInsets.all(20),
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
        ),
      ],
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

  Future<Null> _updatePreferences() async {
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

  bool _isRetrieving = false;

  Future<Null> _retrieveData(String url, {bool force = false}) async {
    if (!force && _isRetrieving) return null;
    _isRetrieving = true;
    if (url == null) return null;
    if (url.endsWith("xml")) {
      // parsing and variables assignment with realtime.xml
      _sourceData = await _parseRealtimeXML(url);
      if (_sourceData == null) {
        _isRetrieving = false;
        return null;
      }
      _visualizeRealtimeXML(_sourceData);
    } else if (url.endsWith("txt")) {
      if (url.endsWith("clientraw.txt")) {
        // parsing and variables assignment with clientraw.txt
        _sourceData = await _parseClientRawTXT(url);
        if (_sourceData == null) {
          // parsing and variables assignment with clientraw.txt
          _sourceData = await _parseRealtimeTXT(url);
          if (_sourceData == null) {
            _isRetrieving = false;
            return null;
          }
          _visualizeRealtimeTXT(_sourceData);
          return null;
        }
        _visualizeClientRawTXT(_sourceData);
      } else {
        // parsing and variables assignment with realtime.txt
        _sourceData = await _parseRealtimeTXT(url);
        if (_sourceData == null) {
          // parsing and variables assignment with clientraw.txt
          _sourceData = await _parseClientRawTXT(url);
          if (_sourceData == null) {
            _isRetrieving = false;
            return null;
          }
          _visualizeClientRawTXT(_sourceData);
          return null;
        }
        _visualizeRealtimeTXT(_sourceData);
      }
    } else {
      _retrieveData(url + "/realtime.xml");
      return _retrieveData(url + "/realtime.txt", force: true);
    }
    _isRetrieving = false;
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
      List properties = getRealtimeTxtProperties();
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

  Future<Map<String, String>> _parseClientRawTXT(String url) async {
    try {
      var rawResponse = await http.get(url);
      var response = rawResponse.body;
      // split values by space
      List properties = getClientRawProperties();
      List values = response.trim().split(' ');
      var pwsInfo = <String, String>{};
      for (var counter = 0; counter < properties.length; counter++) {
        if (counter < values.length)
          pwsInfo[properties[counter]] = values[counter];
      }
      try {
        rawResponse = await http
            .get(url.replaceAll("clientraw.txt", "clientrawextra.txt"));
        response = rawResponse.body;
        // split values by space
        properties = getClientRawExtraProperties();
        values = response.trim().split(' ');
        for (var counter = 0; counter < properties.length; counter++) {
          if (counter < values.length)
            pwsInfo[properties[counter]] = values[counter];
        }
      } catch (e) {}
      return pwsInfo;
    } catch (Exception) {
      return null;
    }
  }

  _visualizeRealtimeXML(map) {
    try {
      setState(() {
        if (map.containsKey("station_location"))
          location = map["station_location"];
        else if (map.containsKey("location"))
          location = map["location"];
        else if (_source != null) location = _source.name;
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
          press = map["barometer"];
        else if (map.containsKey("press")) press = map["press"];
        if (map.containsKey("winddir")) winddir = map["winddir"];
        if (map.containsKey("hum")) humidity = map["hum"];
        if (map.containsKey("temp")) temperature = map["temp"];
        if (map.containsKey("windchill"))
          windchill = map["windchill"];
        else if (map.containsKey("wchill")) windchill = map["wchill"];
        if (map.containsKey("todaysrain"))
          rain = map["todaysrain"];
        else if (map.containsKey("today_rainfall"))
          rain = map["today_rainfall"];
        if (map.containsKey("dew")) dew = map["dew"];
        if (map.containsKey("sunrise")) sunrise = map["sunrise"];
        if (map.containsKey("sunset")) sunset = map["sunset"];
        if (map.containsKey("moonrise")) moonrise = map["moonrise"];
        if (map.containsKey("moonset")) moonset = map["moonset"];
        if (_isNumeric(windspeed)) {
          if (map.containsKey("windunit")) windUnit = map["windunit"];
        } else
          windUnit = "";
        if (_isNumeric(rain)) {
          if (map.containsKey("rainunit")) rainUnit = map["rainunit"];
        } else
          rainUnit = "";
        if (_isNumeric(press)) {
          if (map.containsKey("barunit")) pressUnit = map["barunit"];
        } else
          pressUnit = "";
        if (_isNumeric(temperature)) {
          if (map.containsKey("tempunit")) tempUnit = map["tempunit"];
        } else
          tempUnit = "";
        if (_isNumeric(humidity)) {
          if (map.containsKey("humunit")) humUnit = map["humunit"];
        } else
          humUnit = "";
        dewUnit = (_isNumeric(dew) ? "°" : "");
        _convertToPrefUnits();
      });
    } catch (e) {}
  }

  _visualizeRealtimeTXT(map) {
    try {
      setState(() {
        if (_source != null) location = _source.name;
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
        if (map.containsKey("press")) press = map["press"];
        if (map.containsKey("currentwdir")) winddir = map["currentwdir"];
        if (map.containsKey("hum")) humidity = map["hum"];
        if (map.containsKey("temp")) temperature = map["temp"];
        if (map.containsKey("wchill")) windchill = map["wchill"];
        if (map.containsKey("rfall")) rain = map["rfall"];
        if (map.containsKey("dew")) dew = map["dew"];
        // data about sunrise, sunset, moonrise and moonset cannot be retrieved from realtime.txt
        if (_isNumeric(windspeed)) {
          if (map.containsKey("windunit")) windUnit = map["windunit"];
        } else
          windUnit = "";
        if (_isNumeric(rain)) {
          if (map.containsKey("rainunit")) rainUnit = map["rainunit"];
        } else
          rainUnit = "";
        if (_isNumeric(press)) {
          if (map.containsKey("pressunit")) pressUnit = map["pressunit"];
        } else
          pressUnit = "";
        if (_isNumeric(temperature)) {
          if (map.containsKey("tempunitnodeg")) tempUnit = map["tempunitnodeg"];
        } else
          tempUnit = "";
        if (_isNumeric(humidity)) {
          if (map.containsKey("humunit")) humUnit = map["humunit"];
        } else
          humUnit = "";
        dewUnit = (_isNumeric(dew) ? "°" : "");
        _convertToPrefUnits();
      });
    } catch (e) {}
  }

  _visualizeClientRawTXT(map) {
    try {
      setState(() {
        if (_source != null) location = _source.name;
        var tmpDatetime = "";
        if (map.containsKey("Date")) tmpDatetime += " " + map["Date"];
        if (map.containsKey("Hour")) tmpDatetime += " " + map["Hour"];
        if (map.containsKey("Minute")) tmpDatetime += ":" + map["Minute"];
        if (map.containsKey("Seconds")) tmpDatetime += ":" + map["Seconds"];
        tmpDatetime =
            tmpDatetime.trim().replaceAll("/", "-").replaceAll(".", "-");
        try {
          datetime = DateTime.parse(tmpDatetime)
              .toLocal()
              .toString()
              .replaceAll(".000", "");
        } catch (e) {
          datetime = tmpDatetime;
        }
        if (map.containsKey("CurrentWindspeed"))
          windspeed = map["CurrentWindspeed"];
        if (map.containsKey("Barometer")) press = map["Barometer"];
        if (map.containsKey("WindDirection"))
          winddir = deg2WindDir(map["WindDirection"]);
        if (map.containsKey("OutsideHumidity"))
          humidity = map["OutsideHumidity"];
        if (map.containsKey("OutsideTemp")) temperature = map["OutsideTemp"];
        if (map.containsKey("WindChill")) windchill = map["WindChill"];
        if (map.containsKey("DailyRain")) rain = map["DailyRain"];
        if (map.containsKey("DewPointTemp")) dew = map["DewPointTemp"];
        if (map.containsKey("Sunrise")) sunrise = map["Sunrise"];
        if (map.containsKey("Sunset")) sunset = map["Sunset"];
        if (map.containsKey("Moonrise")) moonrise = map["Moonrise"];
        if (map.containsKey("Moonset")) moonset = map["Moonset"];
        windUnit = "kts";
        rainUnit = "mm";
        pressUnit = "hPa";
        tempUnit = "°C";
        humUnit = "%";
        dewUnit = "°C";
        _convertToPrefUnits();
      });
    } catch (e) {}
  }

  _convertToPrefUnits() {
    ApplicationState appState = Provider.of<ApplicationState>(context);
    if (_isNumeric(windspeed) && windUnit != appState.prefWindUnit) {
      convertWindSpeed(appState.prefWindUnit);
    }
    if (_isNumeric(rain) &&
        appState.prefRainUnit != null &&
        rainUnit != appState.prefRainUnit) {
      convertRain(appState.prefRainUnit);
    }
    if (_isNumeric(press) &&
        appState.prefPressUnit != null &&
        pressUnit != appState.prefPressUnit) {
      convertPressure(appState.prefPressUnit);
    }
    if (_isNumeric(temperature) &&
        appState.prefTempUnit != null &&
        tempUnit != appState.prefTempUnit) {
      convertTemperature(appState.prefTempUnit);
    }
    if (_isNumeric(dew) &&
        appState.prefDewUnit != null &&
        dewUnit != appState.prefDewUnit) {
      convertDew(appState.prefDewUnit);
    }
    if (appState.prefWindUnit != null) windUnit = appState.prefWindUnit;
    if (appState.prefRainUnit != null) rainUnit = appState.prefRainUnit;
    if (appState.prefPressUnit != null) pressUnit = appState.prefPressUnit;
    if (appState.prefTempUnit != null) tempUnit = appState.prefTempUnit;
    if (appState.prefDewUnit != null) dewUnit = appState.prefDewUnit;
  }

  convertWindSpeed(String preferred) {
    double kmh;
    switch (windUnit.trim().replaceAll("/", "").toLowerCase()) {
      case "kts":
        {
          kmh = ktsToKmh(double.parse(windspeed));
          break;
        }
      case "mph":
        {
          kmh = mphToKmh(double.parse(windspeed));
          break;
        }
      case "ms":
        {
          kmh = msToKmh(double.parse(windspeed));
          break;
        }
      default:
        {
          kmh = double.parse(windspeed);
          break;
        }
    }
    switch (preferred.trim().replaceAll("/", "").toLowerCase()) {
      case "kts":
        {
          windspeed = roundToNthDecimal(kmhToKts(kmh), 2).toString();
          break;
        }
      case "mph":
        {
          windspeed = roundToNthDecimal(kmhToMph(kmh), 2).toString();
          break;
        }
      case "ms":
        {
          windspeed = roundToNthDecimal(kmhToMs(kmh), 2).toString();
          break;
        }
      default:
        {
          windspeed = roundToNthDecimal(kmh, 2).toString();
          break;
        }
    }
  }

  convertRain(String preferred) {
    if (rainUnit.trim().replaceAll("/", "").toLowerCase() == "mm") {
      rain = roundToNthDecimal(mmToIn(double.parse(rain)), 2).toString();
    } else {
      rain = roundToNthDecimal(inToMm(double.parse(rain)), 2).toString();
    }
  }

  convertPressure(String preferred) {
    double hPa;
    switch (pressUnit.trim().replaceAll("/", "").toLowerCase()) {
      case "inhg":
        {
          hPa = inhgToHPa(double.parse(press));
          break;
        }
      case "mb":
        {
          hPa = mbToHPa(double.parse(press));
          break;
        }
      default:
        {
          hPa = double.parse(press);
          break;
        }
    }
    switch (preferred.trim().replaceAll("/", "").toLowerCase()) {
      case "inhg":
        {
          press = roundToNthDecimal(hPaToInhg(hPa), 2).toString();
          break;
        }
      case "mb":
        {
          press = roundToNthDecimal(hPaToMb(hPa), 2).toString();
          break;
        }
      default:
        {
          press = roundToNthDecimal(hPa, 2).toString();
          break;
        }
    }
  }

  convertTemperature(String preferred) {
    if (tempUnit.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase() ==
        "f") {
      temperature =
          roundToNthDecimal(fToC(double.parse(temperature)), 2).toString();
    } else {
      temperature =
          roundToNthDecimal(cToF(double.parse(temperature)), 2).toString();
    }
  }

  convertDew(String preferred) {
    if (dewUnit.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase() ==
        "f") {
      dew = roundToNthDecimal(fToC(double.parse(dew)), 2).toString();
    } else {
      dew = roundToNthDecimal(cToF(double.parse(dew)), 2).toString();
    }
  }

  String deg2WindDir(String degrees) {
    try {
      double deg = double.parse(degrees);
      if (deg > 348.75 || deg <= 11.25) {
        return "N";
      } else if (deg > 11.25 && deg <= 33.75) {
        return "NNE";
      } else if (deg > 33.75 && deg <= 56.25) {
        return "NE";
      } else if (deg > 56.25 && deg <= 78.75) {
        return "ENE";
      } else if (deg > 78.75 && deg <= 101.25) {
        return "E";
      } else if (deg > 101.25 && deg <= 123.75) {
        return "ESE";
      } else if (deg > 123.75 && deg <= 146.25) {
        return "SE";
      } else if (deg > 146.25 && deg <= 168.75) {
        return "SSE";
      } else if (deg > 168.75 && deg <= 191.25) {
        return "S";
      } else if (deg > 191.25 && deg <= 213.75) {
        return "SSW";
      } else if (deg > 213.75 && deg <= 236.25) {
        return "SW";
      } else if (deg > 236.25 && deg <= 258.75) {
        return "WSW";
      } else if (deg > 258.75 && deg <= 281.25) {
        return "W";
      } else if (deg > 281.25 && deg <= 303.75) {
        return "WNW";
      } else if (deg > 303.75 && deg <= 326.25) {
        return "NW";
      } else {
        return "NNW";
      }
    } catch (e) {
      return degrees;
    }
  }

  double ktsToKmh(double kts) {
    return kts * 1.852;
  }

  double mphToKmh(double mph) {
    return mph * 1.60934;
  }

  double msToKmh(double ms) {
    return ms * 3.6;
  }

  double kmhToKts(double kmh) {
    return kmh / 1.852;
  }

  double kmhToMph(double kmh) {
    return kmh / 1.60934;
  }

  double kmhToMs(double kmh) {
    return kmh / 3.6;
  }

  double mmToIn(double mm) {
    return mm / 25.4;
  }

  double inToMm(double inc) {
    return inc * 25.4;
  }

  double inhgToHPa(double inhg) {
    return inhg * 33.86389;
  }

  double mbToHPa(double mb) {
    return mb;
  }

  double hPaToInhg(double pa) {
    return pa / 33.86389;
  }

  double hPaToMb(double pa) {
    return pa;
  }

  double fToC(double f) {
    return (f - 32) * 5 / 9;
  }

  double cToF(double c) {
    return (c * 9 / 5) + 32;
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  double roundToNthDecimal(double val, int decimals) {
    int fac = pow(10, decimals);
    return (val * fac).round() / fac;
  }
}
