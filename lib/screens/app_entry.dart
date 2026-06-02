import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/onboarding_prefs.dart';
import 'admin/admin_shell.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';
import 'splash/splash_screen.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? _hasSeenSplash;
  bool _splashAnimationDone = false;

  @override
  void initState() {
    super.initState();
    _loadSplashFlag();
  }

  Future<void> _loadSplashFlag() async {
    final seen = await OnboardingPrefs.hasSeenSplash();
    if (mounted) {
      setState(() {
        _hasSeenSplash = seen;
        if (seen) _splashAnimationDone = true;
      });
    }
  }

  void _onSplashFinished() {
    setState(() => _splashAnimationDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenSplash == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final showSplash = !_hasSeenSplash! && !_splashAnimationDone;
    if (showSplash) {
      return SplashScreen(onFinished: _onSplashFinished);
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
      return const LoginScreen();
    }

    if (auth.isAdmin) {
      return const AdminShell();
    }

    return const MainShell();
  }
}
