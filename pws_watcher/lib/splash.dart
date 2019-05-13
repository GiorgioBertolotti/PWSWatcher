import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluro/fluro.dart';
import 'package:pws_watcher/main.dart';

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
    prefs.setBool("coach_mark_shown", false);
    int index = prefs.getInt("last_used_source") ?? -1;
    PWSWatcher.countID = prefs.getInt("count_id") ?? 0;
    PWSWatcher.router.navigateTo(context, "/pws/" + index.toString(),
        transition: TransitionType.fadeIn);
  }
}
