import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.light,
);

ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  brightness: Brightness.dark,
  
);

class ThemeChanger extends ChangeNotifier {
  SharedPreferences preferences;

  bool _isDarkMode;

  bool get darkTheme => _isDarkMode;

  ThemeChanger() {
    _isDarkMode = false;
    loadTheme();
  }

  toggleTheme() {
    _isDarkMode = !_isDarkMode;
    saveTheme();
    notifyListeners();
  }


  saveTheme() async {
    preferences = await SharedPreferences.getInstance();
    preferences.setBool('theme', _isDarkMode);
  }

  loadTheme() async {
    preferences = await SharedPreferences.getInstance();
    _isDarkMode = preferences.getBool('theme') ?? true;
    notifyListeners();
  }


}