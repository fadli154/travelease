import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _splashSeenKey = 'splash_seen';
  static const _onboardingCompletedKey = 'onboarding_completed';

  static bool _memorySplashSeen = false;
  static bool _memoryOnboardingDone = false;
  static bool? _pluginWorks;

  static Future<SharedPreferences?> _prefs() async {
    if (_pluginWorks == false) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      _pluginWorks = true;
      return prefs;
    } on MissingPluginException {
      _pluginWorks = false;
      return null;
    }
  }

  static Future<bool> hasSeenSplash() async {
    if (_memorySplashSeen) return true;
    final prefs = await _prefs();
    if (prefs == null) return _memorySplashSeen;
    final seen = prefs.getBool(_splashSeenKey) ?? false;
    if (seen) _memorySplashSeen = true;
    return seen;
  }

  static Future<void> markSplashSeen() async {
    _memorySplashSeen = true;
    final prefs = await _prefs();
    await prefs?.setBool(_splashSeenKey, true);
  }

  static Future<bool> hasCompletedOnboarding() async {
    if (_memoryOnboardingDone) return true;
    final prefs = await _prefs();
    if (prefs == null) return _memoryOnboardingDone;
    final done = prefs.getBool(_onboardingCompletedKey) ?? false;
    if (done) _memoryOnboardingDone = true;
    return done;
  }

  static Future<void> markOnboardingCompleted() async {
    _memoryOnboardingDone = true;
    final prefs = await _prefs();
    await prefs?.setBool(_onboardingCompletedKey, true);
  }
}
