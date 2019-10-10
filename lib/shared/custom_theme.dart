import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared.dart';

class CustomTheme with ChangeNotifier {
  String _themeValue = "automatic";

  set themeValue(String value) {
    _themeValue = value;
    notifyListeners();
  }

  String get themeValue => _themeValue;

  bool isLightTheme(BuildContext context) {
    if (_themeValue == "automatic") {
      return MediaQuery.of(context).platformBrightness == Brightness.light;
    } else if (_themeValue == "light") {
      return true;
    } else {
      return false;
    }
  }

  bool isBlackTheme() {
    return _themeValue == "black";
  }

  Future<String> getThemeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeValuePrefs;
    if (prefs != null) themeValuePrefs = prefs.getString("theme");
    return themeValuePrefs ?? themeValue;
  }

  Future<void> setThemeValue(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _themeValue = value;
    await prefs.setString("theme", value);
    notifyListeners();
  }
}

class CustomThemes {
  static final Color _lightAccentColor = Colors.blueAccent[700];
  static final ThemeData light = ThemeData(
    accentColor: _lightAccentColor,
    accentColorBrightness: Brightness.dark,
    appBarTheme: AppBarTheme(brightness: Brightness.dark),
    bottomAppBarTheme: BottomAppBarTheme(elevation: 8.0),
    buttonColor: _lightAccentColor,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    ),
    brightness: Brightness.light,
    cursorColor: _lightAccentColor,
    dialogBackgroundColor: Colors.white,
    highlightColor: Colors.transparent,
    indicatorColor: _lightAccentColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
      contentPadding: EdgeInsets.all(14.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightAccentColor, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
    ),
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    splashFactory: CustomInkRipple.splashFactory,
    textSelectionHandleColor: _lightAccentColor,
  );

  static final Color _darkAccentColor = Colors.blueAccent[100];
  static final ThemeData dark = ThemeData(
    accentColor: _darkAccentColor,
    accentColorBrightness: Brightness.light,
    bottomAppBarColor: Color.fromRGBO(52, 52, 54, 1),
    bottomAppBarTheme: BottomAppBarTheme(elevation: 8.0),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    ),
    brightness: Brightness.dark,
    cursorColor: _darkAccentColor,
    dialogBackgroundColor: Color.fromRGBO(62, 62, 63, 1),
    dividerColor: Colors.white24,
    highlightColor: Colors.transparent,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
      contentPadding: EdgeInsets.all(14.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkAccentColor, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey[300]),
    ),
    primaryColor: Color.fromRGBO(22, 22, 23, 1),
    scaffoldBackgroundColor: Color.fromRGBO(22, 22, 25, 1),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    splashColor: Color.fromRGBO(255, 255, 255, .1),
    splashFactory: CustomInkRipple.splashFactory,
    textSelectionHandleColor: _darkAccentColor,
  );

  static final ThemeData black = ThemeData(
    accentColor: _darkAccentColor,
    accentColorBrightness: Brightness.light,
    bottomAppBarColor: Color.fromRGBO(32, 32, 34, 1),
    bottomAppBarTheme: BottomAppBarTheme(elevation: 8.0),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.grey[900]),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    ),
    brightness: Brightness.dark,
    cursorColor: _darkAccentColor,
    dialogBackgroundColor: Color.fromRGBO(52, 52, 53, 1),
    dividerColor: Colors.white24,
    highlightColor: Colors.transparent,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
      contentPadding: EdgeInsets.all(14.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkAccentColor, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      labelStyle: TextStyle(fontSize: 16.0, color: Colors.grey[300]),
    ),
    primaryColor: Color.fromRGBO(0, 0, 0, 1),
    scaffoldBackgroundColor: Color.fromRGBO(0, 0, 0, 1),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    splashColor: Color.fromRGBO(255, 255, 255, .1),
    splashFactory: CustomInkRipple.splashFactory,
    textSelectionHandleColor: _darkAccentColor,
  );
}
