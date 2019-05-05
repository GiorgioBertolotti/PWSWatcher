import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWS Watcher',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: PWSStatusPage(title: 'PWS Watcher'),
    );
  }
}

class PWSStatusPage extends StatefulWidget {
  PWSStatusPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PWSStatusPageState createState() => _PWSStatusPageState();
}

class _PWSStatusPageState extends State<PWSStatusPage> {
  var _location = "Location";
  var _date = "01/01/1980";
  var _time = "00:00:00";

  var _windspeed = "0,0";
  var _bar = "0,0";
  var _winddir = "N";
  var _humidity = "0";
  var _temperature = "0,0";
  var _windchill = "0,0";
  var _rain = "0,0";
  var _dew = "0,0";
  var _sunrise = "00:00";
  var _sunset = "00:00";
  var _moonrise = "00:00";
  var _moonset = "00:00";

  var _windunit = "km/h";
  var _rainunit = "mm";
  var _barunit = "mb";
  var _tempunit = "C°";
  var _degunit = "°";
  var _humunit = "%";

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    _retrieveData();
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Builder(
        builder: (context) => SafeArea(
              child: Center(
                child: RefreshIndicator(
                  color: Colors.lightBlue,
                  backgroundColor: Colors.white,
                  key: _refreshIndicatorKey,
                  onRefresh: _retrieveData,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                final snackBar = SnackBar(
                                  content: Text('Settings coming soon!'),
                                );
                                Scaffold.of(context).showSnackBar(snackBar);
                                _settings();
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
                                  "$_location",
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
                                  "$_date $_time",
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
                                    "$_temperature$_tempunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                        "$_windspeed",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_windunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "$_bar",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_barunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                        "$_winddir",
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
                                      Text(
                                        "$_humidity",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_humunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                        "$_temperature",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_tempunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "$_windchill",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_degunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                        "$_rain",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_rainunit",
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "$_dew",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "$_degunit",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "$_sunrise",
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
                                      "$_sunset",
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
                                      "$_moonrise",
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
                                      "$_moonset",
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
    );
  }

  Future<Null> _retrieveData() {
    return _getData().then((document) {
      document.findAllElements("misc").forEach((elem) {
        if (elem.attributes
                .where((attr) =>
                    attr.name.toString() == "data" &&
                    attr.value == "station_location")
                .length >
            0)
          setState(() {
            _location = elem.text;
          });
      });
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
                setState(() {
                  _date = elem.text;
                });
                break;
              }
            case "station_time":
              {
                setState(() {
                  _time = elem.text;
                });
                break;
              }
            case "sunrise":
              {
                setState(() {
                  _sunrise = elem.text;
                });
                break;
              }
            case "sunset":
              {
                setState(() {
                  _sunset = elem.text;
                });
                break;
              }
            case "moonrise":
              {
                setState(() {
                  _moonrise = elem.text;
                });
                break;
              }
            case "moonset":
              {
                setState(() {
                  _moonset = elem.text;
                });
                break;
              }
            case "temp":
              {
                setState(() {
                  _temperature = elem.text;
                });
                break;
              }
            case "hum":
              {
                setState(() {
                  _humidity = elem.text;
                });
                break;
              }
            case "winddir":
              {
                setState(() {
                  _winddir = elem.text;
                });
                break;
              }
            case "windspeed":
              {
                setState(() {
                  _windspeed = elem.text;
                });
                break;
              }
            case "windchill":
              {
                setState(() {
                  _windchill = elem.text;
                });
                break;
              }
            case "dew":
              {
                setState(() {
                  _dew = elem.text;
                });
                break;
              }
            case "barometer":
              {
                setState(() {
                  _bar = elem.text;
                });
                break;
              }
            case "todaysrain":
              {
                setState(() {
                  _rain = elem.text;
                });
                break;
              }
            case "windunit":
              {
                setState(() {
                  _windunit = elem.text;
                });
                break;
              }
            case "rainunit":
              {
                setState(() {
                  _rainunit = elem.text;
                });
                break;
              }
            case "barunit":
              {
                setState(() {
                  _barunit = elem.text;
                });
                break;
              }
            case "tempunit":
              {
                setState(() {
                  _tempunit = elem.text;
                });
                break;
              }
            case "humunit":
              {
                setState(() {
                  _humunit = elem.text;
                });
                break;
              }
          }
        }
      });
    });
  }

  Future<xml.XmlDocument> _getData() async {
    // TODO: Url from shared preferences
    var url = "http://meteorogno.altervista.org/realtime.xml";
    var rawResponse = await http.get(url);
    var response = rawResponse.body;
    return xml.parse(response);
  }

  _settings() {
    // TODO: Open settings page
  }
}
