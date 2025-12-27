import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/behavior.dart';

/// Detail screen for individual behavior - shows full description and source links
class BehaviorDetailScreen extends StatelessWidget {
  final Behavior behavior;

  const BehaviorDetailScreen({
    super.key,
    required this.behavior,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(behavior.name),
        backgroundColor: theme.colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Category and Mood
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          behavior.name,
                          style: theme.typography.xl.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colors.primary),
                        ),
                        child: Text(
                          behavior.category,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mood Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getMoodColor(behavior.mood).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getMoodColor(behavior.mood)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getMoodColor(behavior.mood),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          behavior.mood,
                          style: theme.typography.sm.copyWith(
                            color: _getMoodColor(behavior.mood),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description Section
            Text(
              'Description',
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colors.border),
              ),
              child: Text(
                behavior.description,
                style: theme.typography.base.copyWith(
                  height: 1.6,
                  color: theme.colors.foreground,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Source Information
            if (behavior.source != null) ...[
              Text(
                'Source Information',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FIcons.info,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Source: ${behavior.source}',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (behavior.verifiedBy != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            FIcons.check,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Verified by: ${behavior.verifiedBy}',
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (behavior.sourceUrl != null && behavior.sourceUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._buildSourceButtons(behavior),
                    ],
                    if (behavior.lastUpdated != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            FIcons.calendar,
                            size: 16,
                            color: theme.colors.mutedForeground,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last updated: ${_formatDate(behavior.lastUpdated!)}',
                            style: theme.typography.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tips Section
            Text(
              'Understanding This Behavior',
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FIcons.lightbulb,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember',
                        style: theme.typography.base.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cat body language should be interpreted in context with other signals and the situation. Individual cats may vary in their expressions, and some behaviors can have multiple meanings depending on circumstances.',
                    style: theme.typography.sm.copyWith(
                      height: 1.5,
                      color: theme.colors.foreground,
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

  Color _getMoodColor(String mood) {
    switch (mood) {
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  List<Widget> _buildSourceButtons(Behavior behavior) {
    final sources = behavior.source?.split(',') ?? [];
    final sourceUrls = behavior.sourceUrl?.split(',') ?? [];

    if (sources.isEmpty || sourceUrls.isEmpty) return [];

    final buttons = <Widget>[];
    final minLength = sources.length < sourceUrls.length ? sources.length : sourceUrls.length;

    for (int i = 0; i < minLength; i++) {
      final sourceName = sources[i].trim();
      final url = sourceUrls[i].trim();

      if (url.isNotEmpty) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: () => _launchUrl(url),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FIcons.externalLink,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'View Source: $sourceName',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return buttons;
  }
}
