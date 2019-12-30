import 'package:flutter/material.dart';
import 'package:pws_watcher/get_it_setup.dart';
import 'package:pws_watcher/pages/settings/widgets/theme_toggle_button.dart';
import 'package:pws_watcher/services/theme_service.dart';

class ThemeSettingsCard extends StatefulWidget {
  final ThemeService themeService = getIt<ThemeService>();

  @override
  _ThemeSettingsCardState createState() => _ThemeSettingsCardState();
}

class _ThemeSettingsCardState extends State<ThemeSettingsCard> {
  var _themeSelection = [true, false, false, false, false];

  @override
  void initState() {
    _themeSelection = [
      widget.themeService.activeTheme == "day",
      widget.themeService.activeTheme == "evening",
      widget.themeService.activeTheme == "night",
      widget.themeService.activeTheme == "grey",
      widget.themeService.activeTheme == "blacked",
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Theme settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: ToggleButtons(
                children: [
                  ThemeToggleButton("Day", Colors.lightBlue),
                  ThemeToggleButton("Evening", Colors.deepOrange),
                  ThemeToggleButton("Night", Colors.deepPurple),
                  ThemeToggleButton("Grey", Colors.blueGrey),
                  ThemeToggleButton("Blacked", Colors.black),
                ],
                onPressed: (int index) async {
                  for (int buttonIndex = 0;
                      buttonIndex < _themeSelection.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      _themeSelection[buttonIndex] = true;
                    } else {
                      _themeSelection[buttonIndex] = false;
                    }
                  }
                  switch (index) {
                    case 0:
                      widget.themeService.setTheme("day");
                      break;
                    case 1:
                      widget.themeService.setTheme("evening");
                      break;
                    case 2:
                      widget.themeService.setTheme("night");
                      break;
                    case 3:
                      widget.themeService.setTheme("grey");
                      break;
                    case 4:
                      widget.themeService.setTheme("blacked");
                      break;
                  }
                  setState(() {});
                },
                isSelected: _themeSelection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
