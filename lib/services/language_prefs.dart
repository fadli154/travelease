import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePrefs {
  static const _key = 'locale_language_code';
  static const _defaultLanguage = 'id';

  static Future<Locale> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code == null) return const Locale(_defaultLanguage);
      return Locale(code);
    } on MissingPluginException {
      return const Locale(_defaultLanguage);
    }
  }

  static Future<void> save(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    } on MissingPluginException {
      // In-memory only
    }
  }
}
