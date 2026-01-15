import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../services/database_helper.dart';
import '../screens/behavior_detail_screen.dart';

/// Banner showing offline status
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colors.destructive,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FIcons.wifiOff,
            size: 16,
            color: theme.colors.destructiveForeground,
          ),
          const SizedBox(width: 8),
          Text(
            'You are offline',
            style: theme.typography.sm.copyWith(
              color: theme.colors.destructiveForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Typing indicator showing AI is generating a response
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(left: 16, right: 64, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final progress = (_controller.value + delay) % 1.0;
              final offset = (progress < 0.5 ? progress : 1.0 - progress) * 6;

              return Container(
                margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                child: Transform.translate(
                  offset: Offset(0, -offset),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colors.mutedForeground,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Message bubble widget for chat messages
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    final theme = context.theme;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: theme.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colors.border),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FIcons.copy, size: 18, color: theme.colors.foreground),
              const SizedBox(width: 12),
              Text(
                'Copy',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FIcons.share, size: 18, color: theme.colors.foreground),
              const SizedBox(width: 12),
              Text(
                'Share',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'copy') {
        _copyMessage(scaffoldMessenger);
      } else if (value == 'share') {
        _shareMessage();
      }
    });
  }

  void _copyMessage(ScaffoldMessengerState scaffoldMessenger) {
    Clipboard.setData(ClipboardData(text: message.content));
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareMessage() {
    final prefix = message.isUser ? 'My question' : 'PawSight AI';
    Share.share(
      '$prefix:\n${message.content}',
      subject: 'PawSight Chat',
    );
  }

  Future<void> _handleLinkTap(
      BuildContext context, String text, String? href) async {
    // If it's a behavior:// link, navigate to behavior detail
    if (href != null && href.startsWith('behavior://')) {
      final behaviorName = Uri.decodeComponent(href.substring(11));
      await _navigateToBehavior(context, behaviorName);
      return;
    }

    // Otherwise, try to open as external URL
    if (href != null) {
      final uri = Uri.tryParse(href);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _navigateToBehavior(
      BuildContext context, String behaviorName) async {
    final db = DatabaseHelper.instance;
    final behavior = await db.getBehaviorByName(behaviorName);

    if (behavior != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BehaviorDetailScreen(behavior: behavior),
        ),
      );
    } else if (context.mounted) {
      // Show snackbar if behavior not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Behavior "$behaviorName" not found in library'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isUser = message.isUser;
    final isError = message.isError;

    return GestureDetector(
      onSecondaryTapDown: (details) => _showContextMenu(context, details),
      onLongPressStart: (details) => _showContextMenu(
        context,
        TapDownDetails(globalPosition: details.globalPosition),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/pawsightLogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isError
                      ? theme.colors.destructive.withValues(alpha: 0.1)
                      : isUser
                          ? theme.colors.primary
                          : theme.colors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: isError
                      ? Border.all(color: theme.colors.destructive)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              if (isUser)
                Text(
                  message.content,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.primaryForeground,
                  ),
                )
              else if (isError)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FIcons.triangleAlert,
                          size: 16,
                          color: theme.colors.destructive,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            message.content,
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.destructive,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onRetry,
                        child: Text(
                          'Tap to retry',
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              else
                MarkdownBody(
                  data: message.content,
                  selectable: true,
                  onTapLink: (text, href, title) =>
                      _handleLinkTap(context, text, href),
                  styleSheet: MarkdownStyleSheet(
                    p: theme.typography.sm.copyWith(
                      color: theme.colors.foreground,
                    ),
                    strong: theme.typography.sm.copyWith(
                      color: theme.colors.foreground,
                      fontWeight: FontWeight.bold,
                    ),
                    em: theme.typography.sm.copyWith(
                      color: theme.colors.foreground,
                      fontStyle: FontStyle.italic,
                    ),
                    listBullet: theme.typography.sm.copyWith(
                      color: theme.colors.foreground,
                    ),
                    code: theme.typography.xs.copyWith(
                      color: theme.colors.foreground,
                      backgroundColor: theme.colors.muted,
                    ),
                    a: theme.typography.sm.copyWith(
                      color: theme.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              // Timestamp
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: theme.typography.xs.copyWith(
                  color: isUser
                      ? theme.colors.primaryForeground.withValues(alpha: 0.7)
                      : theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Chat input bar with text field and send button
class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final bool isLoading;
  final int remainingRequests;
  final void Function(String message) onSend;

  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.remainingRequests,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _canSend =>
      widget.enabled && !widget.isLoading && _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled || widget.isLoading) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(
          top: BorderSide(color: theme.colors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rate limit indicator
            if (widget.remainingRequests < 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${widget.remainingRequests} messages remaining',
                  style: theme.typography.xs.copyWith(
                    color: widget.remainingRequests <= 1
                        ? theme.colors.destructive
                        : theme.colors.mutedForeground,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled && !widget.isLoading,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: widget.isLoading
                          ? 'Waiting for response...'
                          : widget.enabled
                              ? 'Ask about your cat...'
                              : 'Cannot send messages',
                      hintStyle: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      filled: true,
                      fillColor: theme.colors.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.foreground,
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: _canSend ? _handleSend : null,
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colors.primary,
                            ),
                          )
                        : Icon(
                            FIcons.send,
                            color: _canSend
                                ? theme.colors.primary
                                : theme.colors.mutedForeground,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget for when there are no messages
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

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
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask questions about your cat\'s behavior, body language, or get advice on cat care.',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            // Suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                _SuggestionChip(text: 'Why does my cat meow at night?'),
                _SuggestionChip(text: 'What does tail wagging mean?'),
                _SuggestionChip(text: 'Is kneading normal behavior?'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;

  const _SuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final chatProvider = context.read<ChatProvider>();

    return GestureDetector(
      onTap: () => chatProvider.sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: theme.typography.xs.copyWith(
            color: theme.colors.primary,
          ),
        ),
      ),
    );
  }
}
