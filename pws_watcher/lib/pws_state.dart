import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/main.dart';
import 'package:pws_watcher/source.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pws_watcher/connection_status.dart';
import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

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

  List<DropdownMenuItem<int>> _sources;
  int _currentItem;
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey _dropdown = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setVisibilities();
    _populateSources().then((nada) {
      if (widget.id != null && widget.id != -1) {
        _currentItem = widget.id;
        _getSourceData(widget.id).then((source) {
          widget.source = source;
          if (source != null) _retrieveData(source.url);
        });
      }
    });
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    setState(() {
      isOffline = !connectionStatus.hasConnection;
    });
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
    if (hasConnection && widget.id != null)
      _getSourceData(widget.id).then((source) {
        widget.source = source;
        if (source != null) _retrieveData(source.url);
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
                      else
                        return _retrieveData(null);
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
                                      key: _dropdown,
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
                                  PWSWatcher.openSettings(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        isOffline
                            ? Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "You are offline.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    Container(
                                      height:
                                          (MediaQuery.of(context).size.height) -
                                              200,
                                      width: MediaQuery.of(context).size.width,
                                      child: FlareActor(
                                        "assets/flare/offline.flr",
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                        animation: "go",
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "$location",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "$date $time",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 50, bottom: 50),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "$temperature$tempunit",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 72,
                                              fontWeight: FontWeight.bold,
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
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/windspeed.svg',
                                                          color: Colors.white,
                                                          width: 20,
                                                          height: 20,
                                                          semanticsLabel:
                                                              'Wind speed'),
                                                    ),
                                                    Text(
                                                      "$windspeed",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$windunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
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
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$barunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/barometer.svg',
                                                          color: Colors.white,
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
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/winddir.svg',
                                                          color: Colors.white,
                                                          width: 20,
                                                          height: 20,
                                                          semanticsLabel:
                                                              'Wind dir'),
                                                    ),
                                                    Text(
                                                      "$winddir",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
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
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$humunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/humidity.svg',
                                                          color: Colors.white,
                                                          width: 20,
                                                          height: 20,
                                                          semanticsLabel:
                                                              'Humidity'),
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
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/temperature.svg',
                                                          color: Colors.white,
                                                          width: 20,
                                                          height: 20,
                                                          semanticsLabel:
                                                              'Temperature'),
                                                    ),
                                                    Text(
                                                      "$temperature",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$tempunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
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
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$degunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/windchill.svg',
                                                          color: Colors.white,
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
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/rain.svg',
                                                          color: Colors.white,
                                                          width: 20,
                                                          height: 20,
                                                          semanticsLabel:
                                                              'Rain'),
                                                    ),
                                                    Text(
                                                      "$rain",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$rainunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
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
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      "$degunit",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: SvgPicture.asset(
                                                          'assets/images/dew.svg',
                                                          color: Colors.white,
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
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: SvgPicture.asset(
                                                        'assets/images/sunrise.svg',
                                                        color: Colors.white,
                                                        width: 18,
                                                        height: 18,
                                                        semanticsLabel:
                                                            'Sunrise'),
                                                  ),
                                                  Text(
                                                    "$sunrise",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
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
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: SvgPicture.asset(
                                                        'assets/images/sunset.svg',
                                                        color: Colors.white,
                                                        width: 18,
                                                        height: 18,
                                                        semanticsLabel:
                                                            'Sunset'),
                                                  ),
                                                  Text(
                                                    "$sunset",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
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
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: SvgPicture.asset(
                                                        'assets/images/moonrise.svg',
                                                        color: Colors.white,
                                                        width: 18,
                                                        height: 18,
                                                        semanticsLabel:
                                                            'Moonrise'),
                                                  ),
                                                  Text(
                                                    "$moonrise",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
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
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: SvgPicture.asset(
                                                        'assets/images/moonset.svg',
                                                        color: Colors.white,
                                                        width: 18,
                                                        height: 18,
                                                        semanticsLabel:
                                                            'Moonset'),
                                                  ),
                                                  Text(
                                                    "$moonset",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
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
      PWSWatcher.openSettings(context);
      return;
    } else {
      var counter = 0;
      for (String sourceJSON in sources) {
        dynamic source = jsonDecode(sourceJSON);
        tmp.add(new DropdownMenuItem<int>(
          value: source["id"],
          child: new Text(
            source["name"],
            style: TextStyle(color: Colors.white),
          ),
        ));
        counter++;
      }
      setState(() {
        _sources = tmp;
        _currentItem = null;
      });
      if (counter > 0 && !PWSWatcher.settingsOpen) {
        SharedPreferences.getInstance().then((prefs) {
          if ((prefs.getInt("last_used_source") ?? -1) == -1) {
            CoachMark coachMarkFAB = CoachMark();
            RenderBox target = _dropdown.currentContext.findRenderObject();
            Rect markRect = target.localToGlobal(Offset.zero) & target.size;
            markRect = Rect.fromCircle(
                center: markRect.center, radius: markRect.longestSide * 0.6);
            coachMarkFAB.show(
                targetContext: _dropdown.currentContext,
                markRect: markRect,
                children: [
                  Center(
                      child: Text("Tap here\nto select a source",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          )))
                ],
                duration: null,
                onClose: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool("coach_mark_shown", true);
                });
          }
        });
      }
    }
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
      tempunit = "°C";
      degunit = "°";
      humunit = "%";
    });
  }

  Future<Null> _retrieveData(String url) {
    if (url == null) return null;
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
      if (map.containsKey("station_date"))
        date = map["station_date"];
      else if (map.containsKey("refresh_time"))
        date = map["refresh_time"].substring(0, 10);
      if (map.containsKey("station_time"))
        time = map["station_time"];
      else if (map.containsKey("refresh_time"))
        time = map["refresh_time"].substring(12);
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
      if (map.containsKey("date")) date = map["date"];
      if (map.containsKey("timehhmmss")) time = map["timehhmmss"];
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

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
