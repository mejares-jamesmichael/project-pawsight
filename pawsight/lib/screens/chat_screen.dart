import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

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
  final _messageController = TextEditingController();
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
    _messageController.dispose();
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.shade800,
              child: Row(
                children: [
                  const Icon(FIcons.wifiOff, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
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
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colors.background,
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            child: Row(
              children: [
                // Camera/Image Button (Placeholder for now)
                FButton.icon(
                  onPress: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Image analysis coming soon!')),
                     );
                  },
                  child: const Icon(FIcons.camera),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FTextField(
                    controller: _messageController,
                    hint: 'Ask about your cat...',
                    minLines: 1,
                    maxLines: 4,
                    enabled: !provider.isLoading && !provider.isOffline,
                    // No onSubmitted param in basic FTextField
                  ),
                ),
                const SizedBox(width: 8),
                FButton.icon(
                  onPress: (provider.isLoading || provider.isOffline) ? null : _sendMessage,
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(FIcons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    context.read<ChatProvider>().sendMessage(text);
    
    // Scroll to bottom after a slight delay to allow the new message to render
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
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

  Widget _buildEmptyState(FThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FIcons.messageCircle,
              size: 48,
              color: theme.colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ask PawSight AI',
            style: theme.typography.xl.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'I can help you understand your cat\'s\nbehavior, mood, and needs.',
            textAlign: TextAlign.center,
            style: theme.typography.base.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),
          _buildSuggestionChip('Why is my cat tail wagging?'),
          _buildSuggestionChip('What does a slow blink mean?'),
          _buildSuggestionChip('Why does my cat knead me?'),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          _messageController.text = text;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: context.theme.colors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(text, style: context.theme.typography.sm),
        ),
      ),
    );
  }
}