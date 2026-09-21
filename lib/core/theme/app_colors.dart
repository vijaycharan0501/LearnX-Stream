import 'package:flutter/material.dart';

/// App color palette for LearnX STREAM
/// Light, study-focused theme with soft pastel accents.
class AppColors {
  AppColors._();

  // Backgrounds & Surface
  static const Color background = Color(0xFFF9FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF4F6F9);
  static const Color cardBorder = Color(0xFFEAEFF5);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Primary Accent: Soft Teal
  static const Color tealPrimary = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFE6F7F5);
  static const Color tealBorder = Color(0xFF99F6E4);

  // Secondary Accent: Pastel Blue
  static const Color bluePrimary = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color blueBorder = Color(0xFFBFDBFE);

  // Success Accent: Pastel Green / Mint
  static const Color greenPrimary = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFECFDF5);
  static const Color greenBorder = Color(0xFFA7F3D0);

  // Warm Accent: Pastel Orange / Amber
  static const Color orangePrimary = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color orangeBorder = Color(0xFFFED7AA);

  // Coral / Red Accent for Weak Concepts / Alerts
  static const Color coralPrimary = Color(0xFFEA580C);
  static const Color coralLight = Color(0xFFFFF1EB);
  static const Color coralBorder = Color(0xFFFFD7C2);

  // Purple Accent for Deep Focus / Special representations
  static const Color purplePrimary = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color purpleBorder = Color(0xFFDDD6FE);

  // Shadows
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
