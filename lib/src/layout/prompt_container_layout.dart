import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A responsive layout for AI chat applications.
///
/// Adapts between sidebar layout on desktop and bottom sheet on mobile.
class RaptrAIPromptContainerLayout extends StatelessWidget {
  /// The main chat content.
  final Widget body;

  /// Sidebar content (history, navigation).
  final Widget? sidebar;

  /// Whether to show the sidebar.
  final bool showSidebar;

  /// Breakpoint for showing sidebar (in logical pixels).
  final double sidebarBreakpoint;

  /// Width of the sidebar.
  final double sidebarWidth;

  /// App bar for the layout.
  final PreferredSizeWidget? appBar;

  /// Floating action button.
  final Widget? floatingActionButton;

  const RaptrAIPromptContainerLayout({
    super.key,
    required this.body,
    this.sidebar,
    this.showSidebar = true,
    this.sidebarBreakpoint = 768,
    this.sidebarWidth = 280,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= sidebarBreakpoint;
        final shouldShowSidebar = showSidebar && sidebar != null && isWideScreen;

        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              if (shouldShowSidebar)
                SizedBox(
                  width: sidebarWidth,
                  child: sidebar!,
                ),
              Expanded(child: body),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}

/// A centered chat container with maximum width constraint.
class RaptrAICenteredChat extends StatelessWidget {
  /// The chat content.
  final Widget child;

  /// Maximum width of the chat area.
  final double maxWidth;

  /// Padding around the chat area.
  final EdgeInsets padding;

  /// Background color.
  final Color? backgroundColor;

  const RaptrAICenteredChat({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A full-screen chat layout with header and input.
class RaptrAIChatLayout extends StatelessWidget {
  /// The header widget (title bar).
  final Widget? header;

  /// The messages list widget.
  final Widget messages;

  /// The input widget.
  final Widget input;

  /// Empty state widget (shown when no messages).
  final Widget? emptyState;

  /// Whether to show the empty state.
  final bool isEmpty;

  /// Background color.
  final Color? backgroundColor;

  const RaptrAIChatLayout({
    super.key,
    this.header,
    required this.messages,
    required this.input,
    this.emptyState,
    this.isEmpty = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? RaptrAIColors.darkBackground : RaptrAIColors.lightBackground);

    return Container(
      color: bgColor,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: isEmpty && emptyState != null ? emptyState! : messages,
          ),
          input,
        ],
      ),
    );
  }
}

/// A chat header with title and actions.
class RaptrAIChatHeader extends StatelessWidget {
  /// The title text.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Leading widget (back button, avatar, etc.).
  final Widget? leading;

  /// Action widgets.
  final List<Widget>? actions;

  /// Whether to show a border at the bottom.
  final bool showBorder;

  const RaptrAIChatHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightBackground,
        border: showBorder
            ? Border(bottom: BorderSide(color: borderColor))
            : null,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? RaptrAIColors.darkTextSecondary
                          : RaptrAIColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
