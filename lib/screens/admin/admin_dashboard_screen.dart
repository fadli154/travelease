import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../models/review_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_spacing.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.adminName,
    this.service,
  });

  final String adminName;
  final FirebaseService? service;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firebase = service ?? FirebaseService();

    return FutureBuilder<AdminDashboardData>(
      future: _load(firebase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.error(snapshot.error.toString())));
        }

        final data = snapshot.data!;
        return _DashboardBody(adminName: adminName, data: data);
      },
    );
  }

  static Future<AdminDashboardData> _load(FirebaseService firebase) async {
    final results = await Future.wait([
      firebase.getDestinationCount(),
      firebase.getUserCount(),
      firebase.getReviewCount(),
      firebase.getFavoriteCount(),
      firebase.getCategoryDistribution(),
      firebase.getRecentReviews(limit: 6),
    ]);
    return AdminDashboardData(
      destinations: results[0] as int,
      users: results[1] as int,
      reviews: results[2] as int,
      favorites: results[3] as int,
      categories: results[4] as Map<String, int>,
      recentReviews: results[5] as List<ReviewModel>,
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.destinations,
    required this.users,
    required this.reviews,
    required this.favorites,
    required this.categories,
    required this.recentReviews,
  });

  final int destinations;
  final int users;
  final int reviews;
  final int favorites;
  final Map<String, int> categories;
  final List<ReviewModel> recentReviews;
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.adminName, required this.data});

  final String adminName;
  final AdminDashboardData data;

  static const _chartColors = [
    Color(0xFF0D9488),
    Color(0xFF0284C7),
    Color(0xFF7C3AED),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF10B981),
    Color(0xFF6366F1),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = data.categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.helloName(adminName),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.analyticsOverview,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          Text(
            l10n.summary,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cols = w > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _SummaryCard(
                    icon: Icons.place_rounded,
                    label: l10n.destinations,
                    value: '${data.destinations}',
                    color: colorScheme.primaryContainer,
                  ),
                  _SummaryCard(
                    icon: Icons.people_rounded,
                    label: l10n.users,
                    value: '${data.users}',
                    color: colorScheme.tertiaryContainer,
                  ),
                  _SummaryCard(
                    icon: Icons.reviews_rounded,
                    label: l10n.reviews,
                    value: '${data.reviews}',
                    color: colorScheme.secondaryContainer,
                  ),
                  _SummaryCard(
                    icon: Icons.favorite_rounded,
                    label: l10n.favorites,
                    value: '${data.favorites}',
                    color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  ),
                ],
              );
            },
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.section),
            Text(
              l10n.destinationsByCategory,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                  height: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: List.generate(categories.length, (i) {
                              final e = categories[i];
                              final total = categories.fold<int>(
                                0,
                                (s, c) => s + c.value,
                              );
                              final pct = total > 0
                                  ? (e.value / total * 100)
                                  : 0.0;
                              return PieChartSectionData(
                                value: e.value.toDouble(),
                                title: '${pct.toStringAsFixed(0)}%',
                                radius: 52,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                color: _chartColors[i % _chartColors.length],
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categories.take(6).map((e) {
                            final i = categories.indexOf(e);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color:
                                          _chartColors[i % _chartColors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(e.key)),
                                  Text('${e.value}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.barChart,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY:
                              (categories
                                          .map((e) => e.value)
                                          .reduce((a, b) => a > b ? a : b) +
                                      1)
                                  .toDouble(),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= categories.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final label = categories[i].key;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      label.length > 8
                                          ? '${label.substring(0, 7)}…'
                                          : label,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(categories.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: categories[i].value.toDouble(),
                                  color: _chartColors[i % _chartColors.length],
                                  width: 18,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          Text(
            l10n.recentReviews,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.recentReviews.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noReviewsYet),
              ),
            )
          else
            ...data.recentReviews.map((r) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(r.userName.isNotEmpty ? r.userName[0] : '?'),
                  ),
                  title: Text(r.userName),
                  subtitle: Text(
                    r.comment.isEmpty ? l10n.noComment : r.comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.amber[700],
                      ),
                      Text(r.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 26),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
