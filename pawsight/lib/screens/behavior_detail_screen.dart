import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_constants.dart';
import '../models/behavior.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class BehaviorDetailScreen extends StatefulWidget {
  final Behavior behavior;

  const BehaviorDetailScreen({
    super.key,
    required this.behavior,
  });

  @override
  State<BehaviorDetailScreen> createState() => _BehaviorDetailScreenState();
}

class _BehaviorDetailScreenState extends State<BehaviorDetailScreen> {
  int _currentImageIndex = 0;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final imagePaths = widget.behavior.imagePath.split(',');

    return FScaffold(
      header: FHeader(
        title: Text(
          widget.behavior.name,
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // FHeader automatically handles the back button
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel or Single Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colors.secondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      itemCount: imagePaths.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final path = imagePaths[index].trim();
                        return Image.asset(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Failed to load image: $path. Error: $error');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FIcons.imageOff, size: 48, color: theme.colors.mutedForeground),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Image not available',
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Page Indicator
                    if (imagePaths.length > 1)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imagePaths.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? theme.colors.primary
                                    : theme.colors.background.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Header Card with Category and Mood
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.behavior.name,
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg), // Added spacing between title and tags
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _StatusBadge(
                        label: widget.behavior.category,
                        icon: _getCategoryIcon(widget.behavior.category),
                        color: theme.colors.primary,
                      ),
                      _StatusBadge(
                        label: widget.behavior.mood,
                        icon: null, // Mood color handles visual
                        color: _getMoodColor(widget.behavior.mood),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Description Section
            Text(
              'Description',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colors.border),
              ),
              child: Text(
                widget.behavior.description,
                style: theme.typography.base.copyWith(
                  height: 1.6,
                  color: theme.colors.foreground,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Source Information
            if (widget.behavior.source != null) ...[
              Text(
                'Source Information',
                style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              FCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: FIcons.info,
                      label: 'Source',
                      value: widget.behavior.source!,
                      theme: theme,
                    ),
                    if (widget.behavior.verifiedBy != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        icon: FIcons.check,
                        label: 'Verified by',
                        value: widget.behavior.verifiedBy!,
                        iconColor: Colors.green,
                        theme: theme,
                      ),
                    ],
                    if (widget.behavior.lastUpdated != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        icon: FIcons.calendar,
                        label: 'Last updated',
                        value: _formatDate(widget.behavior.lastUpdated!),
                        theme: theme,
                      ),
                    ],
                    if (widget.behavior.sourceUrl != null && widget.behavior.sourceUrl!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ..._buildSourceButtons(widget.behavior, theme),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Ask AI Button
            _AskAiButton(behavior: widget.behavior),

            const SizedBox(height: AppSpacing.xl),

            // Tips Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(FIcons.lightbulb, size: 20, color: Colors.blue),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Understanding Context',
                          style: theme.typography.base.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Cat body language should be interpreted in context with other signals and the situation. Individual cats may vary in their expressions.',
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
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy': return AppColors.moodHappy;
      case 'Relaxed': return AppColors.moodRelaxed;
      case 'Fearful': return AppColors.moodFearful;
      case 'Aggressive': return AppColors.moodAggressive;
      case 'Mixed': return AppColors.moodMixed;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tail': return FIcons.sparkles;
      case 'Ears': return FIcons.ear;
      case 'Eyes': return FIcons.eye;
      case 'Posture': return FIcons.accessibility;
      case 'Vocal': return FIcons.volume2;
      case 'Whiskers': return FIcons.zap;
      default: return FIcons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  List<Widget> _buildSourceButtons(Behavior behavior, FThemeData theme) {
    final sources = behavior.source?.split(',') ?? [];
    final sourceUrls = behavior.sourceUrl?.split(',') ?? [];

    if (sources.isEmpty || sourceUrls.isEmpty) return [];

    final buttons = <Widget>[];
    final minLength = sources.length < sourceUrls.length ? sources.length : sourceUrls.length;

    for (int i = 0; i < minLength; i++) {
      final url = sourceUrls[i].trim();
      if (url.isNotEmpty) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: FButton(
              onPress: () => _launchUrl(url),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FIcons.externalLink, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text('View Source ${i + 1}'),
                ],
              ),
            ),
          ),
        );
      }
    }
    return buttons;
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const _StatusBadge({
    required this.label,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.sm),
          ] else ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: theme.typography.sm.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final FThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? theme.colors.mutedForeground),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

/// Button to ask AI about this behavior
class _AskAiButton extends StatelessWidget {
  final Behavior behavior;

  const _AskAiButton({required this.behavior});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: () => _askAiAboutBehavior(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colors.primary,
              theme.colors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pawsightLogo.png',
              width: 20,
              height: 20,
              color: theme.colors.primaryForeground,
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                'Ask AI about "${behavior.name}"',
                style: theme.typography.base.copyWith(
                  color: theme.colors.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              FIcons.arrowRight,
              size: 16,
              color: theme.colors.primaryForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _askAiAboutBehavior(BuildContext context) {
    final question = 'Tell me more about "${behavior.name}" behavior in cats. '
        'What does it mean when a cat shows this behavior and how should I respond?';

    final chatProvider = context.read<ChatProvider>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      chatProvider.sendMessage(question);
    });
  }
}
