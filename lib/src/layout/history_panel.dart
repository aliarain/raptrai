import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A panel for displaying conversation history.
class RaptrAIHistoryPanel extends StatelessWidget {
  /// List of conversations to display.
  final List<RaptrAIHistoryItem> conversations;

  /// Currently selected conversation ID.
  final String? selectedId;

  /// Callback when a conversation is selected.
  final ValueChanged<String>? onConversationSelected;

  /// Callback when a conversation is deleted.
  final ValueChanged<String>? onConversationDeleted;

  /// Callback when "New Chat" is pressed.
  final VoidCallback? onNewChat;

  /// Optional header widget.
  final Widget? header;

  /// Whether to show the new chat button.
  final bool showNewChatButton;

  /// Empty state widget.
  final Widget? emptyState;

  const RaptrAIHistoryPanel({
    super.key,
    required this.conversations,
    this.selectedId,
    this.onConversationSelected,
    this.onConversationDeleted,
    this.onNewChat,
    this.header,
    this.showNewChatButton = true,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: header!,
          )
        else if (showNewChatButton)
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: onNewChat,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Chat'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: isDark
                      ? RaptrAIColors.darkBorder
                      : RaptrAIColors.lightBorder,
                ),
              ),
            ),
          ),
        Expanded(
          child: conversations.isEmpty
              ? emptyState ?? _buildDefaultEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final item = conversations[index];
                    final isSelected = selectedId == item.id;

                    return _HistoryItemWidget(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onConversationSelected?.call(item.id),
                      onDelete: onConversationDeleted != null
                          ? () => onConversationDeleted!(item.id)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDefaultEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: isDark
                  ? RaptrAIColors.darkTextMuted
                  : RaptrAIColors.lightTextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? RaptrAIColors.darkTextSecondary
                    : RaptrAIColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new chat to begin',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? RaptrAIColors.darkTextMuted
                    : RaptrAIColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A history item data class.
class RaptrAIHistoryItem {
  /// Unique identifier.
  final String id;

  /// Conversation title.
  final String title;

  /// Preview text (last message).
  final String? preview;

  /// Timestamp.
  final DateTime? timestamp;

  /// Number of messages.
  final int? messageCount;

  const RaptrAIHistoryItem({
    required this.id,
    required this.title,
    this.preview,
    this.timestamp,
    this.messageCount,
  });
}

class _HistoryItemWidget extends StatefulWidget {
  final RaptrAIHistoryItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _HistoryItemWidget({
    required this.item,
    required this.isSelected,
    this.onTap,
    this.onDelete,
  });

  @override
  State<_HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<_HistoryItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: widget.isSelected
              ? RaptrAIColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: widget.isSelected
                        ? RaptrAIColors.accent
                        : (isDark
                            ? RaptrAIColors.darkTextSecondary
                            : RaptrAIColors.lightTextSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? RaptrAIColors.accent
                                : (isDark
                                    ? RaptrAIColors.darkText
                                    : RaptrAIColors.lightText),
                          ),
                        ),
                        if (widget.item.preview != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.item.preview!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? RaptrAIColors.darkTextMuted
                                  : RaptrAIColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.onDelete != null && (_isHovered || widget.isSelected))
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: isDark
                          ? RaptrAIColors.darkTextMuted
                          : RaptrAIColors.lightTextMuted,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A bottom sheet for history on mobile.
class RaptrAIHistoryBottomSheet extends StatelessWidget {
  /// List of conversations.
  final List<RaptrAIHistoryItem> conversations;

  /// Currently selected conversation ID.
  final String? selectedId;

  /// Callback when a conversation is selected.
  final ValueChanged<String>? onConversationSelected;

  /// Callback when a conversation is deleted.
  final ValueChanged<String>? onConversationDeleted;

  /// Callback when "New Chat" is pressed.
  final VoidCallback? onNewChat;

  const RaptrAIHistoryBottomSheet({
    super.key,
    required this.conversations,
    this.selectedId,
    this.onConversationSelected,
    this.onConversationDeleted,
    this.onNewChat,
  });

  /// Shows the history bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required List<RaptrAIHistoryItem> conversations,
    String? selectedId,
    ValueChanged<String>? onConversationSelected,
    ValueChanged<String>? onConversationDeleted,
    VoidCallback? onNewChat,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => RaptrAIHistoryBottomSheet(
          conversations: conversations,
          selectedId: selectedId,
          onConversationSelected: (id) {
            Navigator.pop(context);
            onConversationSelected?.call(id);
          },
          onConversationDeleted: onConversationDeleted,
          onNewChat: () {
            Navigator.pop(context);
            onNewChat?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Chat History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: borderColor),
        // Content
        Expanded(
          child: RaptrAIHistoryPanel(
            conversations: conversations,
            selectedId: selectedId,
            onConversationSelected: onConversationSelected,
            onConversationDeleted: onConversationDeleted,
            onNewChat: onNewChat,
            showNewChatButton: true,
          ),
        ),
      ],
    );
  }
}
