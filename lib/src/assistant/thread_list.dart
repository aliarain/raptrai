import 'package:flutter/material.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';
import 'package:raptrai/src/theme/raptrai_theme.dart';
import 'package:shimmer/shimmer.dart';

/// Data model for a thread item.
class RaptrAIThreadData {
  const RaptrAIThreadData({
    required this.id,
    required this.title,
    this.preview,
    this.timestamp,
    this.isActive = false,
  });

  /// Unique identifier.
  final String id;

  /// Thread title.
  final String title;

  /// Preview of last message.
  final String? preview;

  /// Last updated timestamp.
  final DateTime? timestamp;

  /// Whether this thread is currently active.
  final bool isActive;
}

/// Button to create a new thread.
///
/// Matches assistant-ui ThreadListNew.
class RaptrAIThreadListNew extends StatelessWidget {
  const RaptrAIThreadListNew({
    super.key,
    this.onTap,
    this.label = 'New Thread',
    this.icon = Icons.add,
  });

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Button label.
  final String label;

  /// Button icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;
    final hoverColor = isDark
        ? RaptrAIColors.darkSurfaceVariant
        : RaptrAIColors.lightSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
        hoverColor: hoverColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingMd,
            vertical: RaptrAIColors.spacingSm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: RaptrAIColors.spacingSm),
              Expanded(
                child: Text(
                  label,
                  style: RaptrAITypography.label(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual thread item in the list.
///
/// Matches assistant-ui ThreadListItem.
class RaptrAIThreadListItem extends StatefulWidget {
  const RaptrAIThreadListItem({
    required this.thread,
    super.key,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  /// Thread data.
  final RaptrAIThreadData thread;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Callback when delete is tapped.
  final VoidCallback? onDelete;

  /// Whether this item is selected.
  final bool isSelected;

  @override
  State<RaptrAIThreadListItem> createState() => _RaptrAIThreadListItemState();
}

class _RaptrAIThreadListItemState extends State<RaptrAIThreadListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.isSelected
        ? (isDark
            ? RaptrAIColors.accent.withValues(alpha: 0.15)
            : RaptrAIColors.accent.withValues(alpha: 0.1))
        : Colors.transparent;
    final hoverColor = isDark
        ? RaptrAIColors.darkSurfaceVariant
        : RaptrAIColors.lightSurfaceVariant;
    final textColor = widget.isSelected
        ? RaptrAIColors.accent
        : (isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText);
    final subtitleColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;
    final iconColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
          hoverColor: widget.isSelected ? null : hoverColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RaptrAIColors.spacingMd,
              vertical: RaptrAIColors.spacingSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: widget.isSelected ? RaptrAIColors.accent : iconColor,
                ),
                const SizedBox(width: RaptrAIColors.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.thread.title,
                        style: RaptrAITypography.label(color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.thread.preview != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.thread.preview!,
                          style: RaptrAITypography.caption(color: subtitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_isHovered && widget.onDelete != null)
                  InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.all(RaptrAIColors.spacingXs),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: iconColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton loading placeholder for thread items.
///
/// Matches assistant-ui ThreadListSkeleton with shimmer effect.
class RaptrAIThreadListSkeleton extends StatelessWidget {
  const RaptrAIThreadListSkeleton({
    super.key,
    this.count = 5,
  });

  /// Number of skeleton items to show.
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final highlightColor =
        isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(count, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RaptrAIColors.spacingMd,
              vertical: RaptrAIColors.spacingSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: RaptrAIColors.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Complete thread list sidebar component.
///
/// Matches assistant-ui ThreadList with header, items, and footer.
class RaptrAIThreadList extends StatelessWidget {
  const RaptrAIThreadList({
    super.key,
    this.threads = const [],
    this.selectedThreadId,
    this.onNewThread,
    this.onSelectThread,
    this.onDeleteThread,
    this.isLoading = false,
    this.header,
    this.footer,
    this.width = 280,
    this.showNewThreadButton = true,
  });

  /// List of threads.
  final List<RaptrAIThreadData> threads;

  /// Currently selected thread ID.
  final String? selectedThreadId;

  /// Callback to create new thread.
  final VoidCallback? onNewThread;

  /// Callback when a thread is selected.
  final ValueChanged<RaptrAIThreadData>? onSelectThread;

  /// Callback when a thread is deleted.
  final ValueChanged<RaptrAIThreadData>? onDeleteThread;

  /// Whether threads are loading.
  final bool isLoading;

  /// Custom header widget.
  final Widget? header;

  /// Custom footer widget.
  final Widget? footer;

  /// Width of the sidebar.
  final double width;

  /// Whether to show new thread button.
  final bool showNewThreadButton;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        children: [
          // Header
          if (header != null)
            Padding(
              padding: const EdgeInsets.all(RaptrAIColors.spacingMd),
              child: header,
            ),
          // New thread button
          if (showNewThreadButton)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RaptrAIColors.spacingSm,
                vertical: RaptrAIColors.spacingXs,
              ),
              child: RaptrAIThreadListNew(onTap: onNewThread),
            ),
          // Divider
          if (showNewThreadButton || header != null)
            Divider(
              height: 1,
              color: borderColor,
            ),
          // Thread list
          Expanded(
            child: isLoading
                ? const RaptrAIThreadListSkeleton()
                : threads.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RaptrAIColors.spacingSm,
                          vertical: RaptrAIColors.spacingSm,
                        ),
                        itemCount: threads.length,
                        itemBuilder: (context, index) {
                          final thread = threads[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: RaptrAIColors.spacingXs,
                            ),
                            child: RaptrAIThreadListItem(
                              thread: thread,
                              isSelected: thread.id == selectedThreadId,
                              onTap: onSelectThread != null
                                  ? () => onSelectThread!(thread)
                                  : null,
                              onDelete: onDeleteThread != null
                                  ? () => onDeleteThread!(thread)
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
          // Footer
          if (footer != null) ...[
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(RaptrAIColors.spacingMd),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RaptrAIColors.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: textColor,
            ),
            const SizedBox(height: RaptrAIColors.spacingMd),
            Text(
              'No conversations yet',
              style: RaptrAITypography.body(color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full assistant layout with sidebar and main content.
///
/// Combines ThreadList with Thread for a complete chat interface.
class RaptrAIAssistantLayout extends StatelessWidget {
  const RaptrAIAssistantLayout({
    required this.thread,
    super.key,
    this.threadList,
    this.showSidebar = true,
    this.sidebarWidth = 280,
    this.breakpoint = 768,
  });

  /// Main thread/chat area.
  final Widget thread;

  /// Thread list sidebar.
  final Widget? threadList;

  /// Whether to show sidebar.
  final bool showSidebar;

  /// Width of the sidebar.
  final double sidebarWidth;

  /// Screen width breakpoint for hiding sidebar.
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldShowSidebar = showSidebar && screenWidth >= breakpoint;

    return Row(
      children: [
        if (shouldShowSidebar && threadList != null) threadList!,
        Expanded(child: thread),
      ],
    );
  }
}
