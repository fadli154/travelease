import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'providers/auth_provider.dart';
import 'screens/app_entry.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';
import 'theme/language_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeController = await AppThemeController.create();
  final languageController = await LanguageController.create();
  final authProvider = AuthProvider();
  authProvider.listenToAuthChanges();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeController>.value(value: themeController),
        ChangeNotifierProvider<LanguageController>.value(value: languageController),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const TravelEaseApp(),
    ),
  );
}

class TravelEaseApp extends StatelessWidget {
  const TravelEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<AppThemeController>();
    final languageController = context.watch<LanguageController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelEase',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.themeMode,
      locale: languageController.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppEntry(),
      routes: {
        '/guest': (_) => const MainShell(),
      },
    );
  }
}
