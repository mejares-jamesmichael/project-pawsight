import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../widgets/library_widgets.dart';

/// Library screen - displays searchable cat behavior library with filters
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load behaviors when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadBehaviors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<LibraryProvider>();

    return Scaffold(
      backgroundColor: theme.colors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Behavior Library'),
        backgroundColor: theme.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Clear filters button
          if (provider.selectedMoods.isNotEmpty ||
              provider.selectedCategories.isNotEmpty ||
              _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(FIcons.x),
              onPressed: () {
                _searchController.clear();
                provider.clearAllFilters();
              },
              tooltip: 'Clear all filters',
            ),
        ],
      ),
      body: Container(
        color: theme.colors.background,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                const BehaviorSearchBar(),
                const SizedBox(height: 16),

                // Sorting Dropdown
                const BehaviorSorter(),
                const SizedBox(height: 16),

                // Mood Filters
                const MoodFilters(),
                const SizedBox(height: 16),

                // Category Filters
                const CategoryFilters(),
                const SizedBox(height: 16),

                // Results Count
                Text(
                  '${provider.behaviors.length} behavior(s) found',
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 12),

                // Error State
                if (provider.error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FIcons.x,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.error!,
                            style: theme.typography.base.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FButton(
                            onPress: () {
                              provider.clearError();
                              provider.loadBehaviors();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                // Behavior List
                else if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: FCircularProgress(),
                    ),
                  )
                else if (provider.behaviors.isEmpty)
                  const BehaviorEmptyState()
                else
                  Column(
                    children: provider.behaviors
                        .map((behavior) => BehaviorCard(behavior: behavior))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
