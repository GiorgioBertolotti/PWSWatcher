import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/pages/home/widgets/dots_indicator.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/home/widgets/pws_state.dart';
import 'package:pws_watcher/pages/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/model/source.dart';
import 'dart:convert';
import 'package:pws_watcher/services/connection_status\.dart';
import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  final String title = "PWS Watcher";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = PageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  final List<Widget> _pages = List();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  final GlobalKey _dotsIndicator = GlobalKey();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    super.dispose();
    _connectionChangeStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ApplicationState>(
      context,
      listen: false,
    ).updateSources) {
      Provider.of<ApplicationState>(
        context,
        listen: false,
      ).updateSources = false;
      _populateSources().then((sources) {
        _pages.clear();
        if (sources != null) {
          for (Source s in sources) {
            _pages.add(PWSStatePage(s));
          }
          setState(() {});
        }
      });
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Theme.of(context).primaryColorDark,
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (context) => Provider<ApplicationState>.value(
            value: Provider.of<ApplicationState>(
              context,
              listen: false,
            ),
            child: SafeArea(
              child: Stack(
                children: <Widget>[
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
                                    (MediaQuery.of(context).size.height) - 200,
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
                      : PageView.builder(
                          itemCount: _pages.length,
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: _controller,
                          itemBuilder: (BuildContext context, int index) {
                            if (_pages.length == 0) return Container();
                            return _pages[index % _pages.length];
                          },
                        ),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: IconButton(
                      tooltip: "Settings",
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => Provider<ApplicationState>.value(
                              value: Provider.of<ApplicationState>(
                                context,
                                listen: false,
                              ),
                              child: SettingsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _pages.length > 1 && !isOffline
                      ? Positioned(
                          top: 20.0,
                          right: 0.0,
                          left: 0.0,
                          child: Center(
                            child: Container(
                              key: _dotsIndicator,
                              child: DotsIndicator(
                                controller: _controller,
                                itemCount: _pages.length,
                                onPageSelected: (int page) {
                                  _controller.animateToPage(
                                    page,
                                    duration: _kDuration,
                                    curve: _kCurve,
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Future<List<Source>> _populateSources() async {
    List<Source> toReturn;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> sources = prefs.getStringList("sources");
    if (sources == null || sources.length == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Provider<ApplicationState>.value(
            value: Provider.of<ApplicationState>(
              context,
              listen: false,
            ),
            child: SettingsPage(),
          ),
        ),
      );
    } else {
      toReturn = List();
      for (String sourceJSON in sources) {
        try {
          dynamic source = jsonDecode(sourceJSON);
          toReturn.add(await _getSourceData(source["id"]));
        } catch (e) {
          print(e);
        }
      }
    }
    return toReturn;
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
            source = Source(parsed["id"], parsed["name"], parsed["url"],
                autoUpdateInterval: (parsed["autoUpdateInterval"] != null)
                    ? parsed["autoUpdateInterval"]
                    : 0);
            break;
          }
        }
      }
      return source;
    } else
      return null;
  }
}
