import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/raptrai_colors.dart';

/// A button that copies text to clipboard with visual feedback.
class RaptrAICopyButton extends StatefulWidget {
  /// The text to copy.
  final String textToCopy;

  /// Optional tooltip text.
  final String tooltip;

  /// Text shown after copying.
  final String copiedText;

  /// Duration to show "copied" state.
  final Duration copiedDuration;

  /// Button style variant.
  final RaptrAICopyButtonStyle style;

  /// Icon size.
  final double iconSize;

  /// Callback after copy.
  final VoidCallback? onCopied;

  const RaptrAICopyButton({
    super.key,
    required this.textToCopy,
    this.tooltip = 'Copy to clipboard',
    this.copiedText = 'Copied!',
    this.copiedDuration = const Duration(seconds: 2),
    this.style = RaptrAICopyButtonStyle.icon,
    this.iconSize = 18,
    this.onCopied,
  });

  @override
  State<RaptrAICopyButton> createState() => _RaptrAICopyButtonState();
}

class _RaptrAICopyButtonState extends State<RaptrAICopyButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));

    setState(() => _copied = true);
    widget.onCopied?.call();

    await Future<void>.delayed(widget.copiedDuration);

    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = _copied
        ? RaptrAIColors.success
        : (isDark
            ? RaptrAIColors.darkTextSecondary
            : RaptrAIColors.lightTextSecondary);

    switch (widget.style) {
      case RaptrAICopyButtonStyle.icon:
        return Tooltip(
          message: _copied ? widget.copiedText : widget.tooltip,
          child: IconButton(
            onPressed: _handleCopy,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(_copied),
                size: widget.iconSize,
                color: iconColor,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
        );

      case RaptrAICopyButtonStyle.text:
        return TextButton.icon(
          onPressed: _handleCopy,
          icon: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            size: widget.iconSize,
            color: iconColor,
          ),
          label: Text(
            _copied ? widget.copiedText : 'Copy',
            style: TextStyle(color: iconColor),
          ),
        );

      case RaptrAICopyButtonStyle.outlined:
        return OutlinedButton.icon(
          onPressed: _handleCopy,
          icon: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            size: widget.iconSize,
          ),
          label: Text(_copied ? widget.copiedText : 'Copy'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _copied ? RaptrAIColors.success : null,
            side: BorderSide(
              color: _copied
                  ? RaptrAIColors.success
                  : (isDark
                      ? RaptrAIColors.darkBorder
                      : RaptrAIColors.lightBorder),
            ),
          ),
        );

      case RaptrAICopyButtonStyle.filled:
        return FilledButton.icon(
          onPressed: _handleCopy,
          icon: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            size: widget.iconSize,
          ),
          label: Text(_copied ? widget.copiedText : 'Copy'),
          style: FilledButton.styleFrom(
            backgroundColor: _copied ? RaptrAIColors.success : RaptrAIColors.accent,
          ),
        );
    }
  }
}

/// Copy button style variants.
enum RaptrAICopyButtonStyle {
  icon,
  text,
  outlined,
  filled,
}

/// A code block with copy functionality.
class RaptrAICodeBlock extends StatelessWidget {
  /// The code content.
  final String code;

  /// Optional language label.
  final String? language;

  /// Whether to show line numbers.
  final bool showLineNumbers;

  /// Background color.
  final Color? backgroundColor;

  /// Text style for code.
  final TextStyle? codeStyle;

  const RaptrAICodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showLineNumbers = false,
    this.backgroundColor,
    this.codeStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? RaptrAIColors.slate900 : RaptrAIColors.slate100);
    final textColor = isDark ? RaptrAIColors.slate100 : RaptrAIColors.slate800;
    final lineNumberColor =
        isDark ? RaptrAIColors.slate600 : RaptrAIColors.slate400;

    final lines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? RaptrAIColors.slate800
                  : RaptrAIColors.slate200,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                if (language != null)
                  Text(
                    language!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? RaptrAIColors.darkTextSecondary
                          : RaptrAIColors.lightTextSecondary,
                    ),
                  ),
                const Spacer(),
                RaptrAICopyButton(
                  textToCopy: code,
                  iconSize: 16,
                ),
              ],
            ),
          ),
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLineNumbers) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      lines.length,
                      (i) => Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: lineNumberColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines
                      .map((line) => Text(
                            line.isEmpty ? ' ' : line,
                            style: codeStyle ??
                                TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: textColor,
                                  height: 1.5,
                                ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
