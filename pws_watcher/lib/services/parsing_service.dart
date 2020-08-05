import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pws_watcher/model/pws.dart';
import 'package:pws_watcher/model/state.dart';
import 'package:rxdart/subjects.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:pws_watcher/model/parsing_utilities.dart';

class ParsingService {
  BehaviorSubject<Map<String, String>> allDataSubject =
      BehaviorSubject<Map<String, String>>.seeded(Map());
  BehaviorSubject<Map<String, String>> interestVariablesSubject =
      BehaviorSubject<Map<String, String>>.seeded(Map());
  Stream<Map<String, String>> get data$ => allDataSubject.stream;
  Stream<Map<String, String>> get variables$ => interestVariablesSubject.stream;
  PWS source;
  ApplicationState appState;

  setSource(PWS source) {
    this.source = source;
    updateData();
  }

  setApplicationState(ApplicationState appState) {
    this.appState = appState;
    updateData();
  }

  ParsingService(this.source, this.appState) {
    updateData();
  }

  bool _isRetrieving = false;

  Future<Null> updateData({bool force = false}) async {
    String url = this.source.url;
    await _updateData(url);
  }

  Future<Null> _updateData(String url, {bool force = false}) async {
    if (!force && _isRetrieving) return null;
    if (url == null) return null;
    _isRetrieving = true;
    try {
      if (url.endsWith("xml")) {
        // parsing and variables assignment with realtime.xml
        Map<String, String> sourceData = await _parseRealtimeXML(url);
        if (sourceData != null) {
          Map interestData = _valuesFromRealtimeXML(sourceData);
          sourceData.addAll(beautifyConvertedValues(interestData));
          allDataSubject.add(sourceData);
          interestVariablesSubject.add(interestData);
        } else {
          if (!url.startsWith("http://") && !url.startsWith("https://")) {
            await _updateData("http://" + url, force: true);
            await _updateData("https://" + url, force: true);
          }
        }
      } else if (url.endsWith("txt")) {
        if (url.endsWith("clientraw.txt")) {
          // parsing and variables assignment with clientraw.txt
          Map<String, String> sourceData = await _parseClientRawTXT(url);
          if (sourceData == null) {
            // parsing and variables assignment with clientraw.txt
            sourceData = await _parseRealtimeTXT(url);
            if (sourceData != null) {
              Map interestData = _valuesFromRealtimeXML(sourceData);
              sourceData.addAll(beautifyConvertedValues(interestData));
              allDataSubject.add(sourceData);
              interestVariablesSubject.add(interestData);
            } else {
              if (!url.startsWith("http://") && !url.startsWith("https://")) {
                await _updateData("http://" + url, force: true);
                await _updateData("https://" + url, force: true);
              }
            }
          } else {
            Map interestData = _valuesFromClientRawTXT(sourceData);
            sourceData.addAll(beautifyConvertedValues(interestData));
            allDataSubject.add(sourceData);
            interestVariablesSubject.add(interestData);
          }
        } else {
          // parsing and variables assignment with realtime.txt
          Map<String, String> sourceData = await _parseRealtimeTXT(url);
          if (sourceData == null) {
            // parsing and variables assignment with clientraw.txt
            sourceData = await _parseClientRawTXT(url);
            if (sourceData != null) {
              Map interestData = _valuesFromClientRawTXT(sourceData);
              sourceData.addAll(beautifyConvertedValues(interestData));
              allDataSubject.add(sourceData);
              interestVariablesSubject.add(interestData);
            } else {
              if (!url.startsWith("http://") && !url.startsWith("https://")) {
                await _updateData("http://" + url, force: true);
                await _updateData("https://" + url, force: true);
              }
            }
          } else {
            Map interestData = _valuesFromRealtimeTXT(sourceData);
            sourceData.addAll(beautifyConvertedValues(interestData));
            allDataSubject.add(sourceData);
            interestVariablesSubject.add(interestData);
          }
        }
      } else if (url.endsWith("csv")) {
        // parsing and variables assignment with daily.csv
        Map<String, String> sourceData = await _parseDailyCSV(url);
        if (sourceData != null) {
          Map interestData = _valuesFromDailyCSV(sourceData);
          if (interestData != null) {
            sourceData.addAll(beautifyConvertedValues(interestData));
            interestVariablesSubject.add(interestData);
          }
          allDataSubject.add(sourceData);
        } else {
          if (!url.startsWith("http://") && !url.startsWith("https://")) {
            await _updateData("http://" + url, force: true);
            await _updateData("https://" + url, force: true);
          }
        }
      } else {
        await _updateData(url + "/realtime.xml", force: true);
        await _updateData(url + "/realtime.txt", force: true);
      }
    } catch (e) {}
    _isRetrieving = false;
  }

