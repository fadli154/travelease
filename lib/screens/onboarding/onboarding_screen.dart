import 'package:flutter/material.dart';

import '../../services/onboarding_prefs.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.explore_rounded,
      title: 'Discover Amazing Destinations',
      subtitle: 'Explore the best places across Indonesia with stunning photos and details.',
    ),
    _OnboardingPageData(
      icon: Icons.map_rounded,
      title: 'Plan Your Perfect Journey',
      subtitle: 'Find locations on the map and navigate with Google Maps in one tap.',
    ),
    _OnboardingPageData(
      icon: Icons.favorite_rounded,
      title: 'Save Favorites and Share Reviews',
      subtitle: 'Bookmark trips you love and help others with honest reviews.',
    ),
  ];

  Future<void> _finish() async {
    await OnboardingPrefs.markOnboardingCompleted();
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.seed, colorScheme.tertiary],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(data.icon, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? colorScheme.primary : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              child: Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                      child: Text(isLast ? 'Get Started' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
