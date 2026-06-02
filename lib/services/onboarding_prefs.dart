import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the splash screen was shown.
/// Falls back to in-memory storage if the native plugin is unavailable
/// (e.g. after hot restart before a full rebuild).
class OnboardingPrefs {
  static const _splashSeenKey = 'splash_seen';

  static bool _memorySeen = false;
  static bool? _pluginWorks;

  static Future<bool> hasSeenSplash() async {
    if (_memorySeen) return true;

    if (_pluginWorks == false) {
      return _memorySeen;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _pluginWorks = true;
      final seen = prefs.getBool(_splashSeenKey) ?? false;
      if (seen) _memorySeen = true;
      return seen;
    } on MissingPluginException catch (e, st) {
      _pluginWorks = false;
      if (kDebugMode) {
        debugPrint(
          'OnboardingPrefs: shared_preferences unavailable ($e). '
          'Stop the app and run `flutter run` (full rebuild). '
          'Using in-memory splash flag for this session.',
        );
        debugPrint('$st');
      }
      return _memorySeen;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('OnboardingPrefs.hasSeenSplash failed: $e');
        debugPrint('$st');
      }
      return _memorySeen;
    }
  }

  static Future<void> markSplashSeen() async {
    _memorySeen = true;

    if (_pluginWorks == false) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _pluginWorks = true;
      await prefs.setBool(_splashSeenKey, true);
    } on MissingPluginException {
      _pluginWorks = false;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('OnboardingPrefs.markSplashSeen failed: $e');
        debugPrint('$st');
      }
    }
  }
}
