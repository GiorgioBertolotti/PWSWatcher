import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:pws_watcher/splash.dart';
import 'package:pws_watcher/services/connection_status\.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup get_it
  await setupGetIt();

  // Initialize connection status singleton
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
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
          return OverlaySupport.global(
            child: MaterialApp(
              title: 'PWS Watcher',
              theme: snapshot.data as ThemeData?,
              home: SplashPage(),
              navigatorKey: navigatorKey,
            ),
          );
        });
  }
}
