import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';

ThemeData dayTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.lightBlue,
  primaryColor: Colors.lightBlue,
  primaryColorDark: Colors.lightBlue[800],
  backgroundColor: Colors.lightBlue,
  scaffoldBackgroundColor: Colors.lightBlue[800],
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.lightBlue,
    selectionColor: Colors.lightBlue,
  ),
  toggleableActiveColor: Colors.lightBlue,
  buttonTheme:
      ButtonThemeData(colorScheme: ColorScheme.dark(primary: Colors.lightBlue, background: Colors.transparent)),
  iconTheme: IconThemeData(color: Colors.lightBlue),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue).copyWith(
    secondary: Colors.white,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.lightBlue,
  ),
  primaryIconTheme: IconThemeData(color: Colors.white),
  cardColor: Colors.white,
  disabledColor: Color(0xFFCCCCCC),
);

ThemeData eveningTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  primaryColor: Colors.deepOrange,
  primaryColorDark: Colors.deepOrange[800],
  backgroundColor: Colors.deepOrange,
  scaffoldBackgroundColor: Colors.deepOrange[800],
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.deepOrange,
    selectionColor: Colors.deepOrange,
  ),
  toggleableActiveColor: Colors.deepOrange,
  buttonTheme:
      ButtonThemeData(colorScheme: ColorScheme.dark(primary: Colors.deepOrange, background: Colors.transparent)),
  iconTheme: IconThemeData(color: Colors.deepOrange),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange).copyWith(secondary: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.deepOrange,
  ),
  primaryIconTheme: IconThemeData(color: Colors.white),
  cardColor: Colors.white,
  disabledColor: Color(0xFFCCCCCC),
);

ThemeData nightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepPurple,
  primaryColor: Colors.deepPurple,
  primaryColorDark: Colors.deepPurple[800],
  backgroundColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.deepPurple[800],
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.deepPurple,
    selectionColor: Colors.deepPurple,
  ),
  toggleableActiveColor: Colors.deepPurple,
  buttonTheme:
      ButtonThemeData(colorScheme: ColorScheme.dark(primary: Colors.deepPurple, background: Colors.transparent)),
  iconTheme: IconThemeData(color: Colors.deepPurple),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(secondary: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.deepPurple,
  ),
  primaryIconTheme: IconThemeData(color: Colors.white),
  cardColor: Colors.white,
  disabledColor: Color(0xFFCCCCCC),
);

ThemeData greyTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blueGrey,
  primaryColor: Colors.blueGrey,
  primaryColorDark: Colors.blueGrey[800],
  backgroundColor: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.blueGrey[800],
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blueGrey,
    selectionColor: Colors.blueGrey,
  ),
  toggleableActiveColor: Colors.blueGrey,
  buttonTheme: ButtonThemeData(colorScheme: ColorScheme.dark(primary: Colors.blueGrey, background: Colors.transparent)),
  iconTheme: IconThemeData(color: Colors.blueGrey),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blueGrey,
  ),
  primaryIconTheme: IconThemeData(color: Colors.white),
  cardColor: Colors.white,
  disabledColor: Color(0xFFCCCCCC),
);

MaterialColor _black = const MaterialColor(
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

ThemeData blackedTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: _black,
  primaryColor: Colors.black,
  primaryColorDark: Colors.black,
  backgroundColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Colors.black,
  ),
  toggleableActiveColor: Colors.black,
  buttonTheme: ButtonThemeData(colorScheme: ColorScheme.dark(primary: Colors.white, background: Colors.transparent)),
  iconTheme: IconThemeData(color: Colors.black),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: _black,
    brightness: Brightness.dark,
  ).copyWith(secondary: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.black,
  ),
  primaryIconTheme: IconThemeData(color: Colors.white),
  disabledColor: Color(0xFFCCCCCC),
);

class ThemeService {
  BehaviorSubject<ThemeData> themeSubject = BehaviorSubject<ThemeData>.seeded(dayTheme);
  Stream<ThemeData> get theme$ => themeSubject.stream;
  final Box storage;
  String? activeTheme = "day";

  ThemeService(this.storage) {
    final String? theme = this.storage.get("theme", defaultValue: "day");
    if (activeTheme != theme) {
      setTheme(theme);
    }
  }

  void setTheme(String? theme) {
    activeTheme = theme;
    switch (activeTheme) {
      case "day":
        themeSubject.add(dayTheme);
        break;
      case "evening":
        themeSubject.add(eveningTheme);
        break;
      case "night":
        themeSubject.add(nightTheme);
        break;
      case "grey":
        themeSubject.add(greyTheme);
        break;
      case "blacked":
        themeSubject.add(blackedTheme);
        break;
      default:
        themeSubject.add(dayTheme);
        break;
    }
    storage.put("theme", activeTheme);
  }
}
