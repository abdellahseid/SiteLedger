import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand colors
  static const Color navyDark = Color(0xFF0F172A); // Deep navy typography & header
  static const Color navyLight = Color(0xFF1E293B);
  static const Color surfaceWarm = Color(0xFFF8FAFC); // Warm-gray surface
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE2E8F0);
  
  // Accents
  static const Color electricBlue = Color(0xFF2563EB); // Electric blue primary
  static const Color blueLight = Color(0xFFEFF6FF);
  
  // Semantic status colors
  static const Color emeraldSuccess = Color(0xFF059669); // Emerald completed
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color amberWarning = Color(0xFFD97706); // Amber pending
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color redCritical = Color(0xFFDC2626); // Red errors & damage
  static const Color redBg = Color(0xFFFEF2F2);
  
  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Dark Mode Tokens
  static const Color darkBg = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF151E32);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceWarm,
      primaryColor: AppColors.electricBlue,
      colorScheme: ColorScheme.light(
        primary: AppColors.electricBlue,
        onPrimary: Colors.white,
        secondary: AppColors.navyDark,
        onSecondary: Colors.white,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.redCritical,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
        bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navyDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.navyDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.navyDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          minimumSize: Size(0, 48),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyDark,
          minimumSize: Size(0, 48),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.electricBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.redCritical),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.electricBlue,
      colorScheme: ColorScheme.dark(
        primary: AppColors.electricBlue,
        onPrimary: Colors.white,
        secondary: Color(0xFF38BDF8),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.redCritical,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13.5),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
