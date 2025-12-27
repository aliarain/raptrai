import 'package:flutter/material.dart';

/// RaptrAI color palette.
///
/// Uses zinc color scale for a modern, clean look.
/// Carefully crafted for optimal AI chat interfaces.
class RaptrAIColors {
  RaptrAIColors._();

  // ============================================
  // Zinc Gray Scale (Neutral Colors)
  // ============================================

  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // ============================================
  // Slate Gray Scale (Alternative neutral)
  // ============================================

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // ============================================
  // Primary Accent Colors (Blue)
  // ============================================

  static const Color accent = Color(0xFF3B82F6); // blue-500
  static const Color accentLight = Color(0xFF60A5FA); // blue-400
  static const Color accentDark = Color(0xFF2563EB); // blue-600
  static const Color accentSubtle = Color(0xFFDBEAFE); // blue-100

  // Blue scale for more granular control
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  // ============================================
  // Semantic Colors
  // ============================================

  static const Color success = Color(0xFF22C55E); // green-500
  static const Color successLight = Color(0xFFDCFCE7); // green-100
  static const Color successDark = Color(0xFF166534); // green-800
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningLight = Color(0xFFFEF3C7); // amber-100
  static const Color warningDark = Color(0xFF92400E); // amber-800
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color errorLight = Color(0xFFFEE2E2); // red-100
  static const Color errorDark = Color(0xFF991B1B); // red-800
  static const Color info = Color(0xFF3B82F6); // blue-500
  static const Color infoLight = Color(0xFFDBEAFE); // blue-100
  static const Color infoDark = Color(0xFF1E40AF); // blue-800

  // ============================================
  // Light Theme Colors (using zinc)
  // ============================================

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = zinc50;
  static const Color lightSurfaceVariant = zinc100;
  static const Color lightBorder = zinc200;
  static const Color lightText = zinc950;
  static const Color lightTextSecondary = zinc500;
  static const Color lightTextMuted = zinc400;

  // User message bubble (light)
  static const Color lightUserBubble = zinc900;
  static const Color lightUserBubbleText = zinc50;

  // Assistant message bubble (light)
  static const Color lightAssistantBubble = zinc100;
  static const Color lightAssistantBubbleText = zinc900;

  // ============================================
  // Dark Theme Colors (using zinc)
  // ============================================

  static const Color darkBackground = zinc950; // #09090B
  static const Color darkSurface = zinc900; // #18181B
  static const Color darkSurfaceVariant = zinc800; // #27272A
  static const Color darkBorder = zinc700; // #3F3F46
  static const Color darkText = zinc50; // #FAFAFA
  static const Color darkTextSecondary = zinc400; // #A1A1AA
  static const Color darkTextMuted = zinc500; // #71717A

  // User message bubble (dark)
  static const Color darkUserBubble = zinc800;
  static const Color darkUserBubbleText = zinc50;

  // Assistant message bubble (dark)
  static const Color darkAssistantBubble = Colors.transparent;
  static const Color darkAssistantBubbleText = zinc50;

  // ============================================
  // Gradient Presets
  // ============================================

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [zinc800, zinc900],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================
  // Spacing Constants
  // ============================================

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const double spacing2xl = 32;

  // ============================================
  // Border Radius Constants
  // ============================================

  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 9999;
}

/// Extension for creating custom RaptrAI color schemes.
class RaptrAIColorScheme {
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color userBubble;
  final Color userBubbleText;
  final Color assistantBubble;
  final Color assistantBubbleText;

  const RaptrAIColorScheme({
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.userBubble,
    required this.userBubbleText,
    required this.assistantBubble,
    required this.assistantBubbleText,
  });

  /// Light color scheme with default blue accent.
  factory RaptrAIColorScheme.light({Color? accent}) {
    final accentColor = accent ?? RaptrAIColors.accent;
    return RaptrAIColorScheme(
      accent: accentColor,
      accentLight: RaptrAIColors.accentLight,
      accentDark: RaptrAIColors.accentDark,
      background: RaptrAIColors.lightBackground,
      surface: RaptrAIColors.lightSurface,
      surfaceVariant: RaptrAIColors.lightSurfaceVariant,
      border: RaptrAIColors.lightBorder,
      text: RaptrAIColors.lightText,
      textSecondary: RaptrAIColors.lightTextSecondary,
      textMuted: RaptrAIColors.lightTextMuted,
      userBubble: RaptrAIColors.lightUserBubble,
      userBubbleText: RaptrAIColors.lightUserBubbleText,
      assistantBubble: RaptrAIColors.lightAssistantBubble,
      assistantBubbleText: RaptrAIColors.lightAssistantBubbleText,
    );
  }

  /// Dark color scheme with default blue accent.
  factory RaptrAIColorScheme.dark({Color? accent}) {
    final accentColor = accent ?? RaptrAIColors.accent;
    return RaptrAIColorScheme(
      accent: accentColor,
      accentLight: RaptrAIColors.accentLight,
      accentDark: RaptrAIColors.accentDark,
      background: RaptrAIColors.darkBackground,
      surface: RaptrAIColors.darkSurface,
      surfaceVariant: RaptrAIColors.darkSurfaceVariant,
      border: RaptrAIColors.darkBorder,
      text: RaptrAIColors.darkText,
      textSecondary: RaptrAIColors.darkTextSecondary,
      textMuted: RaptrAIColors.darkTextMuted,
      userBubble: RaptrAIColors.darkUserBubble,
      userBubbleText: RaptrAIColors.darkUserBubbleText,
      assistantBubble: RaptrAIColors.darkAssistantBubble,
      assistantBubbleText: RaptrAIColors.darkAssistantBubbleText,
    );
  }
}
