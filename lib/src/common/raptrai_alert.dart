import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// An alert component for displaying messages and notifications.
class RaptrAIAlert extends StatelessWidget {
  /// The alert message.
  final String message;

  /// Optional title.
  final String? title;

  /// Alert variant.
  final RaptrAIAlertVariant variant;

  /// Optional icon override.
  final IconData? icon;

  /// Whether to show the icon.
  final bool showIcon;

  /// Optional action widget.
  final Widget? action;

  /// Whether the alert can be dismissed.
  final bool dismissible;

  /// Callback when dismissed.
  final VoidCallback? onDismiss;

  /// Border radius.
  final double borderRadius;

  const RaptrAIAlert({
    super.key,
    required this.message,
    this.title,
    this.variant = RaptrAIAlertVariant.info,
    this.icon,
    this.showIcon = true,
    this.action,
    this.dismissible = false,
    this.onDismiss,
    this.borderRadius = 8,
  });

  /// Creates an info alert.
  factory RaptrAIAlert.info({
    Key? key,
    required String message,
    String? title,
    Widget? action,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return RaptrAIAlert(
      key: key,
      message: message,
      title: title,
      variant: RaptrAIAlertVariant.info,
      action: action,
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Creates a success alert.
  factory RaptrAIAlert.success({
    Key? key,
    required String message,
    String? title,
    Widget? action,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return RaptrAIAlert(
      key: key,
      message: message,
      title: title,
      variant: RaptrAIAlertVariant.success,
      action: action,
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Creates a warning alert.
  factory RaptrAIAlert.warning({
    Key? key,
    required String message,
    String? title,
    Widget? action,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return RaptrAIAlert(
      key: key,
      message: message,
      title: title,
      variant: RaptrAIAlertVariant.warning,
      action: action,
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  /// Creates an error alert.
  factory RaptrAIAlert.error({
    Key? key,
    required String message,
    String? title,
    Widget? action,
    bool dismissible = false,
    VoidCallback? onDismiss,
  }) {
    return RaptrAIAlert(
      key: key,
      message: message,
      title: title,
      variant: RaptrAIAlertVariant.error,
      action: action,
      dismissible: dismissible,
      onDismiss: onDismiss,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final alertIcon = icon ?? _getDefaultIcon();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(alertIcon, color: colors.icon, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.title,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: colors.message,
                    height: 1.4,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 12),
                  action!,
                ],
              ],
            ),
          ),
          if (dismissible) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 18,
                color: colors.icon,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (variant) {
      case RaptrAIAlertVariant.info:
        return Icons.info_outline;
      case RaptrAIAlertVariant.success:
        return Icons.check_circle_outline;
      case RaptrAIAlertVariant.warning:
        return Icons.warning_amber_rounded;
      case RaptrAIAlertVariant.error:
        return Icons.error_outline;
    }
  }

  _AlertColors _getColors() {
    switch (variant) {
      case RaptrAIAlertVariant.info:
        return _AlertColors(
          background: RaptrAIColors.infoLight,
          border: RaptrAIColors.info.withValues(alpha: 0.3),
          icon: RaptrAIColors.info,
          title: RaptrAIColors.infoDark,
          message: RaptrAIColors.infoDark.withValues(alpha: 0.8),
        );
      case RaptrAIAlertVariant.success:
        return _AlertColors(
          background: RaptrAIColors.successLight,
          border: RaptrAIColors.success.withValues(alpha: 0.3),
          icon: RaptrAIColors.success,
          title: RaptrAIColors.successDark,
          message: RaptrAIColors.successDark.withValues(alpha: 0.8),
        );
      case RaptrAIAlertVariant.warning:
        return _AlertColors(
          background: RaptrAIColors.warningLight,
          border: RaptrAIColors.warning.withValues(alpha: 0.3),
          icon: RaptrAIColors.warning,
          title: RaptrAIColors.warningDark,
          message: RaptrAIColors.warningDark.withValues(alpha: 0.8),
        );
      case RaptrAIAlertVariant.error:
        return _AlertColors(
          background: RaptrAIColors.errorLight,
          border: RaptrAIColors.error.withValues(alpha: 0.3),
          icon: RaptrAIColors.error,
          title: RaptrAIColors.errorDark,
          message: RaptrAIColors.errorDark.withValues(alpha: 0.8),
        );
    }
  }
}

class _AlertColors {
  final Color background;
  final Color border;
  final Color icon;
  final Color title;
  final Color message;

  const _AlertColors({
    required this.background,
    required this.border,
    required this.icon,
    required this.title,
    required this.message,
  });
}

/// Alert variants.
enum RaptrAIAlertVariant {
  info,
  success,
  warning,
  error,
}
