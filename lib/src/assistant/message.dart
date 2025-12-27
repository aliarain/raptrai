import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';
import 'package:raptrai/src/theme/raptrai_theme.dart';

/// Role of the message sender.
enum RaptrAIMessageRole {
  user,
  assistant,
  system,
}

/// User message component.
///
/// Matches assistant-ui UserMessage with right-aligned bubble.
class RaptrAIUserMessage extends StatelessWidget {
  const RaptrAIUserMessage({
    required this.content,
    super.key,
    this.timestamp,
    this.showActions = false,
    this.onEdit,
  });

  /// Message content.
  final String content;

  /// Timestamp of the message.
  final DateTime? timestamp;

  /// Whether to show action buttons.
  final bool showActions;

  /// Callback when edit is tapped.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkUserBubble : RaptrAIColors.lightUserBubble;
    final textColor =
        isDark ? RaptrAIColors.darkUserBubbleText : RaptrAIColors.lightUserBubbleText;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RaptrAIColors.spacingLg,
                vertical: RaptrAIColors.spacingMd,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
              ),
              child: Text(
                content,
                style: RaptrAITypography.body(color: textColor),
              ),
            ),
            if (showActions) ...[
              const SizedBox(height: RaptrAIColors.spacingXs),
              RaptrAIMessageActions(
                onEdit: onEdit,
                showCopy: true,
                showEdit: onEdit != null,
                showRegenerate: false,
                content: content,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Assistant message component.
///
/// Matches assistant-ui AssistantMessage with avatar and left-aligned content.
class RaptrAIAssistantMessage extends StatefulWidget {
  const RaptrAIAssistantMessage({
    required this.content,
    super.key,
    this.avatar,
    this.avatarIcon = Icons.smart_toy_outlined,
    this.timestamp,
    this.isStreaming = false,
    this.showActions = true,
    this.onRegenerate,
    this.onCopy,
  });

  /// Message content.
  final String content;

  /// Custom avatar widget.
  final Widget? avatar;

  /// Avatar icon if no custom avatar.
  final IconData avatarIcon;

  /// Timestamp of the message.
  final DateTime? timestamp;

  /// Whether the message is still streaming.
  final bool isStreaming;

  /// Whether to show action buttons.
  final bool showActions;

  /// Callback when regenerate is tapped.
  final VoidCallback? onRegenerate;

  /// Callback when copy is tapped.
  final VoidCallback? onCopy;

  @override
  State<RaptrAIAssistantMessage> createState() => _RaptrAIAssistantMessageState();
}

class _RaptrAIAssistantMessageState extends State<RaptrAIAssistantMessage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final avatarBg =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final avatarFg =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            widget.avatar ??
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: avatarBg,
                    borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
                  ),
                  child: Icon(
                    widget.avatarIcon,
                    size: 18,
                    color: avatarFg,
                  ),
                ),
            const SizedBox(width: RaptrAIColors.spacingMd),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  SelectableText(
                    widget.content,
                    style: RaptrAITypography.body(color: textColor),
                  ),
                  // Streaming cursor
                  if (widget.isStreaming)
                    _StreamingCursor(),
                  // Actions
                  if (widget.showActions && !widget.isStreaming && _isHovered) ...[
                    const SizedBox(height: RaptrAIColors.spacingSm),
                    RaptrAIMessageActions(
                      content: widget.content,
                      showCopy: true,
                      showRegenerate: widget.onRegenerate != null,
                      onRegenerate: widget.onRegenerate,
                      onCopy: widget.onCopy,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamingCursor extends StatefulWidget {
  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cursorColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 16,
            margin: const EdgeInsets.only(left: 2),
            color: cursorColor,
          ),
        );
      },
    );
  }
}

/// Action buttons for messages.
///
/// Matches assistant-ui MessageActions with copy, edit, regenerate.
class RaptrAIMessageActions extends StatelessWidget {
  const RaptrAIMessageActions({
    super.key,
    this.content,
    this.showCopy = true,
    this.showEdit = false,
    this.showRegenerate = false,
    this.onCopy,
    this.onEdit,
    this.onRegenerate,
  });

  /// Message content for copy.
  final String? content;

  /// Whether to show copy button.
  final bool showCopy;

  /// Whether to show edit button.
  final bool showEdit;

  /// Whether to show regenerate button.
  final bool showRegenerate;

  /// Custom copy callback.
  final VoidCallback? onCopy;

  /// Edit callback.
  final VoidCallback? onEdit;

  /// Regenerate callback.
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCopy)
          _ActionButton(
            icon: Icons.content_copy_outlined,
            tooltip: 'Copy',
            onTap: () {
              if (onCopy != null) {
                onCopy!();
              } else if (content != null) {
                Clipboard.setData(ClipboardData(text: content!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            iconColor: iconColor,
          ),
        if (showEdit) ...[
          const SizedBox(width: RaptrAIColors.spacingXs),
          _ActionButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            onTap: onEdit,
            iconColor: iconColor,
          ),
        ],
        if (showRegenerate) ...[
          const SizedBox(width: RaptrAIColors.spacingXs),
          _ActionButton(
            icon: Icons.refresh_outlined,
            tooltip: 'Regenerate',
            onTap: onRegenerate,
            iconColor: iconColor,
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(RaptrAIColors.spacingXs),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Generic message container that can be user or assistant.
///
/// Matches assistant-ui Message component.
class RaptrAIMessage extends StatelessWidget {
  const RaptrAIMessage({
    required this.content,
    required this.role,
    super.key,
    this.avatar,
    this.timestamp,
    this.isStreaming = false,
    this.showActions = true,
    this.onEdit,
    this.onRegenerate,
    this.onCopy,
  });

  /// Message content.
  final String content;

  /// Role of the sender.
  final RaptrAIMessageRole role;

  /// Custom avatar widget.
  final Widget? avatar;

  /// Timestamp of the message.
  final DateTime? timestamp;

  /// Whether the message is streaming (assistant only).
  final bool isStreaming;

  /// Whether to show actions.
  final bool showActions;

  /// Edit callback (user only).
  final VoidCallback? onEdit;

  /// Regenerate callback (assistant only).
  final VoidCallback? onRegenerate;

  /// Copy callback.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    if (role == RaptrAIMessageRole.user) {
      return RaptrAIUserMessage(
        content: content,
        timestamp: timestamp,
        showActions: showActions,
        onEdit: onEdit,
      );
    }

    return RaptrAIAssistantMessage(
      content: content,
      avatar: avatar,
      timestamp: timestamp,
      isStreaming: isStreaming,
      showActions: showActions,
      onRegenerate: onRegenerate,
      onCopy: onCopy,
    );
  }
}

/// Edit composer for editing messages inline.
///
/// Matches assistant-ui EditComposer.
class RaptrAIEditComposer extends StatefulWidget {
  const RaptrAIEditComposer({
    required this.initialContent,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  /// Initial content to edit.
  final String initialContent;

  /// Callback when save is tapped.
  final ValueChanged<String> onSave;

  /// Callback when cancel is tapped.
  final VoidCallback onCancel;

  @override
  State<RaptrAIEditComposer> createState() => _RaptrAIEditComposerState();
}

class _RaptrAIEditComposerState extends State<RaptrAIEditComposer> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;

    return Container(
      padding: const EdgeInsets.all(RaptrAIColors.spacingMd),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            maxLines: null,
            style: RaptrAITypography.body(color: textColor),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
          const SizedBox(height: RaptrAIColors.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: RaptrAIColors.spacingSm),
              ElevatedButton(
                onPressed: () => widget.onSave(_controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
