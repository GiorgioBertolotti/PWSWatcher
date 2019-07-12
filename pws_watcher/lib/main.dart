import 'package:flutter/material.dart';
import 'package:pws_watcher/ui/splash.dart';
import 'package:pws_watcher/resources/connection_status.dart';

void main() {
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(PWSWatcher());
}

class PWSWatcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PWS Watcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(),
    );
  }
}
