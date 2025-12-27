import 'package:flutter/material.dart';
import '../theme/raptrai_colors.dart';
import '../providers/provider_interface.dart';

/// Default dialog for approving tool/function calls.
///
/// Shows tool details and allows user to approve or deny execution.
///
/// Example:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => RaptrAIToolApprovalDialog(
///     toolCall: toolCall,
///     onApprove: () => executor.execute(toolCall),
///     onDeny: () => controller.cancelToolCall(toolCall),
///   ),
/// );
/// ```
class RaptrAIToolApprovalDialog extends StatelessWidget {
  const RaptrAIToolApprovalDialog({
    super.key,
    required this.toolCall,
    required this.onApprove,
    required this.onDeny,
    this.toolDescription,
    this.alwaysAllowOption = true,
  });

  /// The tool call to approve.
  final RaptrAIToolCall toolCall;

  /// Called when approved.
  final VoidCallback onApprove;

  /// Called when denied.
  final VoidCallback onDeny;

  /// Optional description of what the tool does.
  final String? toolDescription;

  /// Whether to show "Always allow" option.
  final bool alwaysAllowOption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final mutedColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RaptrAIColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.extension_rounded,
                      color: RaptrAIColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allow tool execution?',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          toolCall.name,
                          style: TextStyle(
                            color: RaptrAIColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (toolDescription != null) ...[
                const SizedBox(height: 16),
                Text(
                  toolDescription!,
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
              ],

              // Arguments
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? RaptrAIColors.slate900 : RaptrAIColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arguments',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...toolCall.arguments.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: TextStyle(
                                color: RaptrAIColors.accent,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatValue(entry.value),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Actions
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDeny();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: mutedColor,
                        side: BorderSide(color: borderColor),
                      ),
                      child: const Text('Deny'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onApprove();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: RaptrAIColors.accent,
                      ),
                      child: const Text('Allow'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is String) return '"$value"';
    if (value is Map || value is List) {
      return value.toString();
    }
    return value.toString();
  }
}

/// Inline tool approval card (non-dialog version).
class RaptrAIToolApprovalCard extends StatelessWidget {
  const RaptrAIToolApprovalCard({
    super.key,
    required this.toolCall,
    required this.onApprove,
    required this.onDeny,
    this.toolDescription,
  });

  final RaptrAIToolCall toolCall;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final String? toolDescription;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final mutedColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

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
              Icon(Icons.extension_rounded, color: RaptrAIColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                toolCall.name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Waiting for approval',
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
            ],
          ),
          if (toolDescription != null) ...[
            const SizedBox(height: 8),
            Text(
              toolDescription!,
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDeny,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: mutedColor,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Deny'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: RaptrAIColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Allow'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tool approval mode for RaptrAIChat.
enum RaptrAIToolApprovalMode {
  /// Never ask for approval, execute tools automatically.
  auto,

  /// Ask for approval on first use of each tool.
  firstUse,

  /// Always ask for approval before executing tools.
  always,

  /// Never execute tools (deny all).
  never,
}
