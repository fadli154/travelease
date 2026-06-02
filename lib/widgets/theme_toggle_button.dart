import 'package:flutter/material.dart';

import '../theme/app_theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.controller});

  final AppThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isDark = controller.isDark;
        return IconButton(
          tooltip: isDark ? 'Light mode' : 'Dark mode',
          onPressed: controller.toggleTheme,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
            ),
          ),
        );
      },
    );
  }
}
