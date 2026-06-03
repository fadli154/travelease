import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme_controller.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/theme_mode_selector.dart';
import '../../widgets/user_avatar.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.name;
    }
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final service = FirebaseService();
      final name = _nameController.text.trim();
      await service.updateUserProfile(userId: user.uid, name: name);
      auth.updateLocalUser(user.copyWith(name: name));
      if (mounted) {
        AppFeedback.success(context, 'Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.error(
          context,
          AppFeedback.actionError(e, 'Update profile'),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final ok = await AppFeedback.confirmSignOut(context);
    if (!ok || !mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (!mounted) return;
    await AppFeedback.logoutSuccess(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;
    final themeController = context.watch<AppThemeController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  UserAvatar(
                    name: user.name,
                    photoUrl: user.photoUrl,
                    radius: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Demo mode: avatar generated from your name.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            enabled: !_saving,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            enabled: false,
            controller: TextEditingController(text: user.email),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            enabled: false,
            controller: TextEditingController(text: 'Administrator'),
            decoration: const InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.shield_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ThemeModeSelector(controller: themeController),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save profile'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: auth.isAuthActionLoading ? null : _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
