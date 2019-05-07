import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/main.dart';
import 'package:fluro/fluro.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class PWSStatusPage extends StatefulWidget {
  PWSStatusPage({Key key, this.id, this.url}) : super(key: key);

  static var updateSources = false;
  final String title = "PWS Watcher";
  int id = -1;
  String url;

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

  List<DropdownMenuItem<int>> _sources;
  int _currentItem;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    populateSources().then((nada) {
      if (widget.id != null && widget.id != -1) {
        _currentItem = widget.id;
        getUrl(widget.id).then((url) => retrieveData(url));
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
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (PWSStatusPage.updateSources) {
      PWSStatusPage.updateSources = false;
      cleanData();
      populateSources().then((nada) {
        if (widget.id != null && widget.id != -1) {
          _currentItem = widget.id;
          getUrl(widget.id).then((url) => retrieveData(url));
        }
      });
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
                      return retrieveData(widget.url);
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
                                      onChanged: changedSource,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: SvgPicture.asset(
                                              'assets/images/windspeed.svg',
                                              color: Colors.white70,
                                              width: 20,
                                              height: 20,
                                              semanticsLabel: 'Wind speed'),
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
                                    ),
                                    Row(
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
                                          padding: EdgeInsets.only(left: 10),
                                          child: SvgPicture.asset(
                                              'assets/images/barometer.svg',
                                              color: Colors.white70,
                                              width: 20,
                                              height: 20,
                                              semanticsLabel: 'Barometer'),
                                        ),
                                      ],
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
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
                                    ),
                                    Row(
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
                                          padding: EdgeInsets.only(left: 10),
                                          child: SvgPicture.asset(
                                              'assets/images/humidity.svg',
                                              color: Colors.white70,
                                              width: 20,
                                              height: 20,
                                              semanticsLabel: 'Humidity'),
                                        ),
                                      ],
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: SvgPicture.asset(
                                              'assets/images/temperature.svg',
                                              color: Colors.white70,
                                              width: 20,
                                              height: 20,
                                              semanticsLabel: 'Temperature'),
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
                                    ),
                                    Row(
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
                                          padding: EdgeInsets.only(left: 10),
                                          child: SvgPicture.asset(
                                              'assets/images/windchill.svg',
                                              color: Colors.white70,
                                              width: 20,
                                              height: 20,
                                              semanticsLabel: 'Wind chill'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
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
                                    ),
                                    Row(
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
                                          padding: EdgeInsets.only(left: 10),
                                          child: SvgPicture.asset(
                                              'assets/images/dew.svg',
                                              color: Colors.white70,
                                              width: 20,
                                              height: 20,
                                              semanticsLabel: 'Dew point'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
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
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
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
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
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
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
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
                                  ),
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

  Future<Null> populateSources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<DropdownMenuItem<int>> tmp = new List();
    List<String> sources = prefs.getStringList("sources");
    if (sources != null)
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

  void changedSource(int id) async {
    cleanData();
    setState(() {
      _currentItem = id;
      widget.id = id;
    });
    getUrl(id).then((url) {
      widget.url = url;
      retrieveData(url);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("last_used_source", id);
  }

  cleanData() {
    setState(() {
      location = "Location";
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

  Future<Null> retrieveData(url) {
    return _getData(url).then((document) {
      if (document == null) return;
      document.findAllElements("misc").forEach((elem) {
        if (elem.attributes
                .where((attr) =>
                    attr.name.toString() == "data" &&
                    attr.value == "station_location")
                .length >
            0) {
          setState(() {
            location = elem.text;
          });
        }
      });
      setState(() {
        document.findAllElements("data").forEach((elem) {
          var variable;
          try {
            variable = elem.attributes
                .firstWhere((attr) => attr.name.toString() == "realtime")
                .value;
          } catch (Exception) {}
          if (variable != null) {
            switch (variable) {
              case "station_date":
                {
                  date = elem.text;
                  break;
                }
              case "station_time":
                {
                  time = elem.text;
                  break;
                }
              case "sunrise":
                {
                  sunrise = elem.text;
                  break;
                }
              case "sunset":
                {
                  sunset = elem.text;
                  break;
                }
              case "moonrise":
                {
                  moonrise = elem.text;
                  break;
                }
              case "moonset":
                {
                  moonset = elem.text;
                  break;
                }
              case "temp":
                {
                  temperature = elem.text;
                  break;
                }
              case "hum":
                {
                  humidity = elem.text;
                  break;
                }
              case "winddir":
                {
                  winddir = elem.text;
                  break;
                }
              case "windspeed":
                {
                  windspeed = elem.text;
                  break;
                }
              case "windchill":
                {
                  windchill = elem.text;
                  break;
                }
              case "dew":
                {
                  dew = elem.text;
                  break;
                }
              case "barometer":
                {
                  bar = elem.text;
                  break;
                }
              case "todaysrain":
                {
                  rain = elem.text;
                  break;
                }
              case "windunit":
                {
                  windunit = elem.text;
                  break;
                }
              case "rainunit":
                {
                  rainunit = elem.text;
                  break;
                }
              case "barunit":
                {
                  barunit = elem.text;
                  break;
                }
              case "tempunit":
                {
                  tempunit = elem.text;
                  break;
                }
              case "humunit":
                {
                  humunit = elem.text;
                  break;
                }
            }
          }
        });
      });
    });
  }

  Future<xml.XmlDocument> _getData(String url) async {
    try {
      var rawResponse = await http.get(url);
      var response = rawResponse.body;
      return xml.parse(response);
    } catch (Exception) {
      return null;
    }
  }

  Future<String> getUrl(int index) async {
    if (index != null && index != -1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> sources = prefs.getStringList("sources");
      String url = null;
      if (sources == null || sources.length < 1)
        url = null;
      else {
        for (String sourceJSON in sources) {
          dynamic source = jsonDecode(sourceJSON);
          if (source["id"] == index) {
            url = source["url"];
            break;
          }
        }
      }
      return url;
    } else
      return null;
  }
}
