import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'raptrai_colors.dart';

/// RaptrAI Theme configuration.
///
/// Provides pre-configured light and dark themes that match the
/// assistant-ui / shadcn design system.
class RaptrAITheme {
  RaptrAITheme._();

  /// Inter text theme for shadcn/assistant-ui style.
  static TextTheme get _interTextTheme {
    return GoogleFonts.interTextTheme();
  }

  /// Creates a light theme with optional accent color customization.
  static ThemeData light({Color? accentColor}) {
    final accent = accentColor ?? RaptrAIColors.accent;
    final textTheme = _interTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme.apply(
        bodyColor: RaptrAIColors.lightText,
        displayColor: RaptrAIColors.lightText,
      ),
      colorScheme: ColorScheme.light(
        primary: accent,
        onPrimary: Colors.white,
        secondary: RaptrAIColors.zinc600,
        onSecondary: Colors.white,
        surface: RaptrAIColors.lightSurface,
        onSurface: RaptrAIColors.lightText,
        surfaceContainerHighest: RaptrAIColors.lightSurfaceVariant,
        outline: RaptrAIColors.lightBorder,
        error: RaptrAIColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: RaptrAIColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: RaptrAIColors.lightBackground,
        foregroundColor: RaptrAIColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: RaptrAIColors.lightText,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: RaptrAIColors.lightBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          side: const BorderSide(color: RaptrAIColors.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RaptrAIColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: RaptrAIColors.lightTextMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RaptrAIColors.spacingLg,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingXl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RaptrAIColors.lightText,
          side: const BorderSide(color: RaptrAIColors.lightBorder),
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingXl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingLg,
            vertical: 10,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: RaptrAIColors.lightTextSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: RaptrAIColors.lightBorder,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: RaptrAIColors.lightSurfaceVariant,
        selectedColor: accent.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: RaptrAIColors.lightText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: RaptrAIColors.lightBackground,
        indicatorColor: accent.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Creates a dark theme with optional accent color customization.
  /// Matches assistant-ui / shadcn dark mode exactly.
  static ThemeData dark({Color? accentColor}) {
    final accent = accentColor ?? RaptrAIColors.accent;
    final textTheme = _interTextTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme.apply(
        bodyColor: RaptrAIColors.darkText,
        displayColor: RaptrAIColors.darkText,
      ),
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        secondary: RaptrAIColors.zinc400,
        onSecondary: RaptrAIColors.zinc900,
        surface: RaptrAIColors.darkSurface,
        onSurface: RaptrAIColors.darkText,
        surfaceContainerHighest: RaptrAIColors.darkSurfaceVariant,
        outline: RaptrAIColors.darkBorder,
        error: RaptrAIColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: RaptrAIColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: RaptrAIColors.darkBackground,
        foregroundColor: RaptrAIColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: RaptrAIColors.darkText,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: RaptrAIColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          side: const BorderSide(color: RaptrAIColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RaptrAIColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusLg),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: RaptrAIColors.darkTextMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RaptrAIColors.spacingLg,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingXl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RaptrAIColors.darkText,
          side: const BorderSide(color: RaptrAIColors.darkBorder),
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingXl,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaptrAIColors.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(
            horizontal: RaptrAIColors.spacingLg,
            vertical: 10,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: RaptrAIColors.darkTextSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: RaptrAIColors.darkBorder,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: RaptrAIColors.darkSurfaceVariant,
        selectedColor: accent.withValues(alpha: 0.3),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: RaptrAIColors.darkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaptrAIColors.radiusSm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: RaptrAIColors.darkSurface,
        indicatorColor: accent.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// InheritedWidget for accessing RaptrAI color scheme in the widget tree.
class RaptrAIThemeData extends InheritedWidget {
  final RaptrAIColorScheme colorScheme;

  const RaptrAIThemeData({
    super.key,
    required this.colorScheme,
    required super.child,
  });

  static RaptrAIColorScheme of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<RaptrAIThemeData>();
    if (widget != null) {
      return widget.colorScheme;
    }
    // Fall back to theme brightness
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? RaptrAIColorScheme.dark()
        : RaptrAIColorScheme.light();
  }

  @override
  bool updateShouldNotify(RaptrAIThemeData oldWidget) {
    return colorScheme != oldWidget.colorScheme;
  }
}

/// Typography constants matching assistant-ui / shadcn styles.
class RaptrAITypography {
  RaptrAITypography._();

  /// Get Inter text style with custom parameters.
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Heading large - 24px semibold
  static TextStyle headingLarge({Color? color}) {
    return inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  /// Heading medium - 18px semibold
  static TextStyle headingMedium({Color? color}) {
    return inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  /// Heading small - 16px semibold
  static TextStyle headingSmall({Color? color}) {
    return inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  /// Body - 14px regular
  static TextStyle body({Color? color}) {
    return inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  /// Body small - 13px regular
  static TextStyle bodySmall({Color? color}) {
    return inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  /// Caption - 12px regular
  static TextStyle caption({Color? color}) {
    return inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  /// Label - 14px medium
  static TextStyle label({Color? color}) {
    return inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
  }

  /// Label small - 12px medium
  static TextStyle labelSmall({Color? color}) {
    return inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
  }
}
