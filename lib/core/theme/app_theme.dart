import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'markflow_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final markFlowTheme = MarkFlowTheme.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: markFlowTheme.primary,
        surface: markFlowTheme.surface,
        onPrimary: Colors.white,
        onSurface: markFlowTheme.text,
      ),
      scaffoldBackgroundColor: markFlowTheme.background,
      cardColor: markFlowTheme.surface,
      dividerColor: markFlowTheme.border,
      extensions: [markFlowTheme],
      textTheme: _buildTextTheme(markFlowTheme),
    );
  }

  static ThemeData get darkTheme {
    final markFlowTheme = MarkFlowTheme.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: markFlowTheme.primary,
        surface: markFlowTheme.surface,
        onPrimary: Colors.black,
        onSurface: markFlowTheme.text,
      ),
      scaffoldBackgroundColor: markFlowTheme.background,
      cardColor: markFlowTheme.surface,
      dividerColor: markFlowTheme.border,
      extensions: [markFlowTheme],
      textTheme: _buildTextTheme(markFlowTheme),
    );
  }

  static TextTheme _buildTextTheme(MarkFlowTheme theme) {
    final baseTheme = GoogleFonts.interTextTheme();

    return baseTheme.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.3,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: theme.text,
        height: 1.4,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.text,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: theme.text,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: theme.text,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: theme.secondaryText,
        height: 1.9,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: theme.secondaryText,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: theme.tertiaryText,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.text,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: theme.tertiaryText,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: theme.ghostText,
      ),
    );
  }
}
