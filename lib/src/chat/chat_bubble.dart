import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A chat bubble widget for displaying messages.
///
/// Supports user and assistant styles with customizable appearance.
class RaptrAIChatBubble extends StatelessWidget {
  /// The message content.
  final String content;

  /// Whether this is a user message.
  final bool isUser;

  /// Optional avatar widget.
  final Widget? avatar;

  /// Whether the message is currently being streamed.
  final bool isStreaming;

  /// Custom content widget (overrides [content] string).
  final Widget? child;

  /// Background color override.
  final Color? backgroundColor;

  /// Text color override.
  final Color? textColor;

  /// Border radius for the bubble.
  final double borderRadius;

  /// Maximum width factor (0.0 - 1.0).
  final double maxWidthFactor;

  /// Padding inside the bubble.
  final EdgeInsets padding;

  /// Whether to show the tail on the bubble.
  final bool showTail;

  const RaptrAIChatBubble({
    super.key,
    required this.content,
    this.isUser = false,
    this.avatar,
    this.isStreaming = false,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 18,
    this.maxWidthFactor = 0.75,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.showTail = true,
  });

  /// Creates a user chat bubble.
  factory RaptrAIChatBubble.user({
    Key? key,
    required String content,
    Widget? avatar,
    Widget? child,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 18,
    double maxWidthFactor = 0.75,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    bool showTail = true,
  }) {
    return RaptrAIChatBubble(
      key: key,
      content: content,
      isUser: true,
      avatar: avatar,
      child: child,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderRadius: borderRadius,
      maxWidthFactor: maxWidthFactor,
      padding: padding,
      showTail: showTail,
    );
  }

  /// Creates an assistant chat bubble.
  factory RaptrAIChatBubble.assistant({
    Key? key,
    required String content,
    Widget? avatar,
    bool isStreaming = false,
    Widget? child,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 18,
    double maxWidthFactor = 0.75,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    bool showTail = true,
  }) {
    return RaptrAIChatBubble(
      key: key,
      content: content,
      isUser: false,
      avatar: avatar,
      isStreaming: isStreaming,
      child: child,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderRadius: borderRadius,
      maxWidthFactor: maxWidthFactor,
      padding: padding,
      showTail: showTail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final bgColor = backgroundColor ??
        (isUser
            ? RaptrAIColors.accent
            : (isDark
                ? RaptrAIColors.darkAssistantBubble
                : RaptrAIColors.lightAssistantBubble));

    final fgColor = textColor ??
        (isUser
            ? Colors.white
            : (isDark
                ? RaptrAIColors.darkAssistantBubbleText
                : RaptrAIColors.lightAssistantBubbleText));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && avatar != null) ...[
            avatar!,
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * maxWidthFactor,
            ),
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: _buildBorderRadius(),
            ),
            child: child ??
                Text(
                  content.isEmpty && isStreaming ? '...' : content,
                  style: TextStyle(
                    color: fgColor,
                    height: 1.4,
                  ),
                ),
          ),
          if (isUser && avatar != null) ...[
            const SizedBox(width: 8),
            avatar!,
          ],
        ],
      ),
    );
  }

  BorderRadius _buildBorderRadius() {
    if (!showTail) {
      return BorderRadius.circular(borderRadius);
    }

    return BorderRadius.only(
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(isUser ? borderRadius : 4),
      bottomRight: Radius.circular(isUser ? 4 : borderRadius),
    );
  }
}

/// A group of chat bubbles with optional date separator.
class RaptrAIChatBubbleGroup extends StatelessWidget {
  /// The list of chat bubbles.
  final List<Widget> children;

  /// Optional date label.
  final String? dateLabel;

  /// Spacing between bubbles.
  final double spacing;

  const RaptrAIChatBubbleGroup({
    super.key,
    required this.children,
    this.dateLabel,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (dateLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              dateLabel!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? RaptrAIColors.darkTextMuted
                    : RaptrAIColors.lightTextMuted,
              ),
            ),
          ),
        ...children.map((child) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            )),
      ],
    );
  }
}
