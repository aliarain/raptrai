import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// An animated typing indicator for AI responses.
///
/// Shows bouncing dots to indicate the AI is "thinking".
class RaptrAITypingIndicator extends StatefulWidget {
  /// The color of the dots.
  final Color? dotColor;

  /// Size of each dot.
  final double dotSize;

  /// Spacing between dots.
  final double spacing;

  /// Number of dots to show.
  final int dotCount;

  /// Whether to show in a bubble container.
  final bool showBubble;

  /// Background color when showing bubble.
  final Color? bubbleColor;

  const RaptrAITypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 8,
    this.spacing = 4,
    this.dotCount = 3,
    this.showBubble = true,
    this.bubbleColor,
  });

  @override
  State<RaptrAITypingIndicator> createState() => _RaptrAITypingIndicatorState();
}

class _RaptrAITypingIndicatorState extends State<RaptrAITypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.dotColor ?? RaptrAIColors.accent;
    final bgColor = widget.bubbleColor ??
        (isDark
            ? RaptrAIColors.darkAssistantBubble
            : RaptrAIColors.lightAssistantBubble);

    final dots = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.dotCount, (index) {
            final delay = index * (1.0 / widget.dotCount);
            final value = (_controller.value + delay) % 1.0;

            // Bounce animation
            double offset = 0;
            if (value < 0.5) {
              offset = -4 * value;
            } else {
              offset = -4 * (1 - value);
            }

            // Opacity animation
            final opacity = value < 0.5
                ? 0.4 + (value * 1.2)
                : 0.4 + ((1 - value) * 1.2);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: opacity.clamp(0.4, 1.0)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );

    if (!widget.showBubble) {
      return dots;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: dots,
    );
  }
}

/// A pulsing dot indicator (alternative style).
class RaptrAIPulsingIndicator extends StatefulWidget {
  /// The color of the indicator.
  final Color? color;

  /// Size of the indicator.
  final double size;

  /// Label text to show next to indicator.
  final String? label;

  const RaptrAIPulsingIndicator({
    super.key,
    this.color,
    this.size = 10,
    this.label,
  });

  @override
  State<RaptrAIPulsingIndicator> createState() => _RaptrAIPulsingIndicatorState();
}

class _RaptrAIPulsingIndicatorState extends State<RaptrAIPulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color ?? RaptrAIColors.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size * 2,
          height: widget.size * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: _opacityAnimation.value),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Center dot
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? RaptrAIColors.darkTextSecondary
                  : RaptrAIColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
