import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HyperfocusColors {
  // Backgrounds
  static const Color background = Color(0xFF000000); // Pure OLED Black
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceHighlight = Color(0xFF2C2C2C);

  // Quadrant Colors
  static const Color purposeful = Color(0xFF00E676); // Bright Teal/Green
  static const Color necessary = Color(0xFF2979FF); // Electric Blue
  static const Color distracting = Color(0xFFFF9100); // Warning Orange
  static const Color unnecessary = Color(0xFFFF1744); // Alert Red

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% opacity
  static const Color textTertiary = Color(0x80FFFFFF); // 50% opacity

  // Accents
  static const Color accent = purposeful;
}

class HyperfocusTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: HyperfocusColors.background,
      primaryColor: HyperfocusColors.purposeful,
      colorScheme: const ColorScheme.dark(
        primary: HyperfocusColors.purposeful,
        secondary: HyperfocusColors.necessary,
        surface: HyperfocusColors.surface,
        // background: HyperfocusColors.background, // Deprecated
        error: HyperfocusColors.unnecessary,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: HyperfocusColors.textPrimary,
        // onBackground: HyperfocusColors.textPrimary, // Deprecated
      ),
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            displayMedium:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            displaySmall:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            headlineLarge:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            headlineMedium:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            headlineSmall:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            titleLarge: GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            titleMedium:
                GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
            titleSmall: GoogleFonts.outfit(color: HyperfocusColors.textPrimary),
          )
          .apply(
            bodyColor: HyperfocusColors.textPrimary,
            displayColor: HyperfocusColors.textPrimary,
            decorationColor: HyperfocusColors.purposeful,
          ),
      /* cardTheme: CardTheme(
        color: HyperfocusColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
      ), */
      iconTheme: const IconThemeData(
        color: HyperfocusColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: HyperfocusColors.surface.withValues(alpha: 0.8),
        indicatorColor: HyperfocusColors.purposeful.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
