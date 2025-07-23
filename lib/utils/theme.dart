import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Islamic Color Palette
  static const Color primaryTeal = Color(0xFF1e7e34);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color emeraldGreen = Color(0xFF28a745);
  static const Color mintGreen = Color(0xFF20c997);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color lightSilver = Color(0xFFC0C0C0);
  static const Color warmWhite = Color(0xFFFFFDF7);
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1a1a1a);
  static const Color darkCard = Color(0xFF2d2d2d);
  static const Color accentGreen = Color(0xFF4ade80);
  static const Color softGold = Color(0xFFfbbf24);
  
  // Enhanced Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, emeraldGreen, mintGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGold, softGold, Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkSurface, darkCard, Color(0xFF374151)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    colors: [warmWhite, Color(0xFFF8F9FA), Color(0xFFe5e7eb)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient islamicGradient = LinearGradient(
    colors: [accentGreen, primaryTeal, emeraldGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient darkIslamicGradient = LinearGradient(
    colors: [Color(0xFF065f46), primaryTeal, Color(0xFF047857)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryTeal),
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: warmWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: primaryGold,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black87,
      ),
      textTheme: _buildTextTheme(Colors.black87),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryTeal,
        ),
        iconTheme: const IconThemeData(color: primaryTeal),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryTeal),
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: darkSurface,
      colorScheme: ColorScheme.dark(
        primary: accentGreen,
        secondary: softGold,
        tertiary: mintGreen,
        surface: darkCard,
        surfaceContainerHighest: Color(0xFF3d3d3d),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        outline: Colors.white24,
        shadow: Colors.black54,
      ),
      textTheme: _buildDarkTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: softGold,
        ),
        iconTheme: const IconThemeData(color: softGold),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 12,
        color: darkCard,
        shadowColor: accentGreen.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: accentGreen.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: accentGreen.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: softGold,
        unselectedItemColor: Colors.white54,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white12,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color baseColor) {
    return TextTheme(
      displayLarge: GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: baseColor.withValues(alpha: 0.7),
      ),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: softGold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: accentGreen,
      ),
      headlineLarge: GoogleFonts.amiri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.amiri(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: softGold,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white60,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white.withValues(alpha: 0.87),
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white60,
      ),
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int colorValue = color.toARGB32();
    final int r = (colorValue >> 16) & 0xFF, g = (colorValue >> 8) & 0xFF, b = colorValue & 0xFF;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(colorValue, swatch);
  }

  // Enhanced Custom decorations
  static BoxDecoration islamicCardDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: isDarkMode ? darkCard : Colors.white,
      border: Border.all(
        color: isDarkMode 
            ? accentGreen.withValues(alpha: 0.2) 
            : primaryTeal.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode 
              ? accentGreen.withValues(alpha: 0.15)
              : primaryTeal.withValues(alpha: 0.1),
          blurRadius: 15,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
        if (isDarkMode)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  static BoxDecoration goldCardDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: isDarkMode ? darkIslamicGradient : goldGradient,
      border: Border.all(
        color: isDarkMode 
            ? softGold.withValues(alpha: 0.3) 
            : primaryGold.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode 
              ? softGold.withValues(alpha: 0.2)
              : primaryGold.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        if (isDarkMode)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  static BoxDecoration prayerTimeCardDecoration(BuildContext context, {bool isActive = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: isDarkMode ? darkCard : Colors.white,
      border: Border.all(
        color: isActive 
            ? (isDarkMode ? accentGreen : primaryTeal)
            : (isDarkMode ? Colors.white12 : Colors.grey.shade200),
        width: isActive ? 2 : 1,
      ),
      boxShadow: [
        if (isActive)
          BoxShadow(
            color: isDarkMode 
                ? accentGreen.withValues(alpha: 0.3)
                : primaryTeal.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        BoxShadow(
          color: isDarkMode 
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration qiblaCompassDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: isDarkMode ? darkIslamicGradient : islamicGradient,
      border: Border.all(
        color: isDarkMode ? softGold : primaryGold,
        width: 3,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode 
              ? accentGreen.withValues(alpha: 0.4)
              : primaryTeal.withValues(alpha: 0.3),
          blurRadius: 25,
          offset: const Offset(0, 10),
          spreadRadius: 5,
        ),
        if (isDarkMode)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
      ],
    );
  }
}