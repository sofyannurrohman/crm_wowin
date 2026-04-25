import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Premium Emerald Green)
  static const Color primary = Color(0xFF004D40);
  static const Color primaryDark = Color(0xFF00332B);
  static const Color primaryLight = Color(0xFFE0F2F1);

  // Secondary / Accent
  static const Color secondary = Color(0xFF00695C);
  static const Color accent = Color(0xFF00BFA5);

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textPlaceholder = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF004D40), Color(0xFF00241F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
