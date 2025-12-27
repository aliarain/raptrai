import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A sidebar component for AI chat applications.
///
/// Displays conversation history and navigation items.
class RaptrAISidebar extends StatelessWidget {
  /// Header widget (logo, title, etc.).
  final Widget? header;

  /// List of sidebar items.
  final List<RaptrAISidebarItem> items;

  /// Currently selected item index.
  final int? selectedIndex;

  /// Callback when an item is selected.
  final ValueChanged<int>? onItemSelected;

  /// Footer widget (settings, profile, etc.).
  final Widget? footer;

  /// Width of the sidebar.
  final double width;

  /// Whether the sidebar is collapsed.
  final bool collapsed;

  /// Background color.
  final Color? backgroundColor;

  const RaptrAISidebar({
    super.key,
    this.header,
    required this.items,
    this.selectedIndex,
    this.onItemSelected,
    this.footer,
    this.width = 280,
    this.collapsed = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightBackground);
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 72 : width,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: header!,
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return _SidebarItemWidget(
                  item: item,
                  isSelected: isSelected,
                  collapsed: collapsed,
                  onTap: () => onItemSelected?.call(index),
                );
              },
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

/// A sidebar item data class.
class RaptrAISidebarItem {
  /// The item title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Custom callback (overrides onItemSelected).
  final VoidCallback? onTap;

  const RaptrAISidebarItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
  });
}

class _SidebarItemWidget extends StatelessWidget {
  final RaptrAISidebarItem item;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback? onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.collapsed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = RaptrAIColors.accent.withValues(alpha: 0.1);
    final selectedFg = RaptrAIColors.accent;
    final defaultFg =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: item.onTap ?? onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 12 : 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                if (item.icon != null)
                  Icon(
                    item.icon,
                    size: 20,
                    color: isSelected ? selectedFg : defaultFg,
                  ),
                if (!collapsed && item.icon != null) const SizedBox(width: 12),
                if (!collapsed)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? selectedFg
                                : (isDark
                                    ? RaptrAIColors.darkText
                                    : RaptrAIColors.lightText),
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: defaultFg,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (!collapsed && item.trailing != null) item.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A conversation item for the sidebar.
class RaptrAIConversationItem extends StatelessWidget {
  /// The conversation title.
  final String title;

  /// Preview of the last message.
  final String? preview;

  /// Timestamp of the last message.
  final DateTime? timestamp;

  /// Whether this conversation is selected.
  final bool isSelected;

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Callback when delete is pressed.
  final VoidCallback? onDelete;

  const RaptrAIConversationItem({
    super.key,
    required this.title,
    this.preview,
    this.timestamp,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? RaptrAIColors.accent.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: isSelected
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? RaptrAIColors.accent
                            : (isDark
                                ? RaptrAIColors.darkText
                                : RaptrAIColors.lightText),
                      ),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        preview!,
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
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
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
    );
  }
}
