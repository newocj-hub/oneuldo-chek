import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'themeIndex';

  int _themeIndex = 0;

  int get themeIndex => _themeIndex;
  AppThemeData get currentTheme => AppThemes.themes[_themeIndex];

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box(_boxName);
    _themeIndex = box.get(_themeKey, defaultValue: 0);
    notifyListeners();
  }

  void setTheme(int index) {
    _themeIndex = index;
    Hive.box(_boxName).put(_themeKey, index);
    notifyListeners();
  }
}
