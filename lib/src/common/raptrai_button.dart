import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A styled button component for AI interfaces.
class RaptrAIButton extends StatelessWidget {
  /// The button label.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// The button style variant.
  final RaptrAIButtonStyle style;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional trailing icon.
  final IconData? trailingIcon;

  /// Whether the button is in loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool disabled;

  /// Custom background color.
  final Color? backgroundColor;

  /// Custom text color.
  final Color? textColor;

  /// Button size.
  final RaptrAIButtonSize size;

  /// Whether to expand to full width.
  final bool fullWidth;

  const RaptrAIButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = RaptrAIButtonStyle.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.disabled = false,
    this.backgroundColor,
    this.textColor,
    this.size = RaptrAIButtonSize.medium,
    this.fullWidth = false,
  });

  /// Creates a primary styled button.
  factory RaptrAIButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool disabled = false,
    RaptrAIButtonSize size = RaptrAIButtonSize.medium,
    bool fullWidth = false,
  }) {
    return RaptrAIButton(
      key: key,
      label: label,
      onPressed: onPressed,
      style: RaptrAIButtonStyle.primary,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      size: size,
      fullWidth: fullWidth,
    );
  }

  /// Creates a secondary styled button.
  factory RaptrAIButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool disabled = false,
    RaptrAIButtonSize size = RaptrAIButtonSize.medium,
    bool fullWidth = false,
  }) {
    return RaptrAIButton(
      key: key,
      label: label,
      onPressed: onPressed,
      style: RaptrAIButtonStyle.secondary,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      size: size,
      fullWidth: fullWidth,
    );
  }

  /// Creates an outlined button.
  factory RaptrAIButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool disabled = false,
    RaptrAIButtonSize size = RaptrAIButtonSize.medium,
    bool fullWidth = false,
  }) {
    return RaptrAIButton(
      key: key,
      label: label,
      onPressed: onPressed,
      style: RaptrAIButtonStyle.outlined,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      size: size,
      fullWidth: fullWidth,
    );
  }

  /// Creates a ghost/text button.
  factory RaptrAIButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool disabled = false,
    RaptrAIButtonSize size = RaptrAIButtonSize.medium,
    bool fullWidth = false,
  }) {
    return RaptrAIButton(
      key: key,
      label: label,
      onPressed: onPressed,
      style: RaptrAIButtonStyle.ghost,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      size: size,
      fullWidth: fullWidth,
    );
  }

  /// Creates a danger/destructive button.
  factory RaptrAIButton.danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool disabled = false,
    RaptrAIButtonSize size = RaptrAIButtonSize.medium,
    bool fullWidth = false,
  }) {
    return RaptrAIButton(
      key: key,
      label: label,
      onPressed: onPressed,
      style: RaptrAIButtonStyle.danger,
      icon: icon,
      isLoading: isLoading,
      disabled: disabled,
      size: size,
      fullWidth: fullWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = disabled || isLoading;

    final padding = _getPadding();
    final fontSize = _getFontSize();
    final iconSize = _getIconSize();

    final colors = _getColors(isDark);
    final bgColor = backgroundColor ?? colors.background;
    final fgColor = textColor ?? colors.foreground;
    final borderColor = colors.border;

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: iconSize, color: fgColor),
        ],
      ],
    );

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: borderColor != null
                  ? Border.all(color: borderColor)
                  : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case RaptrAIButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case RaptrAIButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case RaptrAIButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (size) {
      case RaptrAIButtonSize.small:
        return 13;
      case RaptrAIButtonSize.medium:
        return 14;
      case RaptrAIButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case RaptrAIButtonSize.small:
        return 16;
      case RaptrAIButtonSize.medium:
        return 18;
      case RaptrAIButtonSize.large:
        return 20;
    }
  }

  _ButtonColors _getColors(bool isDark) {
    switch (style) {
      case RaptrAIButtonStyle.primary:
        return _ButtonColors(
          background: RaptrAIColors.accent,
          foreground: Colors.white,
          border: null,
        );
      case RaptrAIButtonStyle.secondary:
        return _ButtonColors(
          background: isDark
              ? RaptrAIColors.darkSurfaceVariant
              : RaptrAIColors.lightSurfaceVariant,
          foreground: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
          border: null,
        );
      case RaptrAIButtonStyle.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: RaptrAIColors.accent,
          border: RaptrAIColors.accent,
        );
      case RaptrAIButtonStyle.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
          border: null,
        );
      case RaptrAIButtonStyle.danger:
        return _ButtonColors(
          background: RaptrAIColors.error,
          foreground: Colors.white,
          border: null,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color? border;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });
}

/// Button style variants.
enum RaptrAIButtonStyle {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
}

/// Button size variants.
enum RaptrAIButtonSize {
  small,
  medium,
  large,
}
