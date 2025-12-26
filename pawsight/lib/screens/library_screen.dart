import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../models/behavior.dart';

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
      appBar: AppBar(
        title: const Text('Behavior Library'),
        backgroundColor: theme.colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            FTextField(
              controller: _searchController,
              hint: 'Search behaviors...',
              maxLines: 1,
              onChange: (value) => provider.search(value),
            ),
            const SizedBox(height: 16),

            // Mood Filters
            Text(
              'Filter by Mood',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MoodChip(
                  label: 'Happy',
                  color: Colors.green,
                  isSelected: provider.selectedMood == 'Happy',
                  onTap: () => provider.filterByMood('Happy'),
                ),
                _MoodChip(
                  label: 'Relaxed',
                  color: Colors.blue,
                  isSelected: provider.selectedMood == 'Relaxed',
                  onTap: () => provider.filterByMood('Relaxed'),
                ),
                _MoodChip(
                  label: 'Fearful',
                  color: Colors.orange,
                  isSelected: provider.selectedMood == 'Fearful',
                  onTap: () => provider.filterByMood('Fearful'),
                ),
                _MoodChip(
                  label: 'Aggressive',
                  color: Colors.red,
                  isSelected: provider.selectedMood == 'Aggressive',
                  onTap: () => provider.filterByMood('Aggressive'),
                ),
                _MoodChip(
                  label: 'Mixed',
                  color: Colors.purple,
                  isSelected: provider.selectedMood == 'Mixed',
                  onTap: () => provider.filterByMood('Mixed'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category Filters
            Text(
              'Filter by Category',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CategoryChip(
                  label: 'Tail',
                  icon: FIcons.sparkles,
                  isSelected: provider.selectedCategory == 'Tail',
                  onTap: () => provider.filterByCategory('Tail'),
                ),
                _CategoryChip(
                  label: 'Ears',
                  icon: FIcons.ear,
                  isSelected: provider.selectedCategory == 'Ears',
                  onTap: () => provider.filterByCategory('Ears'),
                ),
                _CategoryChip(
                  label: 'Eyes',
                  icon: FIcons.eye,
                  isSelected: provider.selectedCategory == 'Eyes',
                  onTap: () => provider.filterByCategory('Eyes'),
                ),
                _CategoryChip(
                  label: 'Posture',
                  icon: FIcons.accessibility,
                  isSelected: provider.selectedCategory == 'Posture',
                  onTap: () => provider.filterByCategory('Posture'),
                ),
                _CategoryChip(
                  label: 'Vocal',
                  icon: FIcons.volume2,
                  isSelected: provider.selectedCategory == 'Vocal',
                  onTap: () => provider.filterByCategory('Vocal'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Results Count
            Text(
              '${provider.behaviors.length} behavior(s) found',
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),

            // Behavior List
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.behaviors.isEmpty)
              _EmptyState(theme: theme)
            else
              Column(
                children: provider.behaviors
                    .map((behavior) => _BehaviorCard(behavior: behavior))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mood filter chip widget
class _MoodChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : theme.colors.secondary,
          border: Border.all(
            color: isSelected ? color : theme.colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.typography.xs.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : theme.colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category filter chip widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? theme.colors.primary : theme.colors.secondary,
          border: Border.all(
            color: isSelected ? theme.colors.primary : theme.colors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.colors.primaryForeground
                  : theme.colors.foreground,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.typography.xs.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colors.primaryForeground
                    : theme.colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual behavior card widget
class _BehaviorCard extends StatelessWidget {
  final Behavior behavior;

  const _BehaviorCard({required this.behavior});

  Color _getMoodColor() {
    switch (behavior.mood) {
      case 'Happy':
        return Colors.green;
      case 'Relaxed':
        return Colors.blue;
      case 'Fearful':
        return Colors.orange;
      case 'Aggressive':
        return Colors.red;
      case 'Mixed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (behavior.category) {
      case 'Tail':
        return FIcons.sparkles;
      case 'Ears':
        return FIcons.ear;
      case 'Eyes':
        return FIcons.eye;
      case 'Posture':
        return FIcons.accessibility;
      case 'Vocal':
        return FIcons.volume2;
      default:
        return FIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final moodColor = _getMoodColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mood Color Indicator
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon + Name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(),
                            size: 20,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            behavior.name,
                            style: theme.typography.base.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badges: Category + Mood
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Badge(
                          label: behavior.category,
                          color: theme.colors.mutedForeground,
                        ),
                        _Badge(
                          label: behavior.mood,
                          color: moodColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      behavior.description,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Source attribution (if available)
                    if (behavior.source != null &&
                        behavior.source != 'Placeholder - To be replaced')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              FIcons.info,
                              size: 12,
                              color: theme.colors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Source: ${behavior.source}',
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.mutedForeground,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small badge widget for category/mood labels
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.typography.xs.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Empty state when no behaviors match filters
class _EmptyState extends StatelessWidget {
  final FThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.searchX,
              size: 48,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No behaviors found',
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search query',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
