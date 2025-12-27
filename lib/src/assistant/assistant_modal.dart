import 'package:flutter/material.dart';
import 'package:raptrai/src/theme/raptrai_colors.dart';
import 'package:raptrai/src/theme/raptrai_theme.dart';

/// Floating action button to trigger the assistant modal.
///
/// Matches assistant-ui AssistantModalTrigger.
class RaptrAIAssistantModalTrigger extends StatelessWidget {
  const RaptrAIAssistantModalTrigger({
    super.key,
    this.onTap,
    this.icon = Icons.chat_bubble_outline,
    this.tooltip = 'Open chat',
    this.backgroundColor,
    this.iconColor,
  });

  /// Callback when tapped.
  final VoidCallback? onTap;

  /// Icon to display.
  final IconData icon;

  /// Tooltip text.
  final String tooltip;

  /// Background color override.
  final Color? backgroundColor;

  /// Icon color override.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? RaptrAIColors.accent;
    final fgColor = iconColor ?? Colors.white;

    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: bgColor,
      tooltip: tooltip,
      elevation: 4,
      child: Icon(icon, color: fgColor),
    );
  }
}

/// Floating chat modal component.
///
/// Matches assistant-ui AssistantModal for bottom-right floating chat.
class RaptrAIAssistantModal extends StatelessWidget {
  const RaptrAIAssistantModal({
    required this.child,
    super.key,
    this.isOpen = true,
    this.onClose,
    this.width = 400,
    this.height = 600,
    this.title = 'Chat',
    this.showHeader = true,
    this.showCloseButton = true,
  });

  /// Content of the modal (usually a Thread).
  final Widget child;

  /// Whether the modal is open.
  final bool isOpen;

  /// Callback when close is requested.
  final VoidCallback? onClose;

  /// Width of the modal.
  final double width;

  /// Height of the modal.
  final double height;

  /// Title in the header.
  final String title;

  /// Whether to show the header.
  final bool showHeader;

  /// Whether to show the close button.
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? RaptrAIColors.darkBackground : RaptrAIColors.lightBackground;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final iconColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;

    return Material(
      color: bgColor,
      elevation: 8,
      borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
        ),
        child: Column(
          children: [
            if (showHeader)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RaptrAIColors.spacingMd,
                  vertical: RaptrAIColors.spacingSm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: RaptrAITypography.headingSmall(color: textColor),
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        onPressed: onClose,
                        icon: Icon(Icons.close, color: iconColor),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: const Radius.circular(RaptrAIColors.radiusLg),
                  top: showHeader
                      ? Radius.zero
                      : const Radius.circular(RaptrAIColors.radiusLg),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Positioned wrapper for the floating modal.
class RaptrAIAssistantModalWrapper extends StatefulWidget {
  const RaptrAIAssistantModalWrapper({
    required this.modal,
    super.key,
    this.trigger,
    this.initiallyOpen = false,
    this.position = RaptrAIModalPosition.bottomRight,
    this.offset = const Offset(16, 16),
  });

  /// The modal content.
  final RaptrAIAssistantModal modal;

  /// Custom trigger widget.
  final Widget? trigger;

  /// Whether to start open.
  final bool initiallyOpen;

  /// Position of the modal.
  final RaptrAIModalPosition position;

  /// Offset from the edge.
  final Offset offset;

  @override
  State<RaptrAIAssistantModalWrapper> createState() =>
      _RaptrAIAssistantModalWrapperState();
}

class _RaptrAIAssistantModalWrapperState
    extends State<RaptrAIAssistantModalWrapper> {
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initiallyOpen;
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Modal
        if (_isOpen)
          Positioned(
            right: widget.position == RaptrAIModalPosition.bottomRight ||
                    widget.position == RaptrAIModalPosition.topRight
                ? widget.offset.dx
                : null,
            left: widget.position == RaptrAIModalPosition.bottomLeft ||
                    widget.position == RaptrAIModalPosition.topLeft
                ? widget.offset.dx
                : null,
            bottom: widget.position == RaptrAIModalPosition.bottomRight ||
                    widget.position == RaptrAIModalPosition.bottomLeft
                ? widget.offset.dy + 72 // Account for FAB
                : null,
            top: widget.position == RaptrAIModalPosition.topRight ||
                    widget.position == RaptrAIModalPosition.topLeft
                ? widget.offset.dy
                : null,
            child: RaptrAIAssistantModal(
              isOpen: _isOpen,
              onClose: _toggle,
              title: widget.modal.title,
              width: widget.modal.width,
              height: widget.modal.height,
              showHeader: widget.modal.showHeader,
              showCloseButton: widget.modal.showCloseButton,
              child: widget.modal.child,
            ),
          ),
        // Trigger FAB
        Positioned(
          right: widget.position == RaptrAIModalPosition.bottomRight ||
                  widget.position == RaptrAIModalPosition.topRight
              ? widget.offset.dx
              : null,
          left: widget.position == RaptrAIModalPosition.bottomLeft ||
                  widget.position == RaptrAIModalPosition.topLeft
              ? widget.offset.dx
              : null,
          bottom: widget.position == RaptrAIModalPosition.bottomRight ||
                  widget.position == RaptrAIModalPosition.bottomLeft
              ? widget.offset.dy
              : null,
          top: widget.position == RaptrAIModalPosition.topRight ||
                  widget.position == RaptrAIModalPosition.topLeft
              ? widget.offset.dy
              : null,
          child: widget.trigger ??
              RaptrAIAssistantModalTrigger(
                onTap: _toggle,
                icon: _isOpen ? Icons.close : Icons.chat_bubble_outline,
              ),
        ),
      ],
    );
  }
}

