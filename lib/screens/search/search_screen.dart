import 'package:flutter/material.dart';

import '../../models/destination_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme_controller.dart';
import '../../utils/destination_sections.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_result_tile.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/theme_toggle_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.service,
    this.themeController,
    Stream<List<DestinationModel>>? destinationsStream,
  }) : _destinationsStream = destinationsStream;

  final FirebaseService? service;
  final AppThemeController? themeController;
  final Stream<List<DestinationModel>>? _destinationsStream;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<DestinationModel> _filter(List<DestinationModel> all) {
    var results = all;

    if (_selectedCategory != null) {
      results = results
          .where((d) => d.category == _selectedCategory)
          .toList();
    }

    if (_query.isNotEmpty) {
      results = results.where((d) {
        return d.name.toLowerCase().contains(_query) ||
            d.location.toLowerCase().contains(_query) ||
            d.category.toLowerCase().contains(_query);
      }).toList();
    }

    results.sort((a, b) => b.displayRating.compareTo(a.displayRating));
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firebase = widget.service ?? FirebaseService();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (widget.themeController != null)
                    ThemeToggleButton(controller: widget.themeController!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.sm,
              ),
              child: SearchBar(
                focusNode: _focusNode,
                controller: _searchController,
                hintText: 'Beach, temple, city, island...',
                leading: Icon(Icons.search_rounded, color: colorScheme.primary),
                trailing: _query.isEmpty && _selectedCategory == null
                    ? null
                    : [
                        IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _selectedCategory = null;
                            });
                          },
                        ),
                      ],
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  colorScheme.surfaceContainerHighest,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DestinationModel>>(
                stream:
                    widget._destinationsStream ?? firebase.getDestinations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SearchResultsSkeleton();
                  }

                  if (snapshot.hasError) {
                    return EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Search unavailable',
                      subtitle: '${snapshot.error}',
                    );
                  }

                  final all = snapshot.data ?? [];
                  final categories = DestinationSections.categories(all);
                  final results = _filter(all);
                  final hasFilter = _query.isNotEmpty || _selectedCategory != null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (categories.isNotEmpty)
                        SizedBox(
                          height: 44,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: const Text('All'),
                                  selected: _selectedCategory == null,
                                  onSelected: (_) =>
                                      setState(() => _selectedCategory = null),
                                ),
                              ),
                              ...categories.map((cat) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(cat),
                                    selected: _selectedCategory == cat,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = selected ? cat : null;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      if (!hasFilter && all.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: Text(
                            '${all.length} destinations · tap a category or search',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      Expanded(
                        child: results.isEmpty
                            ? EmptyState(
                                icon: hasFilter
                                    ? Icons.search_off_rounded
                                    : Icons.travel_explore_rounded,
                                title: hasFilter
                                    ? 'No results found'
                                    : 'Discover Indonesia',
                                subtitle: hasFilter
                                    ? 'Try another keyword or clear filters.'
                                    : 'Search by name, location, or pick a category above.',
                                compact: true,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.screenH,
                                  AppSpacing.md,
                                  AppSpacing.screenH,
                                  AppSpacing.screenBottom,
                                ),
                                itemCount: results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  return SearchResultTile(
                                    destination: results[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
