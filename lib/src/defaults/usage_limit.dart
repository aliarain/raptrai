import 'package:flutter/material.dart';
import '../theme/raptrai_colors.dart';
import '../business/usage_tracker.dart';

/// Default widget shown when usage limits are reached.
///
/// Displays limit information and optional upgrade/wait actions.
///
/// Example:
/// ```dart
/// RaptrAIUsageLimitReached(
///   limitType: RaptrAILimitType.dailyTokens,
///   tracker: usageTracker,
///   onUpgrade: () => navigateToUpgrade(),
/// )
/// ```
class RaptrAIUsageLimitReached extends StatelessWidget {
  const RaptrAIUsageLimitReached({
    super.key,
    required this.limitType,
    this.tracker,
    this.onUpgrade,
    this.onDismiss,
    this.resetTime,
  });

  /// The type of limit that was reached.
  final RaptrAILimitType limitType;

  /// Optional tracker for showing usage stats.
  final RaptrAIUsageTracker? tracker;

  /// Called when upgrade is tapped.
  final VoidCallback? onUpgrade;

  /// Called when dismiss is tapped.
  final VoidCallback? onDismiss;

  /// When the limit resets (for countdown display).
  final DateTime? resetTime;

  String get _title {
    switch (limitType) {
      case RaptrAILimitType.dailyTokens:
        return 'Daily token limit reached';
      case RaptrAILimitType.requestsPerMinute:
        return 'Rate limit reached';
      case RaptrAILimitType.dailyCost:
        return 'Spending limit reached';
      case RaptrAILimitType.requestTokens:
        return 'Request too large';
    }
  }

  String get _subtitle {
    switch (limitType) {
      case RaptrAILimitType.dailyTokens:
        return 'Your daily token allowance has been used. Resets at midnight.';
      case RaptrAILimitType.requestsPerMinute:
        return 'Too many requests. Please wait a moment.';
      case RaptrAILimitType.dailyCost:
        return 'You\'ve reached your spending limit for today.';
      case RaptrAILimitType.requestTokens:
        return 'This request exceeds the maximum token limit.';
    }
  }

  IconData get _icon {
    switch (limitType) {
      case RaptrAILimitType.requestsPerMinute:
        return Icons.speed_rounded;
      case RaptrAILimitType.dailyCost:
        return Icons.attach_money_rounded;
      case RaptrAILimitType.requestTokens:
        return Icons.data_usage_rounded;
      case RaptrAILimitType.dailyTokens:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final mutedColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RaptrAIColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RaptrAIColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: RaptrAIColors.warning, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle,
            style: TextStyle(color: mutedColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (tracker != null) ...[
            const SizedBox(height: 16),
            _UsageStats(tracker: tracker!, isDark: isDark),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (onDismiss != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: mutedColor,
                      side: BorderSide(color: mutedColor.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
              if (onDismiss != null && onUpgrade != null)
                const SizedBox(width: 12),
              if (onUpgrade != null)
                Expanded(
                  child: FilledButton(
                    onPressed: onUpgrade,
                    style: FilledButton.styleFrom(
                      backgroundColor: RaptrAIColors.accent,
                    ),
                    child: const Text('Upgrade'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageStats extends StatelessWidget {
  const _UsageStats({required this.tracker, required this.isDark});

  final RaptrAIUsageTracker tracker;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final mutedColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;
    final usage = tracker.currentUsage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Tokens',
            value: _formatNumber(usage.totalTokens),
            color: mutedColor,
          ),
          _StatItem(
            label: 'Requests',
            value: '${usage.requests}',
            color: mutedColor,
          ),
          _StatItem(
            label: 'Cost',
            value: '\$${usage.estimatedCost.toStringAsFixed(2)}',
            color: mutedColor,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// Compact banner for showing limit warning.
class RaptrAIUsageLimitBanner extends StatelessWidget {
  const RaptrAIUsageLimitBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.action,
    this.actionLabel,
  });

  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: RaptrAIColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: RaptrAIColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
                fontSize: 13,
              ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: action,
              child: Text(actionLabel ?? 'View'),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
