import 'package:flutter/material.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';
import 'package:raptrai/src/theme/raptrai_theme.dart';

/// A suggestion item for the thread welcome screen.
class RaptrAISuggestion {
  const RaptrAISuggestion({
    required this.title,
    this.subtitle,
    this.icon,
  });

  /// Main title of the suggestion.
  final String title;

  /// Optional subtitle for additional context.
  final String? subtitle;

  /// Optional icon for the suggestion.
  final IconData? icon;
}

/// Welcome screen displayed when thread has no messages.
///
/// Matches assistant-ui ThreadWelcome component with greeting,
/// subtitle, and suggestion cards.
class RaptrAIThreadWelcome extends StatelessWidget {
  const RaptrAIThreadWelcome({
    required this.greeting,
    super.key,
    this.subtitle,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.suggestionColumns = 2,
  });

  /// Main greeting text (e.g., "Hello there!").
  final String greeting;

  /// Subtitle text (e.g., "How can I help you today?").
  final String? subtitle;

  /// List of suggestion cards to display.
  final List<RaptrAISuggestion> suggestions;

  /// Callback when a suggestion is tapped.
  final ValueChanged<RaptrAISuggestion>? onSuggestionTap;

  /// Number of columns for suggestion grid.
  final int suggestionColumns;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final subtitleColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingXl,
            vertical: RaptrAIColors.spacing2xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Greeting
                Text(
                  greeting,
                  style: RaptrAITypography.headingLarge(color: textColor),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: RaptrAIColors.spacingSm),
                  Text(
                    subtitle!,
                    style: RaptrAITypography.body(color: subtitleColor),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: RaptrAIColors.spacingXl),
                  _SuggestionGrid(
                    suggestions: suggestions,
                    columns: suggestionColumns,
                    onTap: onSuggestionTap,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({
    required this.suggestions,
    required this.columns,
    this.onTap,
  });

  final List<RaptrAISuggestion> suggestions;
  final int columns;
  final ValueChanged<RaptrAISuggestion>? onTap;

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get actual available width from constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = _calculateWidth(constraints.maxWidth);
        return Wrap(
          spacing: RaptrAIColors.spacingMd,
          runSpacing: RaptrAIColors.spacingMd,
          children: suggestions.map((suggestion) {
            return SizedBox(
              width: cardWidth,
              child: _SuggestionCard(
                suggestion: suggestion,
                onTap: onTap != null ? () => onTap!(suggestion) : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  double _calculateWidth(double availableWidth) {
    const minCardWidth = 120.0; // Minimum card width to prevent negative values
    final gapWidth = RaptrAIColors.spacingMd * (columns - 1);
    final calculatedWidth = (availableWidth - gapWidth) / columns;
    // Ensure we never return a negative or too-small width
    return calculatedWidth > minCardWidth ? calculatedWidth : minCardWidth;
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    this.onTap,
  });

  final RaptrAISuggestion suggestion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurfaceVariant;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final subtitleColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(RaptrAIColors.spacingLg),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestion.icon != null) ...[
                Icon(
                  suggestion.icon,
                  size: 20,
                  color: subtitleColor,
                ),
                const SizedBox(height: RaptrAIColors.spacingSm),
              ],
              Text(
                suggestion.title,
                style: RaptrAITypography.label(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (suggestion.subtitle != null) ...[
                const SizedBox(height: RaptrAIColors.spacingXs),
                Text(
                  suggestion.subtitle!,
                  style: RaptrAITypography.bodySmall(color: subtitleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Scrollable message list component.
///
/// Matches assistant-ui ThreadMessages with auto-scroll behavior.
class RaptrAIThreadMessages extends StatefulWidget {
  const RaptrAIThreadMessages({
    required this.messages,
    super.key,
    this.autoScroll = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: RaptrAIColors.spacingLg,
      vertical: RaptrAIColors.spacingSm,
    ),
    this.scrollController,
  });

  /// List of message widgets to display.
  final List<Widget> messages;

  /// Whether to auto-scroll to bottom on new messages.
  final bool autoScroll;

  /// Padding around the message list.
  final EdgeInsets padding;

  /// Controller for programmatic scroll control.
  final ScrollController? scrollController;

  @override
  State<RaptrAIThreadMessages> createState() => _RaptrAIThreadMessagesState();
}

class _RaptrAIThreadMessagesState extends State<RaptrAIThreadMessages> {
  late ScrollController _scrollController;
  bool _userScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(RaptrAIThreadMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScroll &&
        !_userScrolled &&
        widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50;
    if (!isAtBottom && !_userScrolled) {
      setState(() => _userScrolled = true);
    } else if (isAtBottom && _userScrolled) {
      setState(() => _userScrolled = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          controller: _scrollController,
          padding: widget.padding,
          itemCount: widget.messages.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: RaptrAIColors.spacingMd),
          itemBuilder: (context, index) => widget.messages[index],
        ),
        if (_userScrolled)
          Positioned(
            bottom: RaptrAIColors.spacingLg,
            left: 0,
            right: 0,
            child: Center(
              child: RaptrAIThreadScrollToBottom(
                onTap: () {
                  _scrollToBottom();
                  setState(() => _userScrolled = false);
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Button to scroll to the bottom of the message list.
class RaptrAIThreadScrollToBottom extends StatelessWidget {
  const RaptrAIThreadScrollToBottom({
    super.key,
    this.onTap,
  });

  /// Callback when button is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightBackground;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final iconColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
        child: Container(
          padding: const EdgeInsets.all(RaptrAIColors.spacingSm),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
          ),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Main thread container that combines messages and composer.
///
/// Matches assistant-ui Thread component structure.
class RaptrAIThread extends StatelessWidget {
  const RaptrAIThread({
    super.key,
    this.welcome,
    this.messages = const [],
    this.composer,
    this.showWelcome = true,
    this.scrollController,
    this.backgroundColor,
  });

  /// Welcome widget shown when there are no messages.
  final RaptrAIThreadWelcome? welcome;

  /// List of message widgets.
  final List<Widget> messages;

  /// Composer widget at the bottom.
  final Widget? composer;

  /// Whether to show the welcome screen (when messages is empty).
  final bool showWelcome;

  /// Scroll controller for the message list.
  final ScrollController? scrollController;

  /// Background color override.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? RaptrAIColors.darkBackground : RaptrAIColors.lightBackground);

    final showWelcomeScreen = showWelcome && messages.isEmpty && welcome != null;

    return ColoredBox(
      color: bgColor,
      child: Column(
        children: [
          Expanded(
            child: showWelcomeScreen
                ? welcome!
                : RaptrAIThreadMessages(
                    messages: messages,
                    scrollController: scrollController,
                  ),
          ),
          if (composer != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(RaptrAIColors.spacingLg),
                child: composer,
              ),
            ),
        ],
      ),
    );
  }
}
