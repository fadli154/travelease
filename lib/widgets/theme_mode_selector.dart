import 'package:flutter/material.dart';

import '../theme/app_theme_controller.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, required this.controller});

  final AppThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.light_mode_outlined, size: 16),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.dark_mode_outlined, size: 16),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.settings_brightness_outlined, size: 16),
              ),
            ],
            selected: {controller.themeMode},
            onSelectionChanged: (set) {
              if (set.isNotEmpty) controller.setThemeMode(set.first);
            },
          ),
        );
      },
    );
  }
}
