import 'package:flutter/material.dart';

import '../theme/raptrai_colors.dart';

/// Displays suggested prompts as interactive chips or cards.
///
/// Used for quick-start suggestions in AI chat interfaces.
class RaptrAIPromptSuggestions extends StatelessWidget {
  /// List of suggestion texts to display.
  final List<String> suggestions;

  /// Callback when a suggestion is tapped.
  final ValueChanged<String>? onSuggestionTap;

  /// The style of the suggestions.
  final PromptSuggestionsStyle style;

  /// Optional title above the suggestions.
  final String? title;

  /// Optional icon for each suggestion.
  final IconData? suggestionIcon;

  /// Spacing between suggestions.
  final double spacing;

  /// Whether to wrap suggestions or scroll horizontally.
  final bool wrap;

  const RaptrAIPromptSuggestions({
    super.key,
    required this.suggestions,
    this.onSuggestionTap,
    this.style = PromptSuggestionsStyle.chips,
    this.title,
    this.suggestionIcon,
    this.spacing = 8,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? RaptrAIColors.darkTextSecondary
                    : RaptrAIColors.lightTextSecondary,
              ),
            ),
          ),
        _buildSuggestions(context, isDark),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isDark) {
    final items = suggestions
        .map((s) => _buildSuggestionItem(context, s, isDark))
        .toList();

    if (wrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: items,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((item) => Padding(
                  padding: EdgeInsets.only(right: spacing),
                  child: item,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String suggestion,
    bool isDark,
  ) {
    switch (style) {
      case PromptSuggestionsStyle.chips:
        return ActionChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (suggestionIcon != null) ...[
                Icon(suggestionIcon, size: 16),
                const SizedBox(width: 6),
              ],
              Text(suggestion),
            ],
          ),
          onPressed: () => onSuggestionTap?.call(suggestion),
          backgroundColor: isDark
              ? RaptrAIColors.darkSurfaceVariant
              : RaptrAIColors.lightSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder,
            ),
          ),
        );

      case PromptSuggestionsStyle.cards:
        return Material(
          color: isDark
              ? RaptrAIColors.darkSurfaceVariant
              : RaptrAIColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onSuggestionTap?.call(suggestion),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (suggestionIcon != null) ...[
                    Icon(
                      suggestionIcon,
                      size: 18,
                      color: RaptrAIColors.accent,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: isDark
                            ? RaptrAIColors.darkText
                            : RaptrAIColors.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case PromptSuggestionsStyle.outlined:
        return OutlinedButton.icon(
          onPressed: () => onSuggestionTap?.call(suggestion),
          icon: suggestionIcon != null
              ? Icon(suggestionIcon, size: 16)
              : const SizedBox.shrink(),
          label: Text(suggestion),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                isDark ? RaptrAIColors.darkText : RaptrAIColors.lightText,
            side: BorderSide(
              color: isDark ? RaptrAIColors.darkBorder : RaptrAIColors.lightBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

      case PromptSuggestionsStyle.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                RaptrAIColors.accent.withValues(alpha: 0.1),
                RaptrAIColors.accentLight.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: RaptrAIColors.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSuggestionTap?.call(suggestion),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (suggestionIcon != null) ...[
                      Icon(
                        suggestionIcon,
                        size: 18,
                        color: RaptrAIColors.accent,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          color: isDark
                              ? RaptrAIColors.darkText
                              : RaptrAIColors.lightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}

/// Style variants for [RaptrAIPromptSuggestions].
enum PromptSuggestionsStyle {
  /// Compact chip-style suggestions.
  chips,

  /// Card-style suggestions with more padding.
  cards,

  /// Outlined button-style suggestions.
  outlined,

  /// Gradient background suggestions.
  gradient,
}
