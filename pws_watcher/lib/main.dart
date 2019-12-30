import 'package:flutter/material.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:pws_watcher/splash.dart';
import 'package:pws_watcher/services/connection_status\.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(PWSWatcher());
}

class PWSWatcher extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: getIt<ThemeService>().theme$,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'PWS Watcher',
            theme: snapshot.data,
            home: SplashPage(),
            navigatorKey: navigatorKey,
          );
        });
  }
}
