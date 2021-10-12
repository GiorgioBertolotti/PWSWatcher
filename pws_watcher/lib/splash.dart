import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart' as provider;
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/model/state\.dart';
import 'package:pws_watcher/pages/home/home.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  final ThemeService? themeService = getIt<ThemeService>();

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
      backgroundColor:
          widget.themeService!.themeSubject.value.scaffoldBackgroundColor,
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

    // Set the default refresh interval in shared preferences
    int? refreshInterval = prefs.getInt("widget_refresh_interval");
    if (refreshInterval == null) {
      await prefs.setInt("widget_refresh_interval", 15);
    }

    // Initialize application state
    ApplicationState appState = ApplicationState(
      countID: prefs.getInt("count_id") ?? 0,
      prefWindUnit: prefs.getString("prefWindUnit"),
      prefRainUnit: prefs.getString("prefRainUnit"),
      prefPressUnit: prefs.getString("prefPressUnit"),
      prefTempUnit: prefs.getString("prefTempUnit"),
      prefDewUnit: prefs.getString("prefDewUnit"),
    );

    // Route to home page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => provider.Provider<ApplicationState>.value(
          value: appState,
          child: HomePage(),
        ),
      ),
    );
  }
}
