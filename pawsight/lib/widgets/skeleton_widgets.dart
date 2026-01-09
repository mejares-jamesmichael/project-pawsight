import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Shimmer effect animation for skeleton loading
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colors.muted,
                theme.colors.muted.withValues(alpha: 0.3),
                theme.colors.muted,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Basic skeleton box with rounded corners
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for behavior card in library screen
class BehaviorCardSkeleton extends StatelessWidget {
  const BehaviorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and emoji row
            Row(
              children: [
                const SkeletonBox(width: 32, height: 32, borderRadius: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 18,
                      ),
                      const SizedBox(height: 6),
                      SkeletonBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: 12,
                      ),
                    ],
                  ),
                ),
                const SkeletonBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 12),
            // Description lines
            const SkeletonBox(width: double.infinity, height: 14),
            const SizedBox(height: 6),
            const SkeletonBox(width: double.infinity, height: 14),
            const SizedBox(height: 6),
            SkeletonBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 14,
            ),
            const SizedBox(height: 12),
            // Tags row
            Row(
              children: [
                SkeletonBox(width: 60, height: 24, borderRadius: 12),
                const SizedBox(width: 8),
                SkeletonBox(width: 80, height: 24, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading for library screen
class LibrarySkeletonLoader extends StatelessWidget {
  final int itemCount;

  const LibrarySkeletonLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const BehaviorCardSkeleton(),
      ),
    );
  }
}

/// Skeleton for chat message bubble
class MessageBubbleSkeleton extends StatelessWidget {
  final bool isUser;

  const MessageBubbleSkeleton({super.key, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ShimmerEffect(
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          margin: EdgeInsets.only(
            left: isUser ? 64 : 16,
            right: isUser ? 16 : 64,
            top: 4,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? theme.colors.primary : theme.colors.secondary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: isUser
                    ? MediaQuery.of(context).size.width * 0.4
                    : MediaQuery.of(context).size.width * 0.6,
                height: 16,
              ),
              if (!isUser) ...[
                const SizedBox(height: 8),
                SkeletonBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 16,
                ),
                const SizedBox(height: 8),
                SkeletonBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 16,
                ),
              ],
              const SizedBox(height: 8),
              const SkeletonBox(width: 40, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading for chat history
class ChatHistorySkeleton extends StatelessWidget {
  const ChatHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: const [
        MessageBubbleSkeleton(isUser: true),
        MessageBubbleSkeleton(isUser: false),
        MessageBubbleSkeleton(isUser: true),
        MessageBubbleSkeleton(isUser: false),
        MessageBubbleSkeleton(isUser: true),
      ],
    );
  }
}

/// Skeleton for filter chips
class FilterChipSkeleton extends StatelessWidget {
  const FilterChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SkeletonBox(
              width: 70 + (index * 10).toDouble(),
              height: 32,
              borderRadius: 16,
            ),
          ),
        ),
      ),
    );
  }
}
