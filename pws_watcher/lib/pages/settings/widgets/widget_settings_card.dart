import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetSettingsCard extends StatefulWidget {
  final ThemeService? themeService = getIt<ThemeService>();

  @override
  _WidgetSettingsCardState createState() => _WidgetSettingsCardState();
}

class _WidgetSettingsCardState extends State<WidgetSettingsCard> {
  double refreshInterval = 15;

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Widget",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Widget refresh interval (min):",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Container(
                  margin: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Text(
                    '${refreshInterval.toInt()}',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: SliderTheme(
                    data: SliderThemeData(
                      valueIndicatorTextStyle: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.white),
                    ),
                    child: Slider(
                      value: refreshInterval,
                      onChanged: (value) async {
                        setState(() => refreshInterval = value);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setInt("widget_refresh_interval", value.toInt());
                      },
                      label: refreshInterval.round().toString(),
                      divisions: 59,
                      min: 1,
                      max: 60,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      refreshInterval = prefs.getInt("widget_refresh_interval")!.toDouble();
    });
  }
}
