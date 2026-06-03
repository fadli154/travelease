import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme_controller.dart';
import '../../theme/language_controller.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/theme_mode_selector.dart';
import '../../widgets/theme_toggle_button.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final themeController = context.watch<AppThemeController>();
    final languageController = context.watch<LanguageController>();
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return _GuestProfileView(themeController: themeController);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      UserAvatar(
                        name: user.name,
                        photoUrl: user.photoUrl,
                        radius: 36,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RoleBadge(role: user.role),
                    ],
                  ),
                ),
              ),
            ),
            actions: [ThemeToggleButton(controller: themeController)],
          ),

          // ── Info section ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _SectionLabel(label: 'Account'),
                  const SizedBox(height: 10),
                  _InfoTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Full Name',
                    subtitle: user.name,
                  ),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: user.email,
                  ),
                  _InfoTile(
                    icon: Icons.shield_outlined,
                    title: 'Role',
                    subtitle: user.role == UserRole.admin
                        ? 'Administrator'
                        : 'User',
                  ),

                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit profile'),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(label: l10n.preferences),
                  const SizedBox(height: 10),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.palette_outlined,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Appearance',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ThemeModeSelector(controller: themeController),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.language_outlined,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.language,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<Locale>(
                              segments: [
                                ButtonSegment<Locale>(
                                  value: const Locale('id'),
                                  label: Text(l10n.indonesian),
                                ),
                                ButtonSegment<Locale>(
                                  value: const Locale('en'),
                                  label: Text(l10n.english),
                                ),
                              ],
                              selected: {languageController.locale},
                              onSelectionChanged: (Set<Locale> selection) {
                                languageController.setLocale(selection.first);
                              },
                              showSelectedIcon: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionLabel(label: 'Session'),
                  const SizedBox(height: 10),

                  // Sign out
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: colorScheme.error,
                      ),
                      title: Text(
                        l10n.signOut,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _confirmSignOut(context, auth),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.screenBottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AuthProvider auth) async {
    final confirmed = await AppFeedback.confirmSignOut(context);
    if (!confirmed) return;
    await auth.signOut();
    if (context.mounted) {
      await AppFeedback.logoutSuccess(context);
    }
  }
}

// ── Guest view ───────────────────────────────────────────────────────────────

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({required this.themeController});
  final AppThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final languageController = context.watch<LanguageController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [ThemeToggleButton(controller: themeController)],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 72,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Text(
                'Not signed in',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to save favorites, access your profile, and more.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ThemeModeSelector(controller: themeController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.language,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<Locale>(
                          segments: [
                            ButtonSegment<Locale>(
                              value: const Locale('id'),
                              label: Text(l10n.indonesian),
                            ),
                            ButtonSegment<Locale>(
                              value: const Locale('en'),
                              label: Text(l10n.english),
                            ),
                          ],
                          selected: {languageController.locale},
                          onSelectionChanged: (Set<Locale> selection) {
                            languageController.setLocale(selection.first);
                          },
                          showSelectedIcon: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login_rounded),
                label: Text(l10n.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            isAdmin ? 'Administrator' : 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
