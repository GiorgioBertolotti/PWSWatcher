import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:pws_watcher/splash.dart';
import 'package:pws_watcher/settings.dart';
import 'package:pws_watcher/pws_state.dart';
import 'package:pws_watcher/connection_status.dart';

void main() {
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(PWSWatcher());
}

class PWSWatcher extends StatelessWidget {
  static final router = Router();
  static bool settingsOpen = false;
  static int countID = 0;

  var pwsHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return PWSStatusPage(id: int.parse(params["id"][0]));
  });

  var settingsHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return SettingsPage();
  });

  @override
  Widget build(BuildContext context) {
    router.define("/pws/:id", handler: pwsHandler);
    router.define("/settings", handler: settingsHandler);
    return MaterialApp(
      title: 'PWS Watcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(),
    );
  }

  static openSettings(var context) {
    router.navigateTo(context, "/settings",
        transition: TransitionType.inFromBottom);
    settingsOpen = true;
  }
}
