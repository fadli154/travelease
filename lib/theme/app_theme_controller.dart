import 'package:flutter/material.dart';

import '../services/theme_prefs.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({ThemeMode? initialMode})
      : _themeMode = initialMode ?? ThemeMode.system;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  bool get isLight => _themeMode == ThemeMode.light;

  bool get isSystem => _themeMode == ThemeMode.system;

  /// Call before runApp.
  static Future<AppThemeController> create() async {
    final mode = await ThemePrefs.load();
    return AppThemeController(initialMode: mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await ThemePrefs.save(mode);
    notifyListeners();
  }

  void toggleTheme() {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}
