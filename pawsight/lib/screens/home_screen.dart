import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import '../models/behavior.dart';
import '../providers/library_provider.dart';
import 'library_screen.dart';
import 'hotline_screen.dart';
import 'chat_screen.dart';
import 'discover_screen.dart';
import 'behavior_detail_screen.dart';

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
      // Custom header logic handled inside the body for the home tab
      header: _currentIndex == 0 ? null : _buildHeader(),
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
      suffixes: const [],
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _HomeContent(
          onNavigateToLibrary: () => setState(() => _currentIndex = 1),
          onNavigateToChat: () => _openAIChat(context),
          onNavigateToHotline: () => setState(() => _currentIndex = 2),
          onNavigateToDiscover: () => _openDiscover(context),
          onNavigateToBehavior: (behavior) => _openBehaviorDetail(context, behavior),
        );
      case 1:
        return const LibraryScreen();
      case 2:
        return const HotlineScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  void _openAIChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  void _openDiscover(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiscoverScreen()),
    );
  }

  void _openBehaviorDetail(BuildContext context, Behavior behavior) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BehaviorDetailScreen(behavior: behavior)),
    );
  }
}

/// Home tab content with daily tip and navigation cards
class _HomeContent extends StatelessWidget {
  final VoidCallback onNavigateToLibrary;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToHotline;
  final VoidCallback onNavigateToDiscover;
  final void Function(Behavior behavior) onNavigateToBehavior;

  const _HomeContent({
    required this.onNavigateToLibrary,
    required this.onNavigateToChat,
    required this.onNavigateToHotline,
    required this.onNavigateToDiscover,
    required this.onNavigateToBehavior,
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Home Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: theme.typography.xl.copyWith(
                    fontSize: 28, // Reduced from 32 for better fit
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Cat Enthusiast',
                  style: theme.typography.xl.copyWith(
                    fontSize: 28, // Reduced from 32
                    fontWeight: FontWeight.w300,
                    color: theme.colors.mutedForeground,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // Daily Purr-spective (Hero Card)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FCard(
              title: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: Colors.amber.withValues(alpha: 0.2),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: const Icon(FIcons.lightbulb, size: 20, color: Colors.amber),
                   ),
                  const SizedBox(width: 12),
                  const Text('Daily Purr-spective'),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _todaysTip,
                  style: theme.typography.base.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Tools Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tools',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _ActionCard(
                icon: FIcons.libraryBig,
                title: 'Library',
                subtitle: 'Browse Guide',
                color: Colors.teal,
                onTap: onNavigateToLibrary,
              ),
              _ActionCard(
                icon: FIcons.messageCircle,
                title: 'AI Chat',
                subtitle: 'Ask Assistant',
                color: Colors.purple,
                onTap: onNavigateToChat,
              ),
              _ActionCard(
                icon: FIcons.compass,
                title: 'Discover',
                subtitle: 'Facts & Breeds',
                color: Colors.orange,
                onTap: onNavigateToDiscover,
              ),
              _ActionCard(
                icon: FIcons.phone,
                title: 'Vet Hotline',
                subtitle: 'Emergency',
                color: Colors.red,
                onTap: onNavigateToHotline,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Spotlight Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spotlight',
                  style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
                ),
                // Using TextButton as a ghost button alternative
                GestureDetector(
                    onTap: onNavigateToLibrary,
                    child: Text(
                        'View All',
                        style: theme.typography.sm.copyWith(color: theme.colors.primary),
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Dynamic Spotlight Card from Library
          _SpotlightCard(
            onNavigateToBehavior: onNavigateToBehavior,
            onNavigateToLibrary: onNavigateToLibrary,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// A styled action card for the home screen grid
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // Use secondary or similar since 'card' might not exist
          color: theme.colors.secondary.withValues(alpha: 0.1),
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIcon(context),
            _buildText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildText(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Spotlight card that displays a behavior from the library
class _SpotlightCard extends StatelessWidget {
  final void Function(Behavior behavior) onNavigateToBehavior;
  final VoidCallback onNavigateToLibrary;

  const _SpotlightCard({
    required this.onNavigateToBehavior,
    required this.onNavigateToLibrary,
  });

  /// Get icon for behavior category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tail':
        return FIcons.arrowRight;
      case 'ears':
        return FIcons.headphones;
      case 'eyes':
        return FIcons.eye;
      case 'posture':
        return FIcons.user;
      case 'vocal':
        return FIcons.volume2;
      default:
        return FIcons.cat;
    }
  }

  /// Get color for mood
  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'relaxed':
        return Colors.blue;
      case 'fearful':
        return Colors.orange;
      case 'aggressive':
        return Colors.red;
      case 'mixed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        // Show loading state
        if (libraryProvider.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FCard(
              child: SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colors.primary,
                  ),
                ),
              ),
            ),
          );
        }

        // Get the spotlight behavior
        final behavior = libraryProvider.spotlightBehavior;

        // Fallback if no behaviors available
        if (behavior == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: onNavigateToLibrary,
              child: FCard(
                title: const Text('Explore the Library'),
                subtitle: const Text('Discover cat behaviors'),
                child: const Text(
                  'Tap to browse our collection of cat body language guides.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }

        // Display the spotlight behavior
        final moodColor = _getMoodColor(behavior.mood);
        final categoryIcon = _getCategoryIcon(behavior.category);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => onNavigateToBehavior(behavior),
            child: FCard(
              image: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Stack(
                  children: [
                    // Category icon in center
                    Center(
                      child: Icon(
                        categoryIcon,
                        size: 64,
                        color: moodColor.withValues(alpha: 0.4),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.background.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 14, color: moodColor),
                            const SizedBox(width: 4),
                            Text(
                              behavior.category,
                              style: theme.typography.xs.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Mood badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: moodColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: moodColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          behavior.mood,
                          style: theme.typography.xs.copyWith(
                            color: moodColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(behavior.name),
              subtitle: Text('${behavior.category} • ${behavior.mood}'),
              child: Text(
                behavior.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}
