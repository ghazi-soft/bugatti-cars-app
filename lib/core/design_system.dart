import 'package:flutter/material.dart';

// Color Palette
class AppColors {
  static const Color primary = Color(0xFFD4AF37); // Gold
  static const Color dark = Color(0xFF0F172A); // Deep Black
  static const Color background = Color(0xFF111827); // Dark Background
  static const Color surface = Color(0xFF1F2937); // Dark Gray for Cards/Surfaces
  static const Color accent = Color(0xFFF59E0B); // Orange Gold for highlights

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color borderLight = Color(0xFF374151);
  static const Color borderDark = Color(0xFF1F2937);
}

// Typography
class AppTextStyles {
  static const String arabicFontFamily = 'Cairo'; // Assuming Cairo is available or will be added
  static const String englishFontFamily = 'Poppins'; // Poppins is already in pubspec.yaml

  static TextStyle displayLarge = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle displayMedium = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle displaySmall = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle headlineMedium = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle headlineSmall = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle titleLarge = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static TextStyle bodyLarge = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 16,
    color: AppColors.textSecondary,
  );
  static TextStyle bodyMedium = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  static TextStyle bodySmall = TextStyle(
    fontFamily: englishFontFamily,
    fontSize: 12,
    color: AppColors.textTertiary,
  );
}

// App Theme Data
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      canvasColor: AppColors.background, // For bottom navigation bar, etc.
      dialogBackgroundColor: AppColors.surface,
      dividerColor: AppColors.borderLight,
      splashColor: AppColors.primary.withOpacity(0.2),
      highlightColor: AppColors.primary.withOpacity(0.1),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.dark), // For button text
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.dark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.dark),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.dark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        elevation: 16,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),

      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Add more theme properties as needed
    );
  }
}
