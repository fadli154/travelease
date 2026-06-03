import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/app_entry.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeController = await AppThemeController.create();
  final authProvider = AuthProvider();
  authProvider.listenToAuthChanges();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeController>.value(value: themeController),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: TravelEaseApp(themeController: themeController),
    ),
  );
}

class TravelEaseApp extends StatelessWidget {
  const TravelEaseApp({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TravelEase',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeController.themeMode,
          home: const AppEntry(),
          routes: {
            '/guest': (_) => const MainShell(),
          },
        );
      },
    );
  }
}
