import 'package:flutter/material.dart';
import '../theme/raptrai_colors.dart';

/// Default retry banner shown when stream/response fails.
///
/// Appears at the bottom of the chat with retry action.
///
/// Example:
/// ```dart
/// RaptrAIRetryBanner(
///   message: 'Connection lost',
///   onRetry: () => controller.regenerate(messageId),
/// )
/// ```
class RaptrAIRetryBanner extends StatelessWidget {
  const RaptrAIRetryBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.isRetrying = false,
  });

  /// Error message to display.
  final String message;

  /// Called when retry is tapped.
  final VoidCallback? onRetry;

  /// Called when dismiss is tapped.
  final VoidCallback? onDismiss;

  /// Whether a retry is in progress.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = RaptrAIColors.error.withValues(alpha: isDark ? 0.15 : 0.1);
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: RaptrAIColors.error.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: RaptrAIColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: isRetrying ? null : onRetry,
              child: isRetrying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Retry'),
            ),
          if (onDismiss != null && !isRetrying)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 18,
                color: isDark
                    ? RaptrAIColors.darkTextMuted
                    : RaptrAIColors.lightTextMuted,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}

/// Animated retry banner with countdown.
class RaptrAIAutoRetryBanner extends StatefulWidget {
  const RaptrAIAutoRetryBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.onCancel,
    this.retryDelay = const Duration(seconds: 5),
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onCancel;
  final Duration retryDelay;

  @override
  State<RaptrAIAutoRetryBanner> createState() => _RaptrAIAutoRetryBannerState();
}

class _RaptrAIAutoRetryBannerState extends State<RaptrAIAutoRetryBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.retryDelay,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_cancelled) {
        widget.onRetry();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCancel() {
    _cancelled = true;
    _controller.stop();
    widget.onCancel?.call();
  }

  void _handleRetryNow() {
    _cancelled = true;
    _controller.stop();
    widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = RaptrAIColors.warning.withValues(alpha: isDark ? 0.15 : 0.1);
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final mutedColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: RaptrAIColors.warning.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.autorenew_rounded,
                size: 18,
                color: RaptrAIColors.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: _handleRetryNow,
                child: const Text('Retry now'),
              ),
              TextButton(
                onPressed: _handleCancel,
                style: TextButton.styleFrom(foregroundColor: mutedColor),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _controller.value,
                backgroundColor: mutedColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(RaptrAIColors.warning),
              );
            },
          ),
        ],
      ),
    );
  }
}
