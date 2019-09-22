import 'package:flutter/material.dart';

enum PWSTheme { Day, Evening, Night, Grey, Blacked }

class ApplicationState {
  ApplicationState({
    this.settingsOpen = false,
    this.countID = 0,
    this.updateSources = true,
    this.updateVisibilities = true,
    this.theme = PWSTheme.Day,
  }) {
    setTheme(this.theme);
  }

  bool updateSources;
  bool updateVisibilities;
  bool settingsOpen;
  int countID;
  PWSTheme theme;
  MaterialColor mainColor;
  Color mainColorDark;

  setTheme(PWSTheme newTheme) {
    this.theme = newTheme;
    switch (newTheme) {
      case PWSTheme.Day:
        this.mainColor = Colors.lightBlue;
        this.mainColorDark = Colors.lightBlue[800];
        break;
      case PWSTheme.Evening:
        this.mainColor = Colors.deepOrange;
        this.mainColorDark = Colors.deepOrange[800];
        break;
      case PWSTheme.Night:
        this.mainColor = Colors.deepPurple;
        this.mainColorDark = Colors.deepPurple[800];
        break;
      case PWSTheme.Grey:
        this.mainColor = Colors.blueGrey;
        this.mainColorDark = Colors.blueGrey[800];
        break;
      case PWSTheme.Blacked:
        const MaterialColor black = const MaterialColor(
          0xFF000000,
          const <int, Color>{
            50: const Color(0xFF000000),
            100: const Color(0xFF000000),
            200: const Color(0xFF000000),
            300: const Color(0xFF000000),
            400: const Color(0xFF000000),
            500: const Color(0xFF000000),
            600: const Color(0xFF000000),
            700: const Color(0xFF000000),
            800: const Color(0xFF000000),
            900: const Color(0xFF000000),
          },
        );
        this.mainColor = black;
        this.mainColorDark = Colors.black;
        break;
    }
  }
}
