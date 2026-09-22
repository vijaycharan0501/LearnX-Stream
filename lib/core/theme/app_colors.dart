import 'package:flutter/material.dart';

/// App color palette for LearnX STREAM
/// Supports both pristine Light and modern Dark themes with rich educational accents.
class AppColors {
  AppColors._();

  // Backgrounds & Surface (Light Defaults)
  static const Color background = Color(0xFFF9FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF4F6F9);
  static const Color cardBorder = Color(0xFFEAEFF5);
  static const Color divider = Color(0xFFE2E8F0);

  // Backgrounds & Surface (Dark Defaults)
  static const Color darkBackground = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF151D2A);
  static const Color darkSurfaceSecondary = Color(0xFF1C2638);
  static const Color darkCardBorder = Color(0xFF2B384E);
  static const Color darkDivider = Color(0xFF263346);

  // Text Colors (Light Defaults)
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Text Colors (Dark Defaults)
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Primary Accent: Soft Teal
  static const Color tealPrimary = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFE6F7F5);
  static const Color tealBorder = Color(0xFF99F6E4);

  static const Color darkTealLight = Color(0xFF0F3A38);
  static const Color darkTealBorder = Color(0xFF115E59);

  // Secondary Accent: Pastel Blue
  static const Color bluePrimary = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color blueBorder = Color(0xFFBFDBFE);

  static const Color darkBlueLight = Color(0xFF172554);
  static const Color darkBlueBorder = Color(0xFF1E40AF);

  // Success Accent: Pastel Green / Mint
  static const Color greenPrimary = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFECFDF5);
  static const Color greenBorder = Color(0xFFA7F3D0);

  static const Color darkGreenLight = Color(0xFF064E3B);
  static const Color darkGreenBorder = Color(0xFF047857);

  // Warm Accent: Pastel Orange / Amber
  static const Color orangePrimary = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color orangeBorder = Color(0xFFFED7AA);

  static const Color darkOrangeLight = Color(0xFF451A03);
  static const Color darkOrangeBorder = Color(0xFF78350F);

  // Coral / Red Accent for Weak Concepts / Alerts
  static const Color coralPrimary = Color(0xFFEA580C);
  static const Color coralLight = Color(0xFFFFF1EB);
  static const Color coralBorder = Color(0xFFFFD7C2);

  static const Color darkCoralLight = Color(0xFF4C1D06);
  static const Color darkCoralBorder = Color(0xFF9A3412);

  // Purple Accent for Deep Focus / Special representations
  static const Color purplePrimary = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color purpleBorder = Color(0xFFDDD6FE);

  static const Color darkPurpleLight = Color(0xFF2E1065);
  static const Color darkPurpleBorder = Color(0xFF581C87);

  // Dynamic Theme Helpers
  static Color getBackground(bool isDark) => isDark ? darkBackground : background;
  static Color getSurface(bool isDark) => isDark ? darkSurface : surface;
  static Color getSurfaceSecondary(bool isDark) => isDark ? darkSurfaceSecondary : surfaceSecondary;
  static Color getCardBorder(bool isDark) => isDark ? darkCardBorder : cardBorder;
  static Color getDivider(bool isDark) => isDark ? darkDivider : divider;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : textPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : textSecondary;
  static Color getTextMuted(bool isDark) => isDark ? darkTextMuted : textMuted;
  static Color getTealLight(bool isDark) => isDark ? darkTealLight : tealLight;
  static Color getTealBorder(bool isDark) => isDark ? darkTealBorder : tealBorder;
  static Color getBlueLight(bool isDark) => isDark ? darkBlueLight : blueLight;
  static Color getBlueBorder(bool isDark) => isDark ? darkBlueBorder : blueBorder;
  static Color getPurpleLight(bool isDark) => isDark ? darkPurpleLight : purpleLight;
  static Color getPurpleBorder(bool isDark) => isDark ? darkPurpleBorder : purpleBorder;
  static Color getGreenLight(bool isDark) => isDark ? darkGreenLight : greenLight;
  static Color getGreenBorder(bool isDark) => isDark ? darkGreenBorder : greenBorder;
  static Color getCoralLight(bool isDark) => isDark ? darkCoralLight : coralLight;
  static Color getCoralBorder(bool isDark) => isDark ? darkCoralBorder : coralBorder;
  static Color getOrangeLight(bool isDark) => isDark ? darkOrangeLight : orangeLight;
  static Color getOrangeBorder(bool isDark) => isDark ? darkOrangeBorder : orangeBorder;

  // Shadows
  static List<BoxShadow> softShadowFor(bool isDark) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.25)
              : const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardHoverShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get heroGlow => [
        BoxShadow(
          color: tealPrimary.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];
}
