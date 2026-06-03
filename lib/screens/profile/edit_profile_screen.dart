import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          children: [
            UserAvatar(name: user.name, photoUrl: user.photoUrl, radius: 52),
            const SizedBox(height: 8),
            Text(
              'Avatar uses your name (demo mode — photo upload disabled).',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              controller: TextEditingController(text: user.email),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 32),
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
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