/// Position options for the floating modal.
enum RaptrAIModalPosition {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}

/// Model selector dropdown.
///
/// Matches assistant-ui style model picker.
class RaptrAIModelSelector extends StatelessWidget {
  const RaptrAIModelSelector({
    required this.models,
    required this.selectedModel,
    super.key,
    this.onModelSelected,
  });

  /// Available models.
  final List<RaptrAIModel> models;

  /// Currently selected model.
  final RaptrAIModel selectedModel;

  /// Callback when model is selected.
  final ValueChanged<RaptrAIModel>? onModelSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? RaptrAIColors.darkSurfaceVariant : RaptrAIColors.lightSurfaceVariant;
    final textColor = isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText;
    final borderColor = isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder;

    return PopupMenuButton<RaptrAIModel>(
      onSelected: onModelSelected,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
        side: BorderSide(color: borderColor),
      ),
      color: isDark ? RaptrAIColors.darkSurface : RaptrAIColors.lightBackground,
      itemBuilder: (context) => models.map((model) {
        return PopupMenuItem<RaptrAIModel>(
          value: model,
          child: Row(
            children: [
              if (model.icon != null) ...[
                Icon(model.icon, size: 16, color: textColor),
                const SizedBox(width: RaptrAIColors.spacingSm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: RaptrAITypography.label(color: textColor),
                    ),
                    if (model.description != null)
                      Text(
                        model.description!,
                        style: RaptrAITypography.caption(
                          color: isDark
                              ? RaptrAIColors.darkTextMuted
                              : RaptrAIColors.lightTextMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (model.id == selectedModel.id)
                Icon(
                  Icons.check,
                  size: 16,
                  color: RaptrAIColors.accent,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RaptrAIColors.spacingMd,
          vertical: RaptrAIColors.spacingSm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedModel.icon != null) ...[
              Icon(selectedModel.icon, size: 16, color: textColor),
              const SizedBox(width: RaptrAIColors.spacingSm),
            ],
            Text(
              selectedModel.name,
              style: RaptrAITypography.label(color: textColor),
            ),
            const SizedBox(width: RaptrAIColors.spacingXs),
            Icon(Icons.expand_more, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }
}

/// Model data for the selector.
class RaptrAIModel {
  const RaptrAIModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Optional description.
  final String? description;

  /// Optional icon.
  final IconData? icon;
}

/// Branch picker for navigating message versions.
///
/// Matches assistant-ui BranchPicker.
class RaptrAIBranchPicker extends StatelessWidget {
  const RaptrAIBranchPicker({
    required this.currentIndex,
    required this.totalBranches,
    super.key,
    this.onPrevious,
    this.onNext,
  });

  /// Current branch index (1-based).
  final int currentIndex;

  /// Total number of branches.
  final int totalBranches;

  /// Callback for previous branch.
  final VoidCallback? onPrevious;

  /// Callback for next branch.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (totalBranches <= 1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? RaptrAIColors.darkTextSecondary : RaptrAIColors.lightTextSecondary;
    final iconColor =
        isDark ? RaptrAIColors.darkTextMuted : RaptrAIColors.lightTextMuted;
    final disabledColor = isDark ? RaptrAIColors.zinc700 : RaptrAIColors.zinc300;

    final canGoPrevious = currentIndex > 1;
    final canGoNext = currentIndex < totalBranches;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: canGoPrevious ? onPrevious : null,
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(RaptrAIColors.spacingXs),
            child: Icon(
              Icons.chevron_left,
              size: 16,
              color: canGoPrevious ? iconColor : disabledColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: RaptrAIColors.spacingXs),
          child: Text(
            '$currentIndex / $totalBranches',
            style: RaptrAITypography.caption(color: textColor),
          ),
        ),
        InkWell(
          onTap: canGoNext ? onNext : null,
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(RaptrAIColors.spacingXs),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: canGoNext ? iconColor : disabledColor,
            ),
          ),
        ),
      ],
    );
  }
}