  Map<String, String> beautifyConvertedValues(Map<String, String> map) {
    Map<String, String> toReturn = Map();
    var windspeed = map["windspeed"] ?? "-";
    var press = map["press"] ?? "-";
    var temperature = map["temperature"] ?? "-";
    var windchill = map["windchill"] ?? "-";
    var rain = map["rain"] ?? "-";
    var dew = map["dew"] ?? "-";
    var windUnit = map["windUnit"] ?? "km/h";
    var rainUnit = map["rainUnit"] ?? "mm";
    var pressUnit = map["pressUnit"] ?? "mb";
    var tempUnit = map["tempUnit"] ?? "°C";
    var dewUnit = map["dewUnit"] ?? "°";
    toReturn["FinalWindSpeed"] = windspeed + windUnit;
    toReturn["FinalRain"] = rain + rainUnit;
    toReturn["FinalPressure"] = press + pressUnit;
    toReturn["FinalTemperature"] = temperature + tempUnit;
    toReturn["FinalWindChill"] = windchill + tempUnit;
    toReturn["FinalDewPoint"] = dew + dewUnit;
    return toReturn;
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
                    "units",
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
      List properties = realtimeTxtProperties;
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
      // http request
      var rawResponse = await http.get(url);
      var response = rawResponse.body;

      // split values by space
      List properties = clientRawProperties;
      List values = response.trim().split(' ');
      var pwsInfo = <String, String>{};

      // associate each value to a string key
      for (var counter = 0; counter < properties.length; counter++) {
        if (counter < values.length) {
          pwsInfo[properties[counter]] = values[counter];
        }
      }

      // try to fetch extra info from clientrawextra.txt
      try {
        rawResponse = await http
            .get(url.replaceAll("clientraw.txt", "clientrawextra.txt"));
        response = rawResponse.body;
        // split values by space
        properties = clientRawExtraProperties;
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

  Future<Map<String, String>> _parseDailyCSV(String url) async {
    try {
      var rawResponse = await http.get(url);
      var response = rawResponse.body;
      List lines = response.trim().split('\r\n');
      var pwsInfo = <String, String>{};
      pwsInfo["Date"] = lines[0];
      int latestIndex;
      TimeOfDay latestTimeOfDay;
      for (int i = 3; i < lines.length; i++) {
        List<String> values = lines[i].trim().split(',');
        if (values[0] != "---") {
          bool am = values[0].toLowerCase().contains("am");
          bool pm = values[0].toLowerCase().contains("pm");
          String time = values[0].replaceAll("am", "").replaceAll("pm", "");
          int part1 = int.parse(time.split(":")[0]);
          int part2 = int.parse(time.split(":")[1]);
          if (part1 == 12) {
            if (am) part1 = 0;
            if (pm) part1 = 12;
          }
          TimeOfDay timeOfDay = TimeOfDay(
            hour: part1,
            minute: part2,
          );
          if (latestTimeOfDay == null)
            latestTimeOfDay = timeOfDay;
          else {
            if (_timeOfDayToDouble(latestTimeOfDay) <
                _timeOfDayToDouble(timeOfDay)) {
              latestIndex = i;
              latestTimeOfDay = timeOfDay;
            }
          }
        }
      }
      if (latestIndex != null) {
        List properties = lines[1].trim().split(',');
        List units = lines[2].trim().split(',');
        for (var i = 0; i < properties.length; i++) {
          List<String> values = lines[latestIndex].trim().split(',');
          if (i < units.length) pwsInfo[properties[i] + " Unit"] = units[i];
          if (i < values.length) pwsInfo[properties[i]] = values[i];
        }
      }
      return pwsInfo;
    } catch (Exception) {
      return null;
    }
  }

  double _timeOfDayToDouble(TimeOfDay tod) => tod.hour + tod.minute / 60.0;

  Map<String, String> _valuesFromRealtimeXML(Map<String, String> map) {
    try {
      Map<String, String> interestVariables = Map();
      if (map.containsKey("station_location"))
        interestVariables["location"] = map["station_location"];
      else if (map.containsKey("location"))
        interestVariables["location"] = map["location"];
      else if (source != null) interestVariables["location"] = source.name;
      try {
        var tmpDatetime = "";
        if (map.containsKey("station_date"))
          tmpDatetime += " " + map["station_date"];
        else if (map.containsKey("refresh_time"))
          tmpDatetime += " " + map["refresh_time"].substring(0, 10);
        if (map.containsKey("station_time"))
          tmpDatetime += " " + map["station_time"];
        else if (map.containsKey("refresh_time"))
          tmpDatetime += " " + map["refresh_time"].substring(12);
        tmpDatetime =
            tmpDatetime.trim().replaceAll("/", "-").replaceAll(".", "-");
        interestVariables["datetime"] = DateTime.parse(tmpDatetime)
            .toLocal()
            .toString()
            .replaceAll(".000", "");
      } catch (Exception) {
        interestVariables["datetime"] = (((map.containsKey("station_date"))
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
        interestVariables["windspeed"] = map["windspeed"];
      else if (map.containsKey("avg_windspeed"))
        interestVariables["windspeed"] = map["avg_windspeed"];
      if (map.containsKey("barometer"))
        interestVariables["press"] = map["barometer"];
      else if (map.containsKey("press")) {
        try {
          final doubleRegex = RegExp(r'(\d+\.\d+)+');
          interestVariables["press"] =
              doubleRegex.allMatches(map["press"]).first.group(0);
          interestVariables["pressUnit"] = map["press"]
              .toString()
              .replaceAll(interestVariables["press"], "")
              .trim();
        } catch (e) {
          interestVariables["press"] = map["press"];
        }
      }
      if (map.containsKey("winddir"))
        interestVariables["winddir"] = map["winddir"];
      if (map.containsKey("hum")) interestVariables["humidity"] = map["hum"];
      if (map.containsKey("temp")) {
        try {
          final doubleRegex = RegExp(r'(\d+\.\d+)+');
          interestVariables["temperature"] =
              doubleRegex.allMatches(map["temp"]).first.group(0);
          interestVariables["tempUnit"] = map["temp"]
              .toString()
              .replaceAll(interestVariables["temperature"], "")
              .trim();
        } catch (e) {
          interestVariables["temperature"] = map["temp"];
        }
      }
      if (map.containsKey("windchill"))
        interestVariables["windchill"] = map["windchill"];
      else if (map.containsKey("wchill")) {
        try {
          final doubleRegex = RegExp(r'(\d+\.\d+)+');
          interestVariables["windchill"] =
              doubleRegex.allMatches(map["wchill"]).first.group(0);
        } catch (e) {
          interestVariables["windchill"] = map["wchill"];
        }
      }
      if (map.containsKey("todaysrain"))
        interestVariables["rain"] = map["todaysrain"];
      else if (map.containsKey("today_rainfall")) {
        try {
          final doubleRegex = RegExp(r'(\d+\.\d+)+');
          interestVariables["rain"] =
              doubleRegex.allMatches(map["today_rainfall"]).first.group(0);
          interestVariables["rainUnit"] = map["today_rainfall"]
              .toString()
              .replaceAll(interestVariables["rain"], "")
              .trim();
        } catch (e) {
          interestVariables["rain"] = map["today_rainfall"];
        }
      }
      if (map.containsKey("dew")) {
        try {
          final doubleRegex = RegExp(r'(\d+\.\d+)+');
          interestVariables["dew"] =
              doubleRegex.allMatches(map["dew"]).first.group(0);
          interestVariables["dewUnit"] = map["dew"]
              .toString()
              .replaceAll(interestVariables["dew"], "")
              .trim();
        } catch (e) {
          interestVariables["dew"] = map["dew"];
        }
      }
      if (map.containsKey("sunrise"))
        interestVariables["sunrise"] = map["sunrise"];
      if (map.containsKey("sunset"))
        interestVariables["sunset"] = map["sunset"];
      if (map.containsKey("moonrise"))
        interestVariables["moonrise"] = map["moonrise"];
      if (map.containsKey("moonset"))
        interestVariables["moonset"] = map["moonset"];
      if (_isNumeric(interestVariables["windspeed"])) {
        if (map.containsKey("windunit"))
          interestVariables["windUnit"] = map["windunit"];
      } else
        interestVariables["windUnit"] = "";
      if (_isNumeric(interestVariables["rain"])) {
        if (map.containsKey("rainunit"))
          interestVariables["rainUnit"] = map["rainunit"];
      } else
        interestVariables["rainUnit"] = "";
      if (_isNumeric(interestVariables["press"])) {
        if (map.containsKey("barunit"))
          interestVariables["pressUnit"] = map["barunit"];
      } else
        interestVariables["pressUnit"] = "";
      if (_isNumeric(interestVariables["temperature"])) {
        if (map.containsKey("tempunit"))
          interestVariables["tempUnit"] = map["tempunit"];
      } else
        interestVariables["tempUnit"] = "";
      if (_isNumeric(interestVariables["humidity"])) {
        if (map.containsKey("humunit"))
          interestVariables["humUnit"] = map["humunit"];
      } else
        interestVariables["humUnit"] = "";
      interestVariables["dewUnit"] = (_isNumeric(interestVariables["dew"])
          ? interestVariables["tempUnit"]
          : "");
      interestVariables = _convertToPrefUnits(interestVariables);
      return interestVariables;
    } catch (e) {
      return null;
    }
  }

  Map<String, String> _valuesFromRealtimeTXT(Map<String, String> map) {
    try {
      Map<String, String> interestVariables = Map();
      if (source != null) interestVariables["location"] = source.name;
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
        interestVariables["datetime"] = DateTime.parse(tmpDatetime)
            .toLocal()
            .toString()
            .replaceAll(".000", "");
      } catch (Exception) {
        interestVariables["datetime"] = (((map.containsKey("date"))
                    ? map["date"].trim() + " "
                    : "--/--/-- ") +
                ((map.containsKey("timehhmmss"))
                    ? map["timehhmmss"].trim()
                    : "--:--:--"))
            .replaceAll("/", "-")
            .replaceAll(".", "-");
      }
      if (map.containsKey("wspeed"))
        interestVariables["windspeed"] = map["wspeed"];
      if (map.containsKey("press")) interestVariables["press"] = map["press"];
      if (map.containsKey("currentwdir"))
        interestVariables["winddir"] = map["currentwdir"];
      if (map.containsKey("hum")) interestVariables["humidity"] = map["hum"];
      if (map.containsKey("temp"))
        interestVariables["temperature"] = map["temp"];
      if (map.containsKey("wchill"))
        interestVariables["windchill"] = map["wchill"];
      if (map.containsKey("rfall")) interestVariables["rain"] = map["rfall"];
      if (map.containsKey("dew")) interestVariables["dew"] = map["dew"];
      // data about sunrise, sunset, moonrise and moonset cannot be retrieved from realtime.txt
      if (_isNumeric(interestVariables["windspeed"])) {
        if (map.containsKey("windunit"))
          interestVariables["windUnit"] = map["windunit"];
      } else
        interestVariables["windUnit"] = "";
      if (_isNumeric(interestVariables["rain"])) {
        if (map.containsKey("rainunit"))
          interestVariables["rainUnit"] = map["rainunit"];
      } else
        interestVariables["rainUnit"] = "";
      if (_isNumeric(interestVariables["press"])) {
        if (map.containsKey("pressunit"))
          interestVariables["pressUnit"] = map["pressunit"];
      } else
        interestVariables["pressUnit"] = "";
      if (_isNumeric(interestVariables["temperature"])) {
        if (map.containsKey("tempunitnodeg"))
          interestVariables["tempUnit"] = map["tempunitnodeg"];
      } else
        interestVariables["tempUnit"] = "";
      if (_isNumeric(interestVariables["humidity"])) {
        if (map.containsKey("humunit"))
          interestVariables["humUnit"] = map["humunit"];
      } else
        interestVariables["humUnit"] = "";
      interestVariables["dewUnit"] = (_isNumeric(interestVariables["dew"])
          ? interestVariables["tempUnit"]
          : "");
      interestVariables = _convertToPrefUnits(interestVariables);
      return interestVariables;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, String> _valuesFromClientRawTXT(Map<String, String> map) {
    try {
      Map<String, String> interestVariables = Map();
      if (source != null) interestVariables["location"] = source.name;
      var tmpDatetime = "";
      if (map.containsKey("Date")) tmpDatetime += " " + map["Date"];
      if (map.containsKey("Hour"))
        tmpDatetime += " " + map["Hour"].padLeft(2, "0");
      if (map.containsKey("Minute"))
        tmpDatetime += ":" + map["Minute"].padLeft(2, "0");
      if (map.containsKey("Seconds"))
        tmpDatetime += ":" + map["Seconds"].padLeft(2, "0");
      tmpDatetime =
          tmpDatetime.trim().replaceAll("/", "-").replaceAll(".", "-");
      try {
        interestVariables["datetime"] = DateTime.parse(tmpDatetime)
            .toLocal()
            .toString()
            .replaceAll(".000", "");
      } catch (e) {
        interestVariables["datetime"] = tmpDatetime;
      }
      if (map.containsKey("CurrentWindspeed"))
        interestVariables["windspeed"] = map["CurrentWindspeed"];
      if (map.containsKey("Barometer"))
        interestVariables["press"] = map["Barometer"];
      if (map.containsKey("WindDirection"))
        interestVariables["winddir"] = deg2WindDir(map["WindDirection"]);
      if (map.containsKey("OutsideHumidity"))
        interestVariables["humidity"] = map["OutsideHumidity"];
      if (map.containsKey("OutsideTemp"))
        interestVariables["temperature"] = map["OutsideTemp"];
      if (map.containsKey("WindChill"))
        interestVariables["windchill"] = map["WindChill"];
      if (map.containsKey("DailyRain"))
        interestVariables["rain"] = map["DailyRain"];
      if (map.containsKey("DewPointTemp"))
        interestVariables["dew"] = map["DewPointTemp"];
      if (map.containsKey("Sunrise"))
        interestVariables["sunrise"] = map["Sunrise"];
      if (map.containsKey("Sunset"))
        interestVariables["sunset"] = map["Sunset"];
      if (map.containsKey("Moonrise"))
        interestVariables["moonrise"] = map["Moonrise"];
      if (map.containsKey("Moonset"))
        interestVariables["moonset"] = map["Moonset"];
      if (map.containsKey("CurrentConditionIcon"))
        interestVariables["currentConditionIndex"] =
            map["CurrentConditionIcon"];
      interestVariables["windUnit"] = "kts";
      interestVariables["rainUnit"] = "mm";
      interestVariables["pressUnit"] = "hPa";
      interestVariables["tempUnit"] = "°C";
      interestVariables["humUnit"] = "%";
      interestVariables["dewUnit"] = "°C";
      interestVariables = _convertToPrefUnits(interestVariables);
      return interestVariables;
    } catch (e) {
      return null;
    }
  }

  Map<String, String> _valuesFromDailyCSV(Map<String, String> map) {
    try {
      Map<String, String> interestVariables = Map();
      if (source != null) interestVariables["location"] = source.name;
      var tmpDatetime = "";
      if (map.containsKey("Date")) {
        try {
          if (map["Date"].substring(map["Date"].lastIndexOf("/") + 1).length !=
              4) {
            List<String> vals = map["Date"].split("/");
            tmpDatetime += " " +
                DateTime.now()
                    .year
                    .toString()
                    .substring(0, (4 - vals[2].length)) +
                vals[2] +
                "/" +
                vals[0].padLeft(2, "0") +
                "/" +
                vals[1].padLeft(2, "0");
          } else
            tmpDatetime += " " + map["Date"];
        } catch (e) {
          tmpDatetime += " " + map["Date"];
        }
      }
      bool am = map["Time"]?.toLowerCase()?.contains("am") ?? false;
      bool pm = map["Time"]?.toLowerCase()?.contains("pm") ?? false;
      String time = map["Time"].replaceAll("am", "").replaceAll("pm", "");
      int part1 = int.parse(time.split(":")[0]);
      int part2 = int.parse(time.split(":")[1]);
      if (part1 == 12) {
        if (am) part1 = 0;
        if (pm) part1 = 12;
      }
      tmpDatetime += " " +
          part1.toString().padLeft(2, "0") +
          ":" +
          part2.toString().padLeft(2, "0") +
          ":00";
      tmpDatetime =
          tmpDatetime.trim().replaceAll("/", "-").replaceAll(".", "-");
      try {
        interestVariables["datetime"] = DateTime.parse(tmpDatetime)
            .toLocal()
            .toString()
            .replaceAll(".000", "");
      } catch (e) {
        interestVariables["datetime"] = tmpDatetime;
      }
      if (map.containsKey("Wind Spd"))
        interestVariables["windspeed"] = map["Wind Spd"];
      if (map.containsKey("Raw Barom"))
        interestVariables["press"] = map["Raw Barom"];
      if (map.containsKey("Wind Dir"))
        interestVariables["winddir"] = deg2WindDir(map["Wind Dir"]);
      if (map.containsKey("Humidity"))
        interestVariables["humidity"] = map["Humidity"];
      if (map.containsKey("Temp"))
        interestVariables["temperature"] = map["Temp"];
      if (map.containsKey("Wind Chill"))
        interestVariables["windchill"] = map["Wind Chill"];
      if (map.containsKey("24HrRain"))
        interestVariables["rain"] = map["24HrRain"];
      if (map.containsKey("Dew Point"))
        interestVariables["dew"] = map["Dew Point"];
      // data about sunrise, sunset, moonrise and moonset cannot be retrieved from daily.csv
      if (_isNumeric(interestVariables["windspeed"])) {
        if (map.containsKey("Wind Spd Unit"))
          interestVariables["windUnit"] = map["Wind Spd Unit"];
      } else
        interestVariables["windUnit"] = "";
      if (_isNumeric(interestVariables["rain"])) {
        if (map.containsKey("24HrRain Unit"))
          interestVariables["rainUnit"] = map["24HrRain Unit"];
      } else
        interestVariables["rainUnit"] = "";
      if (_isNumeric(interestVariables["press"])) {
        if (map.containsKey("Raw Barom Unit"))
          interestVariables["pressUnit"] = map["Raw Barom Unit"];
      } else
        interestVariables["pressUnit"] = "";
      if (_isNumeric(interestVariables["temperature"])) {
        if (map.containsKey("Temp Unit"))
          interestVariables["tempUnit"] = map["Temp Unit"];
      } else
        interestVariables["tempUnit"] = "";
      if (_isNumeric(interestVariables["humidity"])) {
        if (map.containsKey("Humidity Unit"))
          interestVariables["humUnit"] = map["Humidity Unit"];
      } else
        interestVariables["humUnit"] = "";
      if (_isNumeric(interestVariables["dew"])) {
        if (map.containsKey("Dew Point Unit"))
          interestVariables["dewUnit"] = map["Dew Point Unit"];
      } else
        interestVariables["dewUnit"] = "";
      interestVariables = _convertToPrefUnits(interestVariables);
      return interestVariables;
    } catch (e) {
      return null;
    }
  }

  Map<String, String> _convertToPrefUnits(
      Map<String, String> interestVariables) {
    if (_isNumeric(interestVariables["windspeed"]) &&
        appState.prefWindUnit != null &&
        !unitEquals(interestVariables["windUnit"], appState.prefWindUnit)) {
      interestVariables =
          convertWindSpeed(interestVariables, appState.prefWindUnit);
    }
    if (_isNumeric(interestVariables["rain"]) &&
        appState.prefRainUnit != null &&
        !unitEquals(interestVariables["rainUnit"], appState.prefRainUnit)) {
      interestVariables = convertRain(interestVariables, appState.prefRainUnit);
    }
    if (_isNumeric(interestVariables["press"]) &&
        appState.prefPressUnit != null &&
        !unitEquals(interestVariables["pressUnit"], appState.prefPressUnit)) {
      interestVariables =
          convertPressure(interestVariables, appState.prefPressUnit);
    }
    if ((_isNumeric(interestVariables["windchill"]) ||
            _isNumeric(interestVariables["temperature"])) &&
        appState.prefTempUnit != null &&
        !unitEquals(interestVariables["tempUnit"], appState.prefTempUnit)) {
      if (_isNumeric(interestVariables["windchill"]))
        interestVariables =
            convertWindChill(interestVariables, appState.prefTempUnit);
      if (_isNumeric(interestVariables["temperature"]))
        interestVariables =
            convertTemperature(interestVariables, appState.prefTempUnit);
    }
    if (_isNumeric(interestVariables["dew"]) &&
        appState.prefDewUnit != null &&
        !unitEquals(interestVariables["dewUnit"], appState.prefDewUnit)) {
      interestVariables = convertDew(interestVariables, appState.prefDewUnit);
    }
    if (_isNumeric(interestVariables["windspeed"]) &&
        appState.prefWindUnit != null)
      interestVariables["windUnit"] = appState.prefWindUnit;
    if (_isNumeric(interestVariables["rain"]) && appState.prefRainUnit != null)
      interestVariables["rainUnit"] = appState.prefRainUnit;
    if (_isNumeric(interestVariables["press"]) &&
        appState.prefPressUnit != null)
      interestVariables["pressUnit"] = appState.prefPressUnit;
    if (_isNumeric(interestVariables["temperature"]) &&
        appState.prefTempUnit != null)
      interestVariables["tempUnit"] = appState.prefTempUnit;
    if (_isNumeric(interestVariables["dew"]) && appState.prefDewUnit != null)
      interestVariables["dewUnit"] = appState.prefDewUnit;
    return interestVariables;
  }

  bool unitEquals(String unit1, String unit2) {
    return unit1.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase() ==
        unit2.trim().replaceAll("/", "").replaceAll("°", "").toLowerCase();
  }

  convertWindSpeed(Map<String, String> interestVariables, String preferred) {
    double kmh;
    switch (interestVariables["windUnit"]
        .trim()
        .replaceAll("/", "")
        .toLowerCase()) {
      case "kts":
      case "kn":
        {
          kmh = ktsToKmh(double.parse(interestVariables["windspeed"]));
          break;
        }
      case "mph":
        {
          kmh = mphToKmh(double.parse(interestVariables["windspeed"]));
          break;
        }
      case "ms":
        {
          kmh = msToKmh(double.parse(interestVariables["windspeed"]));
          break;
        }
      default:
        {
          kmh = double.parse(interestVariables["windspeed"]);
          break;
        }
    }
    switch (preferred.trim().replaceAll("/", "").toLowerCase()) {
      case "kts":
      case "kn":
        {
          interestVariables["windspeed"] =
              roundToNthDecimal(kmhToKts(kmh), 1).toString();
          break;
        }
      case "mph":
        {
          interestVariables["windspeed"] =
              roundToNthDecimal(kmhToMph(kmh), 1).toString();
          break;
        }
      case "ms":
        {
          interestVariables["windspeed"] =
              roundToNthDecimal(kmhToMs(kmh), 1).toString();
          break;
        }
      default:
        {
          interestVariables["windspeed"] = roundToNthDecimal(kmh, 1).toString();
          break;
        }
    }
    return interestVariables;
  }

  convertRain(Map<String, String> interestVariables, String preferred) {
    if (interestVariables["rainUnit"]
            .trim()
            .replaceAll("/", "")
            .toLowerCase() ==
        "mm") {
      interestVariables["rain"] =
          roundToNthDecimal(mmToIn(double.parse(interestVariables["rain"])), 2)
              .toString();
    } else {
      interestVariables["rain"] =
          roundToNthDecimal(inToMm(double.parse(interestVariables["rain"])), 2)
              .toString();
    }
    return interestVariables;
  }

  convertPressure(Map<String, String> interestVariables, String preferred) {
    double hPa;
    switch (interestVariables["pressUnit"]
        .trim()
        .replaceAll("/", "")
        .toLowerCase()) {
      case "in":
      case "inhg":
        {
          hPa = inhgToHPa(double.parse(interestVariables["press"]));
          break;
        }
      case "mb":
        {
          hPa = mbToHPa(double.parse(interestVariables["press"]));
          break;
        }
      default:
        {
          hPa = double.parse(interestVariables["press"]);
          break;
        }
    }
    switch (preferred.trim().replaceAll("/", "").toLowerCase()) {
      case "in":
      case "inhg":
        {
          interestVariables["press"] =
              roundToNthDecimal(hPaToInhg(hPa), 2).toString();
          break;
        }
      case "mb":
        {
          interestVariables["press"] =
              roundToNthDecimal(hPaToMb(hPa), 3).toString();
          break;
        }
      default:
        {
          interestVariables["press"] = roundToNthDecimal(hPa, 3).toString();
          break;
        }
    }
    return interestVariables;
  }

  convertWindChill(Map<String, String> interestVariables, String preferred) {
    if (interestVariables["tempUnit"]
            .trim()
            .replaceAll("/", "")
            .replaceAll("°", "")
            .toLowerCase() ==
        "f") {
      interestVariables["windchill"] = roundToNthDecimal(
              fToC(double.parse(interestVariables["windchill"])), 1)
          .toString();
    } else {
      interestVariables["windchill"] = roundToNthDecimal(
              cToF(double.parse(interestVariables["windchill"])), 1)
          .toString();
    }
    return interestVariables;
  }

  convertTemperature(Map<String, String> interestVariables, String preferred) {
    if (interestVariables["tempUnit"]
            .trim()
            .replaceAll("/", "")
            .replaceAll("°", "")
            .toLowerCase() ==
        "f") {
      interestVariables["temperature"] = roundToNthDecimal(
              fToC(double.parse(interestVariables["temperature"])), 1)
          .toString();
    } else {
      interestVariables["temperature"] = roundToNthDecimal(
              cToF(double.parse(interestVariables["temperature"])), 1)
          .toString();
    }
    return interestVariables;
  }

  convertDew(Map<String, String> interestVariables, String preferred) {
    if (interestVariables["dewUnit"]
            .trim()
            .replaceAll("/", "")
            .replaceAll("°", "")
            .toLowerCase() ==
        "f") {
      interestVariables["dew"] =
          roundToNthDecimal(fToC(double.parse(interestVariables["dew"])), 1)
              .toString();
    } else {
      interestVariables["dew"] =
          roundToNthDecimal(cToF(double.parse(interestVariables["dew"])), 1)
              .toString();
    }
    return interestVariables;
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
