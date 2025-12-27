import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// A comprehensive chat input widget with attachments and voice support.
class RaptrAIChatInput extends StatefulWidget {
  /// Callback when user sends a message.
  final ValueChanged<String>? onSend;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when attachment button is pressed.
  final VoidCallback? onAttachment;

  /// Callback when voice button is pressed.
  final VoidCallback? onVoice;

  /// Hint text for the input.
  final String hintText;

  /// External text controller.
  final TextEditingController? controller;

  /// External focus node.
  final FocusNode? focusNode;

  /// Whether the input is enabled.
  final bool enabled;

  /// Whether currently processing (shows loading state).
  final bool isLoading;

  /// Whether to show attachment button.
  final bool showAttachmentButton;

  /// Whether to show voice button.
  final bool showVoiceButton;

  /// Maximum lines before scrolling.
  final int maxLines;

  /// Border radius.
  final double borderRadius;

  const RaptrAIChatInput({
    super.key,
    this.onSend,
    this.onChanged,
    this.onAttachment,
    this.onVoice,
    this.hintText = 'Type a message...',
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.isLoading = false,
    this.showAttachmentButton = true,
    this.showVoiceButton = false,
    this.maxLines = 5,
    this.borderRadius = 24,
  });

  @override
  State<RaptrAIChatInput> createState() => _RaptrAIChatInputState();
}

class _RaptrAIChatInputState extends State<RaptrAIChatInput> {
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
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    widget.onSend?.call(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? RaptrAIColors.darkSurfaceVariant
        : RaptrAIColors.lightSurfaceVariant;
    final borderColor =
        isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightSurface,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.showAttachmentButton)
              IconButton(
                onPressed: widget.enabled ? widget.onAttachment : null,
                icon: const Icon(Icons.add_circle_outline),
                color: isDark
                    ? RaptrAIColors.darkTextSecondary
                    : RaptrAIColors.lightTextSecondary,
              ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        maxLines: widget.maxLines,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: widget.enabled ? (_) => _handleSend() : null,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: isDark
                                ? RaptrAIColors.darkTextMuted
                                : RaptrAIColors.lightTextMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (widget.showVoiceButton && !_hasText)
                      IconButton(
                        onPressed: widget.enabled ? widget.onVoice : null,
                        icon: const Icon(Icons.mic_none_rounded),
                        color: isDark
                            ? RaptrAIColors.darkTextSecondary
                            : RaptrAIColors.lightTextSecondary,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSendButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(bool isDark) {
    final canSend = _hasText && widget.enabled && !widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: canSend
            ? RaptrAIColors.accent
            : (isDark ? RaptrAIColors.slate700 : RaptrAIColors.slate300),
        shape: BoxShape.circle,
      ),
      child: widget.isLoading
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : IconButton(
              onPressed: canSend ? _handleSend : null,
              icon: const Icon(Icons.send_rounded, size: 20),
              color: Colors.white,
            ),
    );
  }
}
