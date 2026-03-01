import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get h1 =>
      GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold);

  static TextStyle get h2 =>
      GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle get h3 =>
      GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16, height: 1.5);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, height: 1.5);

  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12);

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get navLink =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500);
}
