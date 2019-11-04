import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pws_watcher/resources/state.dart';
import 'package:pws_watcher/ui/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => SafeArea(
          child: Center(
            child: SvgPicture.asset(
              'assets/images/icon.svg',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeStr = prefs.getString("theme") ?? "Day";
    PWSTheme theme;
    switch (themeStr) {
      case "Day":
        theme = PWSTheme.Day;
        break;
      case "Evening":
        theme = PWSTheme.Evening;
        break;
      case "Night":
        theme = PWSTheme.Night;
        break;
      case "Grey":
        theme = PWSTheme.Grey;
        break;
      case "Blacked":
        theme = PWSTheme.Blacked;
        break;
      default:
        theme = PWSTheme.Day;
        break;
    }
    ApplicationState appState = ApplicationState(
      countID: prefs.getInt("count_id") ?? 0,
      theme: theme,
      prefWindUnit: prefs.getString("prefWindUnit"),
      prefRainUnit: prefs.getString("prefRainUnit"),
      prefPressUnit: prefs.getString("prefPressUnit"),
      prefTempUnit: prefs.getString("prefTempUnit"),
      prefDewUnit: prefs.getString("prefDewUnit"),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => Provider<ApplicationState>.value(
          value: appState,
          child: Theme(
            data: ThemeData(primarySwatch: appState.mainColor),
            child: HomePage(),
          ),
        ),
      ),
    );
    prefs.getInt("widget_refresh_interval") ??
        prefs.setInt("widget_refresh_interval", 15);
  }
}
