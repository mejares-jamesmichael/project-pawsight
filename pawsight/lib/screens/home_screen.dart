import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import '../models/behavior.dart';
import '../providers/library_provider.dart';
import '../providers/cat_api_provider.dart';
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

          // Daily Purr-spective (Hero Card) - Cat Facts from API
          _DailyPurrspectiveCard(
            onNavigateToDiscover: onNavigateToDiscover,
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

/// Daily Purr-spective card that displays cat facts from API
class _DailyPurrspectiveCard extends StatefulWidget {
  final VoidCallback onNavigateToDiscover;

  const _DailyPurrspectiveCard({
    required this.onNavigateToDiscover,
  });

  @override
  State<_DailyPurrspectiveCard> createState() => _DailyPurrspectiveCardState();
}

class _DailyPurrspectiveCardState extends State<_DailyPurrspectiveCard> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Load a cat fact when the widget is first shown
      final provider = context.read<CatApiProvider>();
      if (provider.currentFact == null && !provider.isLoadingFacts) {
        provider.refreshFact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Consumer<CatApiProvider>(
      builder: (context, catApiProvider, child) {
        final fact = catApiProvider.currentFact;
        final isLoading = catApiProvider.isLoadingFacts;

        return Padding(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily Purr-spective'),
                      Text(
                        'Cat Fact',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh button
                GestureDetector(
                  onTap: isLoading ? null : () => catApiProvider.refreshFact(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colors.primary,
                            ),
                          )
                        : Icon(
                            FIcons.refreshCw,
                            size: 16,
                            color: theme.colors.primary,
                          ),
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading && fact == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: theme.colors.primary,
                        ),
                      ),
                    )
                  else if (fact != null)
                    Text(
                      fact.text,
                      style: theme.typography.base.copyWith(
                        height: 1.5,
                      ),
                    )
                  else
                    Text(
                      'Tap refresh to load a cat fact!',
                      style: theme.typography.base.copyWith(
                        height: 1.5,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Link to Discover for more facts
                  GestureDetector(
                    onTap: widget.onNavigateToDiscover,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'More cat facts',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          FIcons.arrowRight,
                          size: 14,
                          color: theme.colors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        // Get the first image path (behaviors can have multiple comma-separated images)
        final imagePath = behavior.imagePath.split(',').first.trim();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => onNavigateToBehavior(behavior),
            child: FCard(
              image: Container(
                height: 180,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Actual behavior image
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return Center(
                          child: Icon(
                            categoryIcon,
                            size: 64,
                            color: moodColor.withValues(alpha: 0.4),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay for better text readability on badges
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
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
