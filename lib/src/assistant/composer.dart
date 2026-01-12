import 'package:flutter/material.dart';
import 'package:raptrai/src/providers/provider_types.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';
import 'package:raptrai/src/theme/raptrai_theme.dart';

// Re-export attachment types for convenience when importing composer
export 'package:raptrai/src/providers/provider_types.dart'
    show RaptrAIAttachment, RaptrAIAttachmentType;

/// Text input field for the composer.
///
/// RaptrAI ComposerInput with auto-resize and placeholder.
class RaptrAIComposerInput extends StatelessWidget {
  const RaptrAIComposerInput({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder = 'Send a message...',
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 5,
    this.minLines = 1,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Focus node for the input.
  final FocusNode? focusNode;

  /// Placeholder text.
  final String placeholder;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when submitted (e.g., Enter key).
  final ValueChanged<String>? onSubmitted;

  /// Maximum number of lines before scrolling.
  final int maxLines;

  /// Minimum number of lines.
  final int minLines;

  /// Whether the input is enabled.
  final bool enabled;

  /// Whether to autofocus on mount.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final hintColor = isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      autofocus: autofocus,
      style: RaptrAITypography.body(color: textColor),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: RaptrAITypography.body(color: hintColor),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }
}

/// Button to add attachments.
///
/// RaptrAI ComposerAddAttachment.
class RaptrAIComposerAddAttachment extends StatelessWidget {
  const RaptrAIComposerAddAttachment({
    super.key,
    this.onTap,
    this.icon = Icons.add,
    this.tooltip = 'Add attachment',
  });

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Icon to display.
  final IconData icon;

  /// Tooltip text.
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(RaptrAIColors.spacingSm),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Send button for the composer.
///
/// RaptrAI ComposerSend with circular style.
class RaptrAIComposerSend extends StatelessWidget {
  const RaptrAIComposerSend({
    super.key,
    this.onTap,
    this.disabled = false,
    this.icon = Icons.arrow_upward,
  });

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Whether the button is disabled.
  final bool disabled;

  /// Icon to display.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = disabled
        ? (isDark ? RaptrAIColors.zinc700 : RaptrAIColors.zinc300)
        : RaptrAIColors.accent;
    final iconColor = disabled
        ? (isDark ? RaptrAIColors.zinc500 : RaptrAIColors.zinc400)
        : Colors.white;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

/// Stop button to cancel generation.
class RaptrAIComposerStop extends StatelessWidget {
  const RaptrAIComposerStop({
    super.key,
    this.onTap,
    this.icon = Icons.stop,
  });

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Icon to display.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RaptrAIColors.error,
      borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Attachment preview area.
///
/// RaptrAI ComposerAttachments.
class RaptrAIComposerAttachments extends StatelessWidget {
  const RaptrAIComposerAttachments({
    required this.attachments,
    super.key,
    this.onRemove,
  });

  /// List of attachments to display.
  final List<RaptrAIAttachment> attachments;

  /// Callback when an attachment is removed.
  final ValueChanged<RaptrAIAttachment>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: RaptrAIColors.spacingMd,
        ),
        itemCount: attachments.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: RaptrAIColors.spacingSm),
        itemBuilder: (context, index) {
          final attachment = attachments[index];
          return _AttachmentChip(
            attachment: attachment,
            onRemove: onRemove != null ? () => onRemove!(attachment) : null,
          );
        },
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    this.onRemove,
  });

  final RaptrAIAttachment attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final subtitleColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;

    IconData icon;
    switch (attachment.type) {
      case RaptrAIAttachmentType.image:
        icon = Icons.image_outlined;
      case RaptrAIAttachmentType.document:
        icon = Icons.description_outlined;
      case RaptrAIAttachmentType.audio:
        icon = Icons.audio_file_outlined;
      case RaptrAIAttachmentType.video:
        icon = Icons.video_file_outlined;
      case RaptrAIAttachmentType.file:
        icon = Icons.insert_drive_file_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(RaptrAIColors.spacingSm),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: subtitleColor),
          const SizedBox(width: RaptrAIColors.spacingSm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name ?? 'Attachment',
                  style: RaptrAITypography.labelSmall(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attachment.size != null)
                  Text(
                    _formatFileSize(attachment.size!),
                    style: RaptrAITypography.caption(color: subtitleColor),
                  ),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: RaptrAIColors.spacingSm),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
              child: Icon(
                Icons.close,
                size: 16,
                color: subtitleColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Complete composer component.
///
/// Modern floating chat input bar with pill design.
class RaptrAIComposer extends StatefulWidget {
  const RaptrAIComposer({
    super.key,
    this.placeholder = 'Message...',
    this.onSend,
    this.onAddAttachment,
    this.onRemoveAttachment,
    this.attachments = const [],
    this.controller,
    this.focusNode,
    this.isGenerating = false,
    this.onStop,
    this.showAttachmentButton = true,
    this.autofocus = false,
  });

  /// Placeholder text for the input.
  final String placeholder;

  /// Callback when message is sent.
  final void Function(String text, List<RaptrAIAttachment> attachments)? onSend;

  /// Callback when add attachment button is tapped.
  final VoidCallback? onAddAttachment;

  /// Callback when an attachment is removed.
  final ValueChanged<RaptrAIAttachment>? onRemoveAttachment;

  /// Current attachments.
  final List<RaptrAIAttachment> attachments;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Focus node.
  final FocusNode? focusNode;

  /// Whether AI is currently generating a response.
  final bool isGenerating;

  /// Callback to stop generation.
  final VoidCallback? onStop;

  /// Whether to show the attachment button.
  final bool showAttachmentButton;

  /// Whether to autofocus the input.
  final bool autofocus;

  @override
  State<RaptrAIComposer> createState() => _RaptrAIComposerState();
}

class _RaptrAIComposerState extends State<RaptrAIComposer> {
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

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && widget.attachments.isEmpty) return;

    widget.onSend?.call(text, widget.attachments);
    _controller.clear();
    _focusNode.requestFocus();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.zinc800 : Colors.white;
    final borderColor = isDark
        ? RaptrAIColors.zinc700
        : RaptrAIColors.zinc200;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attachments preview
          if (widget.attachments.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: RaptrAIComposerAttachments(
                attachments: widget.attachments,
                onRemove: widget.onRemoveAttachment,
              ),
            ),
          ],
          // Main input row
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                if (widget.showAttachmentButton)
                  _buildIconButton(
                    context,
                    icon: Icons.add_circle_outline,
                    onTap: widget.onAddAttachment,
                    tooltip: 'Add attachment',
                  ),
                // Input field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: widget.autofocus,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? RaptrAIColors.zinc100 : RaptrAIColors.zinc900,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: isDark ? RaptrAIColors.zinc500 : RaptrAIColors.zinc400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                // Send or Stop button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isGenerating
                      ? _buildStopButton(context)
                      : _buildSendButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? RaptrAIColors.zinc400 : RaptrAIColors.zinc500;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final canSend = _hasText || widget.attachments.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: canSend ? RaptrAIColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: canSend ? _handleSend : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 20,
              color: canSend ? Colors.white : RaptrAIColors.zinc400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return Material(
      color: RaptrAIColors.zinc700,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: widget.onStop,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
