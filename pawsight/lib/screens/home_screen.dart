import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'library_screen.dart';
import 'hotline_screen.dart';

/// Main app shell with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: _buildHeader(),
      footer: FBottomNavigationBar(
        index: _currentIndex,
        onChange: (index) => setState(() => _currentIndex = index),
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FIcons.house),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.libraryBig),
            label: Text('Library'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.phone),
            label: Text('Hotline'),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildHeader() {
    final titles = ['PawSight', 'Library', 'Vet Hotline'];
    return FHeader(
      title: Text(titles[_currentIndex]),
      suffixes: [
        if (_currentIndex == 0)
          FHeaderAction(
            icon: Icon(FIcons.info),
            onPress: () => _showAboutDialog(context),
          ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _HomeContent(
          onNavigateToLibrary: () => setState(() => _currentIndex = 1),
          onNavigateToChat: () => _openAIChat(context),
          onNavigateToHotline: () => setState(() => _currentIndex = 2),
        );
      case 1:
        return const LibraryScreen();
      case 2:
        return const HotlineScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAboutDialog(BuildContext context) {
    showFDialog(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          direction: Axis.vertical,
          title: const Text('About PawSight'),
          body: const Text(
            'PawSight helps you understand your cat\'s body language.\n\n'
            'Version 0.1.0-alpha\n\n'
            '🐱 Built with Flutter & Forui',
          ),
          actions: [
            FButton(
              child: const Text('OK'),
              onPress: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _openAIChat(BuildContext context) {
    // TODO: Navigate to AI Chat screen
    showFDialog(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          direction: Axis.vertical,
          title: const Text('AI Chat'),
          body: const Text(
            'AI Chat feature coming soon!\n\n'
            'You\'ll be able to:\n'
            '• Ask questions about your cat\n'
            '• Upload photos for analysis\n'
            '• Get personalized advice',
          ),
          actions: [
            FButton(
              child: const Text('Got it'),
              onPress: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}

/// Home tab content with daily tip and navigation cards
class _HomeContent extends StatelessWidget {
  final VoidCallback onNavigateToLibrary;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToHotline;

  const _HomeContent({
    required this.onNavigateToLibrary,
    required this.onNavigateToChat,
    required this.onNavigateToHotline,
  });

  // Daily tips about cat behavior
  static const _dailyTips = [
    'A slow blink from your cat is a sign of trust and affection - try slow blinking back!',
    'Cats knead when they feel content and safe, a behavior from kittenhood.',
    'A cat\'s tail held high usually means they\'re feeling confident and happy.',
    'When your cat shows their belly, it\'s a sign of trust, not always an invitation to pet.',
    'Purring doesn\'t always mean happiness - cats also purr when stressed or unwell.',
    'Ears pointed forward indicate curiosity, while flattened ears signal fear or aggression.',
    'A twitching tail tip often means your cat is focused or mildly irritated.',
  ];

  String get _todaysTip {
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return _dailyTips[dayOfYear % _dailyTips.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Tip Card
          FCard(
            title: Row(
              children: [
                Icon(FIcons.lightbulb, size: 18, color: theme.colors.primary),
                const SizedBox(width: 8),
                const Text('Daily Tip'),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _todaysTip,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section title
          Text(
            'Explore',
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Navigation Cards - Library & AI Chat row
          Row(
            children: [
              Expanded(
                child: _NavigationCard(
                  icon: FIcons.libraryBig,
                  title: 'Library',
                  description: 'Browse cat body language guide',
                  onTap: onNavigateToLibrary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavigationCard(
                  icon: FIcons.messageCircle,
                  title: 'AI Chat',
                  description: 'Ask questions about your cat',
                  onTap: onNavigateToChat,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Vet Hotline Card - full width
          _NavigationCard(
            icon: FIcons.phone,
            title: 'Vet Hotline',
            description: 'Emergency contacts & clinics',
            onTap: onNavigateToHotline,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// Reusable navigation card widget
class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool fullWidth;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: FCard.raw(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: fullWidth
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: theme.colors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.typography.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: fullWidth ? TextAlign.center : TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
