import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A styled card component for AI interfaces.
class RaptrAICard extends StatelessWidget {
  /// The card content.
  final Widget child;

  /// Optional header widget.
  final Widget? header;

  /// Optional footer widget.
  final Widget? footer;

  /// Card style variant.
  final RaptrAICardStyle style;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Custom background color.
  final Color? backgroundColor;

  /// Border radius.
  final double borderRadius;

  /// Whether the card is interactive.
  final bool interactive;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  const RaptrAICard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.style = RaptrAICardStyle.bordered,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 12,
    this.interactive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightBackground);
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          header!,
          Divider(color: borderColor, height: 1),
        ],
        Padding(
          padding: padding,
          child: child,
        ),
        if (footer != null) ...[
          Divider(color: borderColor, height: 1),
          footer!,
        ],
      ],
    );

    final decoration = _buildDecoration(bgColor, borderColor, isDark);

    if (interactive || onTap != null) {
      return Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: decoration.copyWith(color: Colors.transparent),
            child: content,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      child: content,
    );
  }

  BoxDecoration _buildDecoration(
    Color bgColor,
    Color borderColor,
    bool isDark,
  ) {
    switch (style) {
      case RaptrAICardStyle.bordered:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        );
      case RaptrAICardStyle.elevated:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case RaptrAICardStyle.filled:
        return BoxDecoration(
          color: isDark
              ? RaptrAIColors.darkSurfaceVariant
              : RaptrAIColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case RaptrAICardStyle.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        );
    }
  }
}

/// Card style variants.
enum RaptrAICardStyle {
  bordered,
  elevated,
  filled,
  ghost,
}

/// A feature card with icon and description.
class RaptrAIFeatureCard extends StatelessWidget {
  /// The feature title.
  final String title;

  /// The feature description.
  final String description;

  /// The feature icon.
  final IconData icon;

  /// Icon color.
  final Color? iconColor;

  /// Callback when tapped.
  final VoidCallback? onTap;

  const RaptrAIFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ?? RaptrAIColors.accent;

    return RaptrAICard(
      onTap: onTap,
      interactive: onTap != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? RaptrAIColors.darkTextSecondary
                  : RaptrAIColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
