import 'package:flutter/material.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';
import 'package:raptrai/src/theme/raptrai_theme.dart';

/// Status of a tool call.
enum RaptrAIToolCallStatus {
  pending,
  running,
  completed,
  failed,
}

/// Data model for a tool call.
class RaptrAIToolCallData {
  const RaptrAIToolCallData({
    required this.id,
    required this.name,
    this.arguments,
    this.result,
    this.status = RaptrAIToolCallStatus.pending,
    this.error,
  });

  /// Unique identifier.
  final String id;

  /// Tool/function name.
  final String name;

  /// Arguments passed to the tool.
  final Map<String, dynamic>? arguments;

  /// Result from the tool.
  final dynamic result;

  /// Current status.
  final RaptrAIToolCallStatus status;

  /// Error message if failed.
  final String? error;
}

/// Progress indicator for tool execution.
///
/// Matches assistant-ui ToolCallProgress.
class RaptrAIToolCallProgress extends StatelessWidget {
  const RaptrAIToolCallProgress({
    super.key,
    this.message = 'Running...',
  });

  /// Progress message.
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(RaptrAIColors.accent),
          ),
        ),
        const SizedBox(width: RaptrAIColors.spacingSm),
        Text(
          message,
          style: RaptrAITypography.bodySmall(color: textColor),
        ),
      ],
    );
  }
}

/// Display for tool call result.
///
/// Matches assistant-ui ToolCallResult.
class RaptrAIToolCallResult extends StatelessWidget {
  const RaptrAIToolCallResult({
    required this.result,
    super.key,
    this.isSuccess = true,
  });

  /// Result content.
  final String result;

  /// Whether the result is successful.
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isSuccess
        ? (isDark ? RaptrAIColors.successDark.withValues(alpha: 0.2) : RaptrAIColors.successLight)
        : (isDark ? RaptrAIColors.errorDark.withValues(alpha: 0.2) : RaptrAIColors.errorLight);
    final textColor = isSuccess
        ? (isDark ? RaptrAIColors.success : RaptrAIColors.successDark)
        : (isDark ? RaptrAIColors.error : RaptrAIColors.errorDark);
    final iconColor = isSuccess ? RaptrAIColors.success : RaptrAIColors.error;

    return Container(
      padding: const EdgeInsets.all(RaptrAIColors.spacingMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: RaptrAIColors.spacingSm),
          Expanded(
            child: Text(
              result,
              style: RaptrAITypography.bodySmall(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Complete tool call display component.
///
/// Matches assistant-ui ToolCall with collapsible card.
class RaptrAIToolCallWidget extends StatefulWidget {
  const RaptrAIToolCallWidget({
    required this.toolCall,
    super.key,
    this.initiallyExpanded = false,
    this.showArguments = true,
    this.showResult = true,
  });

  /// Tool call data.
  final RaptrAIToolCallData toolCall;

  /// Whether to start expanded.
  final bool initiallyExpanded;

  /// Whether to show arguments.
  final bool showArguments;

  /// Whether to show result.
  final bool showResult;

  @override
  State<RaptrAIToolCallWidget> createState() => _RaptrAIToolCallWidgetState();
}

class _RaptrAIToolCallWidgetState extends State<RaptrAIToolCallWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final subtitleColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(RaptrAIColors.radiusMd),
              bottom: _isExpanded
                  ? Radius.zero
                  : const Radius.circular(RaptrAIColors.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(RaptrAIColors.spacingMd),
              child: Row(
                children: [
                  _StatusIcon(status: widget.toolCall.status),
                  const SizedBox(width: RaptrAIColors.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.toolCall.name,
                          style: RaptrAITypography.label(color: textColor),
                        ),
                        Text(
                          _getStatusText(),
                          style: RaptrAITypography.caption(color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: subtitleColor,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded) ...[
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(RaptrAIColors.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arguments
                  if (widget.showArguments &&
                      widget.toolCall.arguments != null &&
                      widget.toolCall.arguments!.isNotEmpty) ...[
                    Text(
                      'Arguments',
                      style: RaptrAITypography.labelSmall(color: subtitleColor),
                    ),
                    const SizedBox(height: RaptrAIColors.spacingXs),
                    _JsonDisplay(data: widget.toolCall.arguments!),
                    const SizedBox(height: RaptrAIColors.spacingMd),
                  ],
                  // Result
                  if (widget.showResult &&
                      widget.toolCall.status == RaptrAIToolCallStatus.completed &&
                      widget.toolCall.result != null) ...[
                    Text(
                      'Result',
                      style: RaptrAITypography.labelSmall(color: subtitleColor),
                    ),
                    const SizedBox(height: RaptrAIColors.spacingXs),
                    RaptrAIToolCallResult(
                      result: widget.toolCall.result.toString(),
                    ),
                  ],
                  // Error
                  if (widget.toolCall.status == RaptrAIToolCallStatus.failed &&
                      widget.toolCall.error != null) ...[
                    Text(
                      'Error',
                      style: RaptrAITypography.labelSmall(color: subtitleColor),
                    ),
                    const SizedBox(height: RaptrAIColors.spacingXs),
                    RaptrAIToolCallResult(
                      result: widget.toolCall.error!,
                      isSuccess: false,
                    ),
                  ],
                  // Progress
                  if (widget.toolCall.status == RaptrAIToolCallStatus.running)
                    const RaptrAIToolCallProgress(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (widget.toolCall.status) {
      case RaptrAIToolCallStatus.pending:
        return 'Pending...';
      case RaptrAIToolCallStatus.running:
        return 'Running...';
      case RaptrAIToolCallStatus.completed:
        return 'Completed';
      case RaptrAIToolCallStatus.failed:
        return 'Failed';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final RaptrAIToolCallStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case RaptrAIToolCallStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          size: 16,
          color: RaptrAIColors.zinc500,
        );
      case RaptrAIToolCallStatus.running:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(RaptrAIColors.accent),
          ),
        );
      case RaptrAIToolCallStatus.completed:
        return Icon(
          Icons.check_circle,
          size: 16,
          color: RaptrAIColors.success,
        );
      case RaptrAIToolCallStatus.failed:
        return Icon(
          Icons.error,
          size: 16,
          color: RaptrAIColors.error,
        );
    }
  }
}

class _JsonDisplay extends StatelessWidget {
  const _JsonDisplay({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final keyColor = RaptrAIColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RaptrAIColors.spacingSm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.key}: ',
                    style: RaptrAITypography.caption(color: keyColor),
                  ),
                  TextSpan(
                    text: entry.value.toString(),
                    style: RaptrAITypography.caption(color: textColor),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Inline tool call indicator (compact version).
class RaptrAIToolCallInline extends StatelessWidget {
  const RaptrAIToolCallInline({
    required this.name,
    super.key,
    this.status = RaptrAIToolCallStatus.running,
    this.onTap,
  });

  /// Tool name.
  final String name;

  /// Current status.
  final RaptrAIToolCallStatus status;

  /// Callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final textColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RaptrAIColors.spacingSm,
          vertical: RaptrAIColors.spacingXs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusIcon(status: status),
            const SizedBox(width: RaptrAIColors.spacingXs),
            Text(
              name,
              style: RaptrAITypography.caption(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
