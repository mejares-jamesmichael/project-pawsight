import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../services/connectivity_service.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/skeleton_widgets.dart';

/// Main AI Chat screen
///
/// Displays conversation history and allows sending messages to the AI.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize chat provider and load history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final connectivity = context.watch<ConnectivityService>();
    final chatProvider = context.watch<ChatProvider>();

    // Auto-scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(FIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PawSight AI',
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (chatProvider.isLoading)
              Text(
                'Typing...',
                style: theme.typography.xs.copyWith(
                  color: theme.colors.primary,
                ),
              ),
          ],
        ),
        actions: [
          if (chatProvider.messages.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(FIcons.ellipsis, color: theme.colors.foreground),
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearHistoryDialog(context, chatProvider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(FIcons.trash2, size: 18),
                      SizedBox(width: 8),
                      Text('Clear history'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (connectivity.isOffline) const OfflineBanner(),

          // Cooldown indicator
          if (chatProvider.isOnCooldown)
            _CooldownBanner(
              remainingDuration: chatProvider.cooldownRemaining,
            ),

          // Messages list
          Expanded(
            child: chatProvider.isInitializing
                ? const ChatHistorySkeleton()
                : chatProvider.messages.isEmpty
                    ? const ChatEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: chatProvider.messages.length +
                            (chatProvider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show typing indicator at the end while loading
                          if (index == chatProvider.messages.length &&
                              chatProvider.isLoading) {
                            return const TypingIndicator();
                          }

                          final message = chatProvider.messages[index];
                          return MessageBubble(
                            message: message,
                            onRetry: message.isError
                                ? () => chatProvider.retryLastMessage()
                                : null,
                          );
                        },
                      ),
          ),

          // Input bar
          ChatInputBar(
            enabled: chatProvider.canSendMessage,
            isLoading: chatProvider.isLoading,
            remainingRequests: chatProvider.remainingRequests,
            onSend: (message) => chatProvider.sendMessage(message),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, ChatProvider provider) {
    showFDialog(
      context: context,
      builder: (context, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          direction: Axis.vertical,
          title: const Text('Clear Chat History'),
          body: const Text(
            'Are you sure you want to clear all chat messages? This cannot be undone.',
          ),
          actions: [
            FButton(
              child: const Text('Cancel'),
              onPress: () => Navigator.pop(context),
            ),
            FButton(
              child: const Text('Clear'),
              onPress: () {
                provider.clearHistory();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

/// Banner showing cooldown status
class _CooldownBanner extends StatelessWidget {
  final Duration? remainingDuration;

  const _CooldownBanner({this.remainingDuration});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final seconds = remainingDuration?.inSeconds ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FIcons.clock,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            'Rate limited. Please wait ${seconds}s',
            style: theme.typography.sm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
