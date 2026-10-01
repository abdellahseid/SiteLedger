import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color electricBlue = Color(0xFF2563EB); // Vibrant Electric Sapphire
  static const Color electricBlueDark = Color(0xFF1D4ED8);
  static const Color electricBlueLight = Color(0xFF3B82F6);
  static const Color cobaltAccent = Color(0xFF0284C7);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color blueGlow = Color(0x332563EB);

  // Modern Navy & Slate Palette
  static const Color navyDark = Color(0xFF0F172A); // Slate 900
  static const Color navyLight = Color(0xFF1E293B); // Slate 800
  static const Color navySubtle = Color(0xFF334155); // Slate 700
  static const Color surfaceWarm = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocus = Color(0xFF93C5FD);

  // Semantic Status Colors
  static const Color emeraldSuccess = Color(0xFF10B981); // Emerald 500
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldBg = Color(0xFFECFDF5);
  static const Color emeraldBorder = Color(0xFFA7F3D0);

  static const Color amberWarning = Color(0xFFF59E0B); // Amber 500
  static const Color amberDark = Color(0xFFD97706);
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color amberBorder = Color(0xFFFDE68A);

  static const Color redCritical = Color(0xFFEF4444); // Red 500
  static const Color redDark = Color(0xFFDC2626);
  static const Color redBg = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);

  static const Color purpleAi = Color(0xFF8B5CF6); // Gemini AI Violet
  static const Color purpleAiLight = Color(0xFFF5F3FF);
  static const Color purpleAiBorder = Color(0xFFDDD6FE);

  // Typography & Layout Canvas
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color borderDark = Color(0xFFCBD5E1);

  // Neutral Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Dark Mode Tokens
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkBorderSubtle = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = primary;

  static const LinearGradient sapphireGaze = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppShadows {
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get cardHover => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.09),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: AppColors.electricBlue.withValues(alpha: 0.35),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceWarm,
      primaryColor: AppColors.electricBlue,
      colorScheme: const ColorScheme.light(
        primary: AppColors.electricBlue,
        onPrimary: Colors.white,
        secondary: AppColors.navyDark,
        onSecondary: Colors.white,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.redCritical,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.8),
        titleLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.4),
        titleMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.2),
        bodyLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.45),
        bodyMedium: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
        bodySmall: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navyDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.navyDark,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.navyDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyDark,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.electricBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redCritical, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11.5),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 11.5),
        elevation: 10,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.electricBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricBlue,
        onPrimary: Colors.white,
        secondary: Color(0xFF38BDF8),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.redCritical,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.4),
        titleMedium: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.2),
        bodyLarge: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 15),
        bodyMedium: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13.5),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.electricBlue,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
