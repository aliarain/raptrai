import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A message display widget for AI conversations.
///
/// Supports user and assistant message styles with actions.
class RaptrAIPromptMessage extends StatelessWidget {
  /// The message content to display.
  final String content;

  /// The role of the message sender.
  final MessageRole role;

  /// Optional avatar widget.
  final Widget? avatar;

  /// Optional sender name.
  final String? senderName;

  /// Optional timestamp.
  final DateTime? timestamp;

  /// Whether the message is currently streaming.
  final bool isStreaming;

  /// Actions to display below the message.
  final List<Widget>? actions;

  /// Custom content widget (overrides [content] string).
  final Widget? customContent;

  /// Maximum width as a fraction of screen width (0.0 - 1.0).
  final double maxWidthFactor;

  /// Border radius for the message bubble.
  final double borderRadius;

  const RaptrAIPromptMessage({
    super.key,
    required this.content,
    required this.role,
    this.avatar,
    this.senderName,
    this.timestamp,
    this.isStreaming = false,
    this.actions,
    this.customContent,
    this.maxWidthFactor = 0.8,
    this.borderRadius = 16,
  });

  /// Creates a user message.
  factory RaptrAIPromptMessage.user({
    Key? key,
    required String content,
    Widget? avatar,
    String? senderName,
    DateTime? timestamp,
    List<Widget>? actions,
    Widget? customContent,
    double maxWidthFactor = 0.8,
    double borderRadius = 16,
  }) {
    return RaptrAIPromptMessage(
      key: key,
      content: content,
      role: MessageRole.user,
      avatar: avatar,
      senderName: senderName,
      timestamp: timestamp,
      actions: actions,
      customContent: customContent,
      maxWidthFactor: maxWidthFactor,
      borderRadius: borderRadius,
    );
  }

  /// Creates an assistant message.
  factory RaptrAIPromptMessage.assistant({
    Key? key,
    required String content,
    Widget? avatar,
    String? senderName,
    DateTime? timestamp,
    bool isStreaming = false,
    List<Widget>? actions,
    Widget? customContent,
    double maxWidthFactor = 0.8,
    double borderRadius = 16,
  }) {
    return RaptrAIPromptMessage(
      key: key,
      content: content,
      role: MessageRole.assistant,
      avatar: avatar,
      senderName: senderName,
      timestamp: timestamp,
      isStreaming: isStreaming,
      actions: actions,
      customContent: customContent,
      maxWidthFactor: maxWidthFactor,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = role == MessageRole.user;
    final screenWidth = MediaQuery.of(context).size.width;

    final bubbleColor = isUser
        ? RaptrAIColors.accent
        : (isDark
            ? RaptrAIColors.darkAssistantBubble
            : RaptrAIColors.lightAssistantBubble);

    final textColor = isUser
        ? Colors.white
        : (isDark
            ? RaptrAIColors.darkAssistantBubbleText
            : RaptrAIColors.lightAssistantBubbleText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && avatar != null) ...[
            avatar!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      senderName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? RaptrAIColors.darkTextSecondary
                            : RaptrAIColors.lightTextSecondary,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * maxWidthFactor,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(isUser ? borderRadius : 4),
                      bottomRight: Radius.circular(isUser ? 4 : borderRadius),
                    ),
                  ),
                  child: customContent ??
                      Text(
                        content.isEmpty && isStreaming ? '...' : content,
                        style: TextStyle(color: textColor, height: 1.4),
                      ),
                ),
                if (timestamp != null || actions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (timestamp != null)
                          Text(
                            _formatTime(timestamp!),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? RaptrAIColors.darkTextMuted
                                  : RaptrAIColors.lightTextMuted,
                            ),
                          ),
                        if (actions != null) ...[
                          if (timestamp != null) const SizedBox(width: 8),
                          ...actions!,
                        ],
                      ],
                    ),
                  ),
              ],
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

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// The role of a message sender.
enum MessageRole {
  /// Message from the user.
  user,

  /// Message from the AI assistant.
  assistant,

  /// System message.
  system,
}
