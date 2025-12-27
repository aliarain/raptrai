import 'package:flutter/material.dart';
import '../theme/raptrai_colors.dart';
import '../providers/provider_interface.dart';

/// Default error state widget shown when AI requests fail.
///
/// Shows a friendly error message with optional retry action.
///
/// Example:
/// ```dart
/// RaptrAIErrorState(
///   error: exception,
///   onRetry: () => controller.regenerate(messageId),
/// )
/// ```
class RaptrAIErrorState extends StatelessWidget {
  const RaptrAIErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  /// The error that occurred.
  final RaptrAIException error;

  /// Called when retry is tapped.
  final VoidCallback? onRetry;

  /// Called when dismiss is tapped.
  final VoidCallback? onDismiss;

  /// Whether to show detailed error info.
  final bool showDetails;

  String get _friendlyMessage {
    switch (error.code) {
      case 'rate_limit':
        return 'Too many requests. Please wait a moment.';
      case 'auth_error':
        return 'Authentication failed. Check your API key.';
      case 'network_error':
        return 'Network error. Check your connection.';
      case 'timeout':
        return 'Request timed out. Please try again.';
      case 'invalid_request':
        return 'Invalid request. Please try rephrasing.';
      case 'context_length':
        return 'Conversation too long. Try starting fresh.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;
    final borderColor = RaptrAIColors.error.withValues(alpha: 0.3);
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final mutedColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: RaptrAIColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _friendlyMessage,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close, size: 18, color: mutedColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
            ],
          ),
          if (showDetails && error.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              error.message,
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: RaptrAIColors.accent,
                  side: BorderSide(color: RaptrAIColors.accent.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline error widget for compact display.
class RaptrAIErrorInline extends StatelessWidget {
  const RaptrAIErrorInline({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_amber_rounded, size: 16, color: RaptrAIColors.warning),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry', style: TextStyle(fontSize: 13)),
          ),
        ],
      ],
    );
  }
}
