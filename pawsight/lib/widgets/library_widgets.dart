import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../models/behavior.dart';
import '../screens/behavior_detail_screen.dart';

/// Search bar widget for the behavior library
class BehaviorSearchBar extends StatefulWidget {
  const BehaviorSearchBar({super.key});

  @override
  State<BehaviorSearchBar> createState() => _BehaviorSearchBarState();
}

class _BehaviorSearchBarState extends State<BehaviorSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();

    return FTextField(
      controller: _controller,
      hint: 'Search behaviors...',
      maxLines: 1,
      onChange: (value) => provider.search(value),
    );
  }
}

/// Sorting dropdown widget for the behavior library
class BehaviorSorter extends StatelessWidget {
  const BehaviorSorter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<LibraryProvider>();

    return Row(
      children: [
        Text(
          'Sort by:',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colors.border),
            ),
            child: Material(
              color: Colors.transparent,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: provider.sortBy,
                  isExpanded: true,
                  icon: Icon(FIcons.chevronDown, size: 16, color: theme.colors.mutedForeground),
                  style: theme.typography.sm.copyWith(color: theme.colors.foreground),
                  dropdownColor: theme.colors.secondary,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'category', child: Text('Category')),
                    DropdownMenuItem(value: 'mood', child: Text('Mood')),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setSorting(value);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mood filter chips widget (Horizontal Scroll)
class MoodFilters extends StatelessWidget {
  const MoodFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<LibraryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              MoodFilterChip(
                label: 'Happy',
                color: Colors.green,
                isSelected: provider.selectedMoods.contains('Happy'),
                onTap: () => provider.toggleMoodFilter('Happy'),
              ),
              const SizedBox(width: 8),
              MoodFilterChip(
                label: 'Relaxed',
                color: Colors.blue,
                isSelected: provider.selectedMoods.contains('Relaxed'),
                onTap: () => provider.toggleMoodFilter('Relaxed'),
              ),
              const SizedBox(width: 8),
              MoodFilterChip(
                label: 'Fearful',
                color: Colors.orange,
                isSelected: provider.selectedMoods.contains('Fearful'),
                onTap: () => provider.toggleMoodFilter('Fearful'),
              ),
              const SizedBox(width: 8),
              MoodFilterChip(
                label: 'Aggressive',
                color: Colors.red,
                isSelected: provider.selectedMoods.contains('Aggressive'),
                onTap: () => provider.toggleMoodFilter('Aggressive'),
              ),
              const SizedBox(width: 8),
              MoodFilterChip(
                label: 'Mixed',
                color: Colors.purple,
                isSelected: provider.selectedMoods.contains('Mixed'),
                onTap: () => provider.toggleMoodFilter('Mixed'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual mood filter chip
class MoodFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodFilterChip({
    super.key,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : theme.colors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : theme.colors.border,
            width: 1,
          ),
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
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.typography.sm.copyWith(
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

/// Category filter chips widget (Horizontal Scroll)
class CategoryFilters extends StatelessWidget {
  const CategoryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<LibraryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CategoryFilterChip(
                label: 'Tail',
                icon: FIcons.sparkles,
                isSelected: provider.selectedCategories.contains('Tail'),
                onTap: () => provider.toggleCategoryFilter('Tail'),
              ),
              const SizedBox(width: 8),
              CategoryFilterChip(
                label: 'Ears',
                icon: FIcons.ear,
                isSelected: provider.selectedCategories.contains('Ears'),
                onTap: () => provider.toggleCategoryFilter('Ears'),
              ),
              const SizedBox(width: 8),
              CategoryFilterChip(
                label: 'Eyes',
                icon: FIcons.eye,
                isSelected: provider.selectedCategories.contains('Eyes'),
                onTap: () => provider.toggleCategoryFilter('Eyes'),
              ),
              const SizedBox(width: 8),
              CategoryFilterChip(
                label: 'Posture',
                icon: FIcons.accessibility,
                isSelected: provider.selectedCategories.contains('Posture'),
                onTap: () => provider.toggleCategoryFilter('Posture'),
              ),
              const SizedBox(width: 8),
              CategoryFilterChip(
                label: 'Vocal',
                icon: FIcons.volume2,
                isSelected: provider.selectedCategories.contains('Vocal'),
                onTap: () => provider.toggleCategoryFilter('Vocal'),
              ),
              const SizedBox(width: 8),
              CategoryFilterChip(
                label: 'Whiskers',
                icon: FIcons.zap,
                isSelected: provider.selectedCategories.contains('Whiskers'),
                onTap: () => provider.toggleCategoryFilter('Whiskers'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual category filter chip
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colors.primary : theme.colors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colors.primary : theme.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colors.primaryForeground
                  : theme.colors.foreground,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.typography.sm.copyWith(
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

/// Individual behavior card widget (Refactored to FCard)
class BehaviorCard extends StatelessWidget {
  final Behavior behavior;

  const BehaviorCard({super.key, required this.behavior});

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
      case 'Whiskers':
        return FIcons.zap;
      default:
        return FIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final moodColor = _getMoodColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BehaviorDetailScreen(behavior: behavior),
            ),
          );
        },
        child: FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      behavior.name,
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(FIcons.chevronRight, size: 16, color: theme.colors.mutedForeground),
                ],
              ),
              const SizedBox(height: 12), // Spacing between title and tags

              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BehaviorBadge(
                    label: behavior.category,
                    color: theme.colors.mutedForeground,
                    icon: _getCategoryIcon(),
                  ),
                  BehaviorBadge(
                    label: behavior.mood,
                    color: moodColor,
                  ),
                ],
              ),
              const SizedBox(height: 12), // Spacing between tags and description

              // Description
              Text(
                behavior.description,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small badge widget for category/mood labels
class BehaviorBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const BehaviorBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.typography.xs.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no behaviors match filters
class BehaviorEmptyState extends StatelessWidget {
  const BehaviorEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.muted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FIcons.searchX,
                size: 32,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No behaviors found',
              style: theme.typography.lg.copyWith(
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