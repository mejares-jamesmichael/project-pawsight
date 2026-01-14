import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'library_screen.dart';
import 'hotline_screen.dart';
import 'chat_screen.dart';

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
      suffixes: [
        if (_currentIndex == 1) // Library
           FHeaderAction(
             icon: const Icon(FIcons.search),
             onPress: () {}, // TODO: Implement global search
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

  void _openAIChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
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
                    fontSize: 32, // Manual 4xl equivalent
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Cat Enthusiast',
                  style: theme.typography.xl.copyWith(
                    fontSize: 32,
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
            ],
          ),

          const SizedBox(height: 12),
          
          // Vet Hotline Full Width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ActionCard(
              icon: FIcons.phone,
              title: 'Vet Hotline',
              subtitle: 'Emergency contacts & clinics',
              color: Colors.red,
              onTap: onNavigateToHotline,
              isHorizontal: true,
            ),
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

          // Static Spotlight Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: onNavigateToLibrary,
              child: FCard(
                image: Container(
                  height: 150,
                  width: double.infinity,
                  color: theme.colors.secondary,
                  child: const Center(
                    child: Icon(FIcons.eye, size: 48, color: Colors.white54),
                  ),
                ),
                title: const Text('Slow Blink'),
                subtitle: const Text('Affection • Relaxed'),
                child: const Text(
                  'A slow blink is a cat\'s way of saying "I trust you". It\'s like a kitty kiss!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
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
  final bool isHorizontal;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isHorizontal = false,
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
        child: isHorizontal
            ? Row(
                children: [
                  _buildIcon(context),
                  const SizedBox(width: 16),
                  Expanded(child: _buildText(context)),
                  Icon(FIcons.chevronRight, color: theme.colors.mutedForeground),
                ],
              )
            : Column(
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
