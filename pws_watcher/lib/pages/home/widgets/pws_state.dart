import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/model/parsing_properties\.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/detail/detail.dart';
import 'package:pws_watcher/pages/home/widgets/update_timer.dart';
import 'package:pws_watcher/pages/home/widgets/variable_row.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
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
  Map<String, String> _sourceData;
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
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ApplicationState>(context).updatePreferences) {
      Provider.of<ApplicationState>(context).updatePreferences = false;
      _updatePreferences();
      _retrieveData(_source.url);
    }
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        _buildUpdateIndicator(_source),
        SizedBox(height: 20.0),
        Center(
          child: Text(
            "$location",
            maxLines: 1,
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
                "More info",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
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
    );
  }

  dynamic _buildUpdateIndicator(Source source) {
    if (source.autoUpdateInterval != null && source.autoUpdateInterval == 0) {
      return Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          tooltip: "Update",
          icon: Icon(
            Icons.refresh,
            color: Theme.of(context).accentColor,
          ),
          padding: EdgeInsets.all(0),
          onPressed: () {
            _retrieveData(_source.url);
          },
        ),
      );
    } else if (visibilityUpdateTimer) {
      return Align(
        alignment: Alignment.topLeft,
        child: Tooltip(
          message: "Update timer",
          child: UpdateTimer(
            Duration(seconds: source.autoUpdateInterval),
            () => _retrieveData(source.url),
          ),
        ),
      );
    } else
      return Container();
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
        else if (map.containsKey("press")) {
          try {
            final doubleRegex = RegExp(r'(\d+\.\d+)+');
            press = doubleRegex.allMatches(map["press"]).first.group(0);
            pressUnit = map["press"].toString().replaceAll(press, "").trim();
          } catch (e) {
            press = map["press"];
          }
        }
        if (map.containsKey("winddir")) winddir = map["winddir"];
        if (map.containsKey("hum")) humidity = map["hum"];
        if (map.containsKey("temp")) {
          try {
            final doubleRegex = RegExp(r'(\d+\.\d+)+');
            temperature = doubleRegex.allMatches(map["temp"]).first.group(0);
            tempUnit =
                map["temp"].toString().replaceAll(temperature, "").trim();
          } catch (e) {
            temperature = map["temp"];
          }
        }
        if (map.containsKey("windchill"))
          windchill = map["windchill"];
        else if (map.containsKey("wchill")) {
          try {
            final doubleRegex = RegExp(r'(\d+\.\d+)+');
            windchill = doubleRegex.allMatches(map["wchill"]).first.group(0);
          } catch (e) {
            windchill = map["wchill"];
          }
        }
        if (map.containsKey("todaysrain"))
          rain = map["todaysrain"];
        else if (map.containsKey("today_rainfall")) {
          try {
            final doubleRegex = RegExp(r'(\d+\.\d+)+');
            rain = doubleRegex.allMatches(map["today_rainfall"]).first.group(0);
            rainUnit =
                map["today_rainfall"].toString().replaceAll(rain, "").trim();
          } catch (e) {
            rain = map["today_rainfall"];
          }
        }
        if (map.containsKey("dew")) {
          try {
            final doubleRegex = RegExp(r'(\d+\.\d+)+');
            dew = doubleRegex.allMatches(map["dew"]).first.group(0);
            dewUnit = map["dew"].toString().replaceAll(dew, "").trim();
          } catch (e) {
            dew = map["dew"];
          }
        }
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
        dewUnit = (_isNumeric(dew) ? tempUnit : "");
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
        dewUnit = (_isNumeric(dew) ? tempUnit : "");
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
    if (_isNumeric(windspeed) &&
        appState.prefWindUnit != null &&
        !unitEquals(windUnit, appState.prefWindUnit)) {
      convertWindSpeed(appState.prefWindUnit);
    }
    if (_isNumeric(rain) &&
        appState.prefRainUnit != null &&
        !unitEquals(rainUnit, appState.prefRainUnit)) {
      convertRain(appState.prefRainUnit);
    }
    if (_isNumeric(press) &&
        appState.prefPressUnit != null &&
        !unitEquals(pressUnit, appState.prefPressUnit)) {
      convertPressure(appState.prefPressUnit);
    }
    if ((_isNumeric(windchill) || _isNumeric(temperature)) &&
        appState.prefTempUnit != null &&
        !unitEquals(tempUnit, appState.prefTempUnit)) {
      if (_isNumeric(windchill)) convertWindChill(appState.prefTempUnit);
      if (_isNumeric(temperature)) convertTemperature(appState.prefTempUnit);
    }
    if (_isNumeric(dew) &&
        appState.prefDewUnit != null &&
        !unitEquals(dewUnit, appState.prefDewUnit)) {
      convertDew(appState.prefDewUnit);
    }
    if (_isNumeric(windspeed) && appState.prefWindUnit != null)
      windUnit = appState.prefWindUnit;
    if (_isNumeric(rain) && appState.prefRainUnit != null)
      rainUnit = appState.prefRainUnit;
    if (_isNumeric(press) && appState.prefPressUnit != null)
      pressUnit = appState.prefPressUnit;
    if (_isNumeric(temperature) && appState.prefTempUnit != null)
      tempUnit = appState.prefTempUnit;
    if (_isNumeric(dew) && appState.prefDewUnit != null)
      dewUnit = appState.prefDewUnit;
  }

  bool unitEquals(String unit1, String unit2) {
    return unit1.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase() ==
        unit2.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase();
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

  convertWindChill(String preferred) {
    if (tempUnit.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase() ==
        "f") {
      windchill =
          roundToNthDecimal(fToC(double.parse(windchill)), 2).toString();
    } else {
      windchill =
          roundToNthDecimal(cToF(double.parse(windchill)), 2).toString();
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
