import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/onboarding_prefs.dart';
import 'admin/admin_shell.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';
import 'onboarding/onboarding_screen.dart';
import 'splash/splash_screen.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? _hasSeenSplash;
  bool? _hasCompletedOnboarding;
  bool _splashDone = false;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final seenSplash = await OnboardingPrefs.hasSeenSplash();
    final onboardingDone = await OnboardingPrefs.hasCompletedOnboarding();
    if (mounted) {
      setState(() {
        _hasSeenSplash = seenSplash;
        _hasCompletedOnboarding = onboardingDone;
        if (seenSplash) _splashDone = true;
        if (onboardingDone) _onboardingDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenSplash == null || _hasCompletedOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasSeenSplash! && !_splashDone) {
      return SplashScreen(onFinished: () => setState(() => _splashDone = true));
    }

    if (!_hasCompletedOnboarding! && !_onboardingDone) {
      return OnboardingScreen(onFinished: () => setState(() => _onboardingDone = true));
    }

    return const _AuthGate();
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLoggedIn) {
      return const LoginScreen(key: ValueKey('auth-login'));
    }

    final uid = auth.currentUser!.uid;

    if (auth.isAdmin) {
      return AdminShell(key: ValueKey('auth-admin-$uid'));
    }

    return MainShell(key: ValueKey('auth-user-$uid'));
  }
}
