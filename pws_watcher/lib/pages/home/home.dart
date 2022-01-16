import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/pages/home/widgets/dots_indicator.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/home/widgets/pws_state.dart';
import 'package:pws_watcher/pages/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pws_watcher/model/pws.dart';
import 'dart:convert';
import 'package:pws_watcher/services/connection_status\.dart';
import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  final String title = "PWS Watcher";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();
  final List<Widget> _pages = [];
  final int _visitsBeforeReviewRequest = 3;

  // Dots indicator variables
  final _kDuration = const Duration(milliseconds: 300);
  final _kCurve = Curves.ease;

  late StreamSubscription _connectionChangeStream;
  bool _isOffline = false;

  final GlobalKey _dotsIndicator = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Checks if the app has internet connection
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();

    setState(() {
      _isOffline = !connectionStatus.hasConnection;
    });

    _connectionChangeStream = connectionStatus.connectionChange.listen(
      (hasConnection) => setState(() {
        _isOffline = !hasConnection;
      }),
    );

    // Checks if the user should be requested of a review
    _checkReviewRequest();

    // Fetches the PWSs
    _populateSources().then((sources) {
      _pages.clear();
      if (sources != null) {
        for (PWS? s in sources) {
          _pages.add(PWSStatePage(s));
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionChangeStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          builder: (context) => provider.Provider<ApplicationState>.value(
            value: provider.Provider.of<ApplicationState>(
              context,
              listen: false,
            ),
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  _buildBody(),
                  _buildSettingsButton(),
                  _pages.length > 1 && !_isOffline
                      ? _buildDotsIndicator()
                      : Container(),
                ],
              ),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  // FUNCTIONS

  Future<List<PWS?>> _populateSources() async {
    List<PWS?> toReturn = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? sources = prefs.getStringList("sources");

    if (sources == null || sources.isEmpty) {
      // If there are no sources to show, route the user to the settings page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => provider.Provider<ApplicationState>.value(
            value: provider.Provider.of<ApplicationState>(
              context,
              listen: false,
            ),
            child: SettingsPage(),
          ),
        ),
      );

      // When he's back, reload the preferences
      await prefs.reload();
      sources = prefs.getStringList("sources");
    }

    // Populate PWS list from a list of JSONs stored in shared prefs
    for (String sourceJSON in sources!) {
      try {
        dynamic source = jsonDecode(sourceJSON);
        toReturn.add(_parsePWS(source));
      } catch (e) {
        print(e);
      }
    }

    return toReturn;
  }

  PWS? _parsePWS(dynamic rawSource) {
    int? id = rawSource['id'];

    if (id == null || id < 0) {
      // Invalid id
      return null;
    }

    return PWS(
      rawSource["id"],
      rawSource["name"],
      rawSource["url"],
      autoUpdateInterval: rawSource["autoUpdateInterval"] ?? 0,
      snapshotUrl: rawSource["snapshotUrl"],
    );
  }

  _checkReviewRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int homepageCounter = prefs.getInt("homepageCounter") ?? 0;

    if (homepageCounter < _visitsBeforeReviewRequest) {
      await prefs.setInt("homepageCounter", ++homepageCounter);

      if (homepageCounter == _visitsBeforeReviewRequest) {
        Flushbar(
          message: "Please leave a 5 star review ❤️",
          duration: null,
          animationDuration: Duration(milliseconds: 350),
          mainButton: FlatButton(
            onPressed: () => LaunchReview.launch(),
            child: Text(
              "REVIEW",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        )..show(context);
      }
    }
  }

  // WIDGETS

  Widget _buildBody() {
    if (_isOffline) {
      // Show the flare animation
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "You are offline.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white),
            ),
            Container(
              height: (MediaQuery.of(context).size.height) - 200,
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
      );
    } else {
      return PageView.builder(
        itemCount: _pages.length,
        physics: AlwaysScrollableScrollPhysics(),
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          if (_pages.length == 0) return Container();
          return _pages[index % _pages.length];
        },
      );
    }
  }

  Widget _buildSettingsButton() {
    return Positioned(
      top: 0.0,
      right: 0.0,
      child: IconButton(
        tooltip: "Settings",
        icon: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(0),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => provider.Provider<ApplicationState>.value(
                value: provider.Provider.of<ApplicationState>(
                  context,
                  listen: false,
                ),
                child: SettingsPage(),
              ),
            ),
          );

          // Fetches the PWSs
          List<PWS?> sources = await _populateSources();

          _pages.clear();

          if (sources != null && sources.isNotEmpty) {
            for (PWS? s in sources) {
              _pages.add(PWSStatePage(s));
            }
          }

          setState(() {});
        },
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Positioned(
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
    );
  }
}
