import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(
    0xFF2C3E50,
  ); // Deep Blue/Charcoal - Professional & Trust
  static const Color secondary = Color(
    0xFFE67E22,
  ); // Burnt Orange - Energy & Call to Action
  static const Color accent = Color(0xFF3498DB); // Bright Blue - Highlights

  // Background Colors
  static const Color background = Color(0xFFF9F9F9); // Off-white - Easy on eyes
  static const Color surface = Colors.white; // Card backgrounds
  static const Color surfaceHighlight = Color(
    0xFFF5F6FA,
  ); // Slight contrast for sections

  // Text Colors
  static const Color textPrimary = Color(
    0xFF2D3436,
  ); // Almost black - High contrast
  static const Color textSecondary = Color(0xFF636E72); // Grey - Descriptions
  static const Color textLight = Colors.white; // Text on dark backgrounds

  // Functional Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFD63031);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color divider = Color(0xFFDFE6E9);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
