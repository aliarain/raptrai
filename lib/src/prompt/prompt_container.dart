import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A container for prompt/chat interfaces.
///
/// Provides different layout styles for AI chat applications.
class RaptrAIPromptContainer extends StatelessWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// The style variant of the container.
  final PromptContainerStyle style;

  /// Optional header widget.
  final Widget? header;

  /// Optional footer widget (typically the input area).
  final Widget? footer;

  /// Background color override.
  final Color? backgroundColor;

  /// Border radius for the container.
  final double borderRadius;

  /// Whether to show a border.
  final bool showBorder;

  /// Padding inside the container.
  final EdgeInsets padding;

  const RaptrAIPromptContainer({
    super.key,
    required this.child,
    this.style = PromptContainerStyle.card,
    this.header,
    this.footer,
    this.backgroundColor,
    this.borderRadius = 16,
    this.showBorder = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface);
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    Widget content = Column(
      children: [
        if (header != null) header!,
        Expanded(child: child),
        if (footer != null) footer!,
      ],
    );

    switch (style) {
      case PromptContainerStyle.card:
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder ? Border.all(color: borderColor) : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        );

      case PromptContainerStyle.floating:
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder ? Border.all(color: borderColor) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        );

      case PromptContainerStyle.fullscreen:
        return Container(
          color: bgColor,
          child: SafeArea(
            child: Padding(
              padding: padding,
              child: content,
            ),
          ),
        );

      case PromptContainerStyle.minimal:
        return Padding(
          padding: padding,
          child: content,
        );
    }
  }
}

/// Style variants for [RaptrAIPromptContainer].
enum PromptContainerStyle {
  /// Card-style container with border and rounded corners.
  card,

  /// Floating card with shadow effect.
  floating,

  /// Full-screen container.
  fullscreen,

  /// Minimal container with no styling.
  minimal,
}
