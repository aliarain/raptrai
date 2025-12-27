import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A badge component for status indicators and labels.
class RaptrAIBadge extends StatelessWidget {
  /// The badge label.
  final String label;

  /// The badge variant.
  final RaptrAIBadgeVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Badge size.
  final RaptrAIBadgeSize size;

  /// Whether to show a dot indicator instead of text.
  final bool dotOnly;

  /// Custom background color.
  final Color? backgroundColor;

  /// Custom text color.
  final Color? textColor;

  const RaptrAIBadge({
    super.key,
    required this.label,
    this.variant = RaptrAIBadgeVariant.neutral,
    this.icon,
    this.size = RaptrAIBadgeSize.medium,
    this.dotOnly = false,
    this.backgroundColor,
    this.textColor,
  });

  /// Creates a success badge.
  factory RaptrAIBadge.success({
    Key? key,
    required String label,
    IconData? icon,
    RaptrAIBadgeSize size = RaptrAIBadgeSize.medium,
  }) {
    return RaptrAIBadge(
      key: key,
      label: label,
      variant: RaptrAIBadgeVariant.success,
      icon: icon,
      size: size,
    );
  }

  /// Creates a warning badge.
  factory RaptrAIBadge.warning({
    Key? key,
    required String label,
    IconData? icon,
    RaptrAIBadgeSize size = RaptrAIBadgeSize.medium,
  }) {
    return RaptrAIBadge(
      key: key,
      label: label,
      variant: RaptrAIBadgeVariant.warning,
      icon: icon,
      size: size,
    );
  }

  /// Creates an error badge.
  factory RaptrAIBadge.error({
    Key? key,
    required String label,
    IconData? icon,
    RaptrAIBadgeSize size = RaptrAIBadgeSize.medium,
  }) {
    return RaptrAIBadge(
      key: key,
      label: label,
      variant: RaptrAIBadgeVariant.error,
      icon: icon,
      size: size,
    );
  }

  /// Creates an info badge.
  factory RaptrAIBadge.info({
    Key? key,
    required String label,
    IconData? icon,
    RaptrAIBadgeSize size = RaptrAIBadgeSize.medium,
  }) {
    return RaptrAIBadge(
      key: key,
      label: label,
      variant: RaptrAIBadgeVariant.info,
      icon: icon,
      size: size,
    );
  }

  /// Creates an accent badge.
  factory RaptrAIBadge.accent({
    Key? key,
    required String label,
    IconData? icon,
    RaptrAIBadgeSize size = RaptrAIBadgeSize.medium,
  }) {
    return RaptrAIBadge(
      key: key,
      label: label,
      variant: RaptrAIBadgeVariant.accent,
      icon: icon,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final bgColor = backgroundColor ?? colors.background;
    final fgColor = textColor ?? colors.foreground;
    final padding = _getPadding();
    final fontSize = _getFontSize();

    if (dotOnly) {
      return Container(
        width: _getDotSize(),
        height: _getDotSize(),
        decoration: BoxDecoration(
          color: fgColor,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _getColors() {
    switch (variant) {
      case RaptrAIBadgeVariant.neutral:
        return _BadgeColors(
          background: RaptrAIColors.slate200,
          foreground: RaptrAIColors.slate700,
        );
      case RaptrAIBadgeVariant.success:
        return _BadgeColors(
          background: RaptrAIColors.successLight,
          foreground: RaptrAIColors.success,
        );
      case RaptrAIBadgeVariant.warning:
        return _BadgeColors(
          background: RaptrAIColors.warningLight,
          foreground: RaptrAIColors.warning,
        );
      case RaptrAIBadgeVariant.error:
        return _BadgeColors(
          background: RaptrAIColors.errorLight,
          foreground: RaptrAIColors.error,
        );
      case RaptrAIBadgeVariant.info:
        return _BadgeColors(
          background: RaptrAIColors.infoLight,
          foreground: RaptrAIColors.info,
        );
      case RaptrAIBadgeVariant.accent:
        return _BadgeColors(
          background: RaptrAIColors.accentSubtle,
          foreground: RaptrAIColors.accent,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case RaptrAIBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case RaptrAIBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case RaptrAIBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
    }
  }

  double _getFontSize() {
    switch (size) {
      case RaptrAIBadgeSize.small:
        return 10;
      case RaptrAIBadgeSize.medium:
        return 12;
      case RaptrAIBadgeSize.large:
        return 14;
    }
  }

  double _getDotSize() {
    switch (size) {
      case RaptrAIBadgeSize.small:
        return 6;
      case RaptrAIBadgeSize.medium:
        return 8;
      case RaptrAIBadgeSize.large:
        return 10;
    }
  }
}

class _BadgeColors {
  final Color background;
  final Color foreground;

  const _BadgeColors({
    required this.background,
    required this.foreground,
  });
}

/// Badge variants.
enum RaptrAIBadgeVariant {
  neutral,
  success,
  warning,
  error,
  info,
  accent,
}

/// Badge sizes.
enum RaptrAIBadgeSize {
  small,
  medium,
  large,
}
