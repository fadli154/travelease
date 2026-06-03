import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme_controller.dart';
import '../../widgets/theme_toggle_button.dart';
import 'add_destination_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'destination_management_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeController = context.watch<AppThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    final titles = ['Admin Dashboard', 'Destinations', 'Profile'];
    final pages = [
      AdminDashboardScreen(adminName: auth.currentUser?.name ?? 'Admin'),
      const DestinationManagementScreen(),
      const AdminProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          if (_index != 2) ThemeToggleButton(controller: themeController),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Manage',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AddDestinationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            )
          : null,
    );
  }
}
