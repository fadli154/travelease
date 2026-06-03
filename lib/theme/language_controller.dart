import 'package:flutter/material.dart';

import '../services/language_prefs.dart';

class LanguageController extends ChangeNotifier {
  LanguageController({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale('id');

  Locale _locale;

  Locale get locale => _locale;

  /// Call before runApp.
  static Future<LanguageController> create() async {
    final initial = await LanguagePrefs.load();
    return LanguageController(initialLocale: initial);
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    await LanguagePrefs.save(newLocale);
    notifyListeners();
  }
}
