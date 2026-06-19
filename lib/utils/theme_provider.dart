import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'themeIndex';
  static const String _bankKey = 'bankIndex';

  int _themeIndex = 0;
  int _bankIndex = 0;

  int get themeIndex => _themeIndex;
  int get bankIndex => _bankIndex;
  AppThemeData get currentTheme => AppThemes.themes[_themeIndex];
  BankApp get currentBank => BankApps.apps[_bankIndex];

  ThemeProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box(_boxName);
    _themeIndex = box.get(_themeKey, defaultValue: 0);
    _bankIndex = box.get(_bankKey, defaultValue: 0);
    notifyListeners();
  }

  void setTheme(int index) {
    _themeIndex = index;
    Hive.box(_boxName).put(_themeKey, index);
    notifyListeners();
  }

  void setBank(int index) {
    _bankIndex = index;
    Hive.box(_boxName).put(_bankKey, index);
    notifyListeners();
  }
}
