import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/main.dart';
import 'package:pws_watcher/source.dart';
import 'package:fluro/fluro.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class PWSStatusPage extends StatefulWidget {
  PWSStatusPage({Key key, this.id, this.source}) : super(key: key);

  static var updateVisibilities = false;
  static var updateSources = false;
  final String title = "PWS Watcher";
  int id = -1;
  Source source;

  @override
  _PWSStatusPageState createState() => _PWSStatusPageState();
}

class _PWSStatusPageState extends State<PWSStatusPage> {
  var location = "Location";
  var date = "--/--/----";
  var time = "--:--:--";

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
  var tempunit = "C°";
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

  List<DropdownMenuItem<int>> _sources;
  int _currentItem;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _setVisibilities();
    _populateSources().then((nada) {
      if (widget.id != null && widget.id != -1) {
        _currentItem = widget.id;
        _getSourceData(widget.id).then((source) {
          widget.source = source;
          if(source != null)
            _retrieveData(source.url);
        });
      }
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('Do you want to close the app?'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    child: new Text('Yes'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (PWSStatusPage.updateSources) {
      PWSStatusPage.updateSources = false;
      _cleanData();
      _populateSources().then((nada) {
        if (widget.id != null && widget.id != -1) {
          _currentItem = widget.id;
          _getSourceData(widget.id).then((source) {
            widget.source = source;
            _retrieveData(source.url);
          });
        }
      });
    }
    if (PWSStatusPage.updateVisibilities) {
      PWSStatusPage.updateVisibilities = false;
      _setVisibilities();
    }
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Builder(
          builder: (context) => SafeArea(
                child: Center(
                  child: RefreshIndicator(
                    color: Colors.lightBlue,
                    backgroundColor: Colors.white,
                    key: _refreshIndicatorKey,
                    onRefresh: () {
                      if (widget.source != null)
                        return _retrieveData(widget.source.url);
                    },
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  new Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.blue[900],
                                    ),
                                    child: new DropdownButton<int>(
                                      iconEnabledColor: Colors.white,
                                      value: _currentItem,
                                      items: _sources,
                                      onChanged: _changedSource,
                                      elevation: 2,
                                      style: TextStyle(
                                        color: Colors.black,
                                        decorationColor: Colors.white,
                                        fontSize: 22,
                                      ),
                                      hint: Text(
                                        "Pick a source...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          decorationColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  PWSWatcher.router.navigateTo(
                                      context, "/settings",
                                      transition: TransitionType.inFromBottom);
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "$location",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "$date $time",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 50, bottom: 50),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "$temperature$tempunit",
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w100,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    visibilityWindSpeed
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/windspeed.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel:
                                                        'Wind speed'),
                                              ),
                                              Text(
                                                "$windspeed",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$windunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                    visibilityPressure
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                "$bar",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$barunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/barometer.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel:
                                                        'Barometer'),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    visibilityWindDirection
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/winddir.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel: 'Wind dir'),
                                              ),
                                              Text(
                                                "$winddir",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                    visibilityHumidity
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                "$humidity",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$humunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/humidity.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel: 'Humidity'),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    visibilityTemperature
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/temperature.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel:
                                                        'Temperature'),
                                              ),
                                              Text(
                                                "$temperature",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$tempunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                    visibilityWindChill
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                "$windchill",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$degunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/windchill.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel:
                                                        'Wind chill'),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    visibilityRain
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/rain.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel: 'Rain'),
                                              ),
                                              Text(
                                                "$rain",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$rainunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                    visibilityDew
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                "$dew",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                "$degunit",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w100,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: SvgPicture.asset(
                                                    'assets/images/dew.svg',
                                                    color: Colors.white70,
                                                    width: 20,
                                                    height: 20,
                                                    semanticsLabel:
                                                        'Dew point'),
                                              ),
                                            ],
                                          )
                                        : new Container(),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  visibilitySunrise
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: SvgPicture.asset(
                                                  'assets/images/sunrise.svg',
                                                  color: Colors.white70,
                                                  width: 18,
                                                  height: 18,
                                                  semanticsLabel: 'Sunrise'),
                                            ),
                                            Text(
                                              "$sunrise",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w100,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        )
                                      : new Container(),
                                  visibilitySunset
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: SvgPicture.asset(
                                                  'assets/images/sunset.svg',
                                                  color: Colors.white70,
                                                  width: 18,
                                                  height: 18,
                                                  semanticsLabel: 'Sunset'),
                                            ),
                                            Text(
                                              "$sunset",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w100,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        )
                                      : new Container(),
                                  visibilityMoonrise
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: SvgPicture.asset(
                                                  'assets/images/moonrise.svg',
                                                  color: Colors.white70,
                                                  width: 18,
                                                  height: 18,
                                                  semanticsLabel: 'Moonrise'),
                                            ),
                                            Text(
                                              "$moonrise",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w100,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        )
                                      : new Container(),
                                  visibilityMoonset
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: SvgPicture.asset(
                                                  'assets/images/moonset.svg',
                                                  color: Colors.white70,
                                                  width: 18,
                                                  height: 18,
                                                  semanticsLabel: 'Moonset'),
                                            ),
                                            Text(
                                              "$moonset",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w100,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        )
                                      : new Container(),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
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

  Future<Null> _populateSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DropdownMenuItem<int>> tmp = new List();
    List<String> sources = prefs.getStringList("sources");
    if (sources == null || sources.length == 0) {
      PWSWatcher.router.navigateTo(
          context, "/settings",
          transition: TransitionType.inFromBottom);
      return;
    } else
      for (String sourceJSON in sources) {
        dynamic source = jsonDecode(sourceJSON);
        tmp.add(new DropdownMenuItem<int>(
          value: source["id"],
          child: new Text(
            source["name"],
            style: TextStyle(color: Colors.white),
          ),
        ));
      }
    setState(() {
      _sources = tmp;
      _currentItem = null;
    });
  }

  void _changedSource(int id) async {
    _cleanData();
    setState(() {
      _currentItem = id;
      widget.id = id;
    });
    _getSourceData(id).then((source) {
      widget.source = source;
      _retrieveData(source.url);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("last_used_source", id);
  }

  _cleanData() {
    setState(() {
      location = (widget.source != null) ? widget.source.name : "Location";
      date = "--/--/----";
      time = "--:--:--";
      windspeed = "-";
      bar = "-";
      winddir = "-";
      humidity = "-";
      temperature = "-";
      windchill = "-";
      rain = "-";
      dew = "-";
      sunrise = "--:--";
      sunset = "--:--";
      moonrise = "--:--";
      moonset = "--:--";
      windunit = "km/h";
      rainunit = "mm";
      barunit = "mb";
      tempunit = "C°";
      degunit = "°";
      humunit = "%";
    });
  }

  Future<Null> _retrieveData(String url) {
    if (url.endsWith("xml")) {
      // parsing and variables assignment with realtime.xml
      return _parseRealtimeXML(url).then((map) {
        if (map == null) return;
        _visualizeRealtimeXML(map);
      });
    } else if (url.endsWith("txt")) {
      // parsing and variables assignment with realtime.txt
      return _parseRealtimeTXT(url).then((map) {
        if (map == null) return;
        _visualizeRealtimeTXT(map);
      });
    } else
      return null;
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
              .firstWhere((attr) => attr.name.toString() == "realtime")
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
      location = (map.containsKey("station_location")
          ? map["station_location"]
          : ((widget.source != null) ? widget.source.name : "Location"));
      date = (map.containsKey("station_date")
          ? map["station_date"]
          : "--/--/----");
      time =
          (map.containsKey("station_time") ? map["station_time"] : "--:--:--");
      windspeed = (map.containsKey("windspeed") ? map["windspeed"] : "-");
      bar = (map.containsKey("barometer") ? map["barometer"] : "-");
      winddir = (map.containsKey("winddir") ? map["winddir"] : "-");
      humidity = (map.containsKey("hum") ? map["hum"] : "-");
      temperature = (map.containsKey("temp") ? map["temp"] : "-");
      windchill = (map.containsKey("windchill") ? map["windchill"] : "-");
      rain = (map.containsKey("todaysrain") ? map["todaysrain"] : "-");
      dew = (map.containsKey("dew") ? map["dew"] : "-");
      sunrise = (map.containsKey("sunrise") ? map["sunrise"] : "--:--");
      sunset = (map.containsKey("sunset") ? map["sunset"] : "--:--");
      moonrise = (map.containsKey("moonrise") ? map["moonrise"] : "--:--");
      moonset = (map.containsKey("moonset") ? map["moonset"] : "--:--");
      windunit = (map.containsKey("windunit") ? map["windunit"] : "km/h");
      rainunit = (map.containsKey("rainunit") ? map["rainunit"] : "mm");
      barunit = (map.containsKey("barunit") ? map["barunit"] : "mb");
      tempunit = (map.containsKey("tempunit") ? map["tempunit"] : "C°");
      humunit = (map.containsKey("humunit") ? map["humunit"] : "%");
    });
  }

  _visualizeRealtimeTXT(map) {
    setState(() {
      location = ((widget.source != null) ? widget.source.name : "Location");
      date = (map.containsKey("date") ? map["date"] : "--/--/----");
      time = (map.containsKey("timehhmmss") ? map["timehhmmss"] : "--:--:--");
      windspeed = (map.containsKey("wspeed") ? map["wspeed"] : "-");
      bar = (map.containsKey("press") ? map["press"] : "-");
      winddir = (map.containsKey("currentwdir") ? map["currentwdir"] : "-");
      humidity = (map.containsKey("hum") ? map["hum"] : "-");
      temperature = (map.containsKey("temp") ? map["temp"] : "-");
      windchill = (map.containsKey("wchill") ? map["wchill"] : "-");
      rain = (map.containsKey("rfall") ? map["rfall"] : "-");
      dew = (map.containsKey("dew") ? map["dew"] : "-");
      // these four properties cannot be retrieved from realtime.txt
      sunrise = "--:--";
      sunset = "--:--";
      moonrise = "--:--";
      moonset = "--:--";
      windunit = (map.containsKey("windunit") ? map["windunit"] : "km/h");
      rainunit = (map.containsKey("rainunit") ? map["rainunit"] : "mm");
      barunit = (map.containsKey("pressunit") ? map["pressunit"] : "mb");
      tempunit =
          (map.containsKey("tempunitnodeg") ? map["tempunitnodeg"] : "C°");
      humunit = (map.containsKey("humunit") ? map["humunit"] : "%");
    });
  }

  Future<Source> _getSourceData(int id) async {
    if (id != null && id != -1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> sources = prefs.getStringList("sources");
      Source source;
      if (sources == null || sources.length < 1)
        source = null;
      else {
        for (String sourceJSON in sources) {
          dynamic parsed = jsonDecode(sourceJSON);
          if (parsed["id"] == id) {
            source = new Source(parsed["id"], parsed["name"], parsed["url"]);
            break;
          }
        }
      }
      return source;
    } else
      return null;
  }
}
