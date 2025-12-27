import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A text input field designed for AI prompt entry.
///
/// Supports multiple styles, auto-expand, and submit actions.
class RaptrAIPromptInput extends StatefulWidget {
  /// Callback when the user submits the prompt.
  final ValueChanged<String>? onSubmit;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Hint text shown when empty.
  final String hintText;

  /// The style variant of the input.
  final PromptInputStyle style;

  /// Text controller for external control.
  final TextEditingController? controller;

  /// Focus node for external focus control.
  final FocusNode? focusNode;

  /// Whether the input is enabled.
  final bool enabled;

  /// Whether to auto-focus on mount.
  final bool autofocus;

  /// Maximum number of lines before scrolling.
  final int maxLines;

  /// Minimum number of lines to show.
  final int minLines;

  /// Custom send button icon.
  final IconData sendIcon;

  /// Whether to show the send button.
  final bool showSendButton;

  /// Custom prefix widget (e.g., attachment button).
  final Widget? prefix;

  /// Custom suffix widget (e.g., voice input button).
  final Widget? suffix;

  /// Border radius for the input.
  final double borderRadius;

  const RaptrAIPromptInput({
    super.key,
    this.onSubmit,
    this.onChanged,
    this.hintText = 'Type a message...',
    this.style = PromptInputStyle.rounded,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 5,
    this.minLines = 1,
    this.sendIcon = Icons.send_rounded,
    this.showSendButton = true,
    this.prefix,
    this.suffix,
    this.borderRadius = 24,
  });

  @override
  State<RaptrAIPromptInput> createState() => _RaptrAIPromptInputState();
}

class _RaptrAIPromptInputState extends State<RaptrAIPromptInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSubmit?.call(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? RaptrAIColors.darkSurfaceVariant
        : RaptrAIColors.lightSurfaceVariant;
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final hintColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;

    final inputDecoration = _buildInputDecoration(
      fillColor: fillColor,
      borderColor: borderColor,
      hintColor: hintColor,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.prefix != null) ...[
          widget.prefix!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            textInputAction: TextInputAction.send,
            keyboardType: TextInputType.multiline,
            style: TextStyle(color: textColor),
            decoration: inputDecoration,
            onSubmitted: widget.enabled ? (_) => _handleSubmit() : null,
          ),
        ),
        if (widget.suffix != null) ...[
          const SizedBox(width: 8),
          widget.suffix!,
        ],
        if (widget.showSendButton) ...[
          const SizedBox(width: 8),
          _buildSendButton(isDark),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required Color fillColor,
    required Color borderColor,
    required Color hintColor,
  }) {
    switch (widget.style) {
      case PromptInputStyle.rounded:
        return InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: hintColor),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: RaptrAIColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        );

      case PromptInputStyle.bordered:
        return InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: hintColor),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: RaptrAIColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        );

      case PromptInputStyle.minimal:
        return InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: hintColor),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        );

      case PromptInputStyle.underlined:
        return InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: hintColor),
          filled: false,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: RaptrAIColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 14,
          ),
        );
    }
  }

  Widget _buildSendButton(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _hasText && widget.enabled
            ? RaptrAIColors.accent
            : (isDark ? RaptrAIColors.slate700 : RaptrAIColors.slate300),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(widget.sendIcon, color: Colors.white, size: 20),
        onPressed: _hasText && widget.enabled ? _handleSubmit : null,
        tooltip: 'Send message',
      ),
    );
  }
}

/// Style variants for [RaptrAIPromptInput].
enum PromptInputStyle {
  /// Rounded pill-shaped input.
  rounded,

  /// Input with visible border.
  bordered,

  /// Minimal input with no decorations.
  minimal,

  /// Input with underline only.
  underlined,
}
