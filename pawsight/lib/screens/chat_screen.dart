import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

import '../core/app_constants.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_widgets.dart';

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

  void _handleSendMessage(String text) {
    context.read<ChatProvider>().sendMessage(text);
    // Scroll to bottom after a slight delay to allow the new message to render
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ChatProvider>();

    // Listen for errors and show toast
    if (provider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Safe toast/snackbar fallback
        try {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(provider.error!),
               backgroundColor: Colors.red,
               behavior: SnackBarBehavior.floating,
             ),
           );
        } catch (_) {
          // ignore
        }
        provider.clearError(); // Clear error after showing toast
      });
    }

    return FScaffold(
      header: FHeader(
        title: const Text('AI Assistant'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.trash2),
            onPress: () => _showClearHistoryDialog(context, provider),
          ),
        ],
      ),
      child: Column(
        children: [
          // Offline Banner
          if (provider.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm, 
                horizontal: AppSpacing.lg,
              ),
              color: Colors.orange.shade800,
              child: Row(
                children: [
                  const Icon(FIcons.wifiOff, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'You are offline. AI features are unavailable.',
                    style: theme.typography.sm.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Chat Messages
          Expanded(
            child: provider.isInitializing
                ? const Center(child: CircularProgressIndicator())
                : provider.messages.isEmpty
                    ? const ChatEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length) {
                            return const TypingIndicator();
                          }
                          return MessageBubble(
                            message: provider.messages[index],
                            onRetry: provider.retryLastMessage,
                          );
                        },
                      ),
          ),

          // Input Area
          ChatInputBar(
            enabled: !provider.isOffline,
            isLoading: provider.isLoading,
            remainingRequests: provider.remainingRequests,
            onSend: _handleSendMessage,
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
