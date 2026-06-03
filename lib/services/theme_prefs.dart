import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePrefs {
  static const _key = 'theme_mode';

  static Future<ThemeMode> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_key);
      if (index == null) return ThemeMode.system;
      return ThemeMode.values[index.clamp(0, ThemeMode.values.length - 1)];
    } on MissingPluginException {
      return ThemeMode.system;
    }
  }

  static Future<void> save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, mode.index);
    } on MissingPluginException {
      // In-memory only session
    }
  }
}
