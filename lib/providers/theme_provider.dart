import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Initialize theme from saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(_themeKey) ?? 'system';

    switch (themeValue) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  // Toggle between themes
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    String themeValue;
    switch (_themeMode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      default:
        themeValue = 'system';
    }
    await prefs.setString(_themeKey, themeValue);

    notifyListeners();
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    String themeValue;
    switch (mode) {
      case ThemeMode.light:
        themeValue = 'light';
        break;
      case ThemeMode.dark:
        themeValue = 'dark';
        break;
      default:
        themeValue = 'system';
    }
    await prefs.setString(_themeKey, themeValue);

    notifyListeners();
  }

  // Get theme display name
  String get themeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}
