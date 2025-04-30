import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

class AppTheme {
 // Ana renkler için hex değerleri
  static const int _primaryValue = 0xFFBD2A2E;
  static const int _secondaryValue = 0xFFB2BEBF;
  static const int _darkGreyValue = 0xFF3B3936;
  static const int _lightGreyValue = 0xFF889C9B;
  static const int _tealValue = 0xFF486966;

  // Primary Color (Kırmızı)
  static const MaterialColor primaryColor = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFf9e5e6),
      100: Color(0xFFf0bec0),
      200: Color(0xFFe69396),
      300: Color(0xFFdb676b),
      400: Color(0xFFd4474c),
      500: Color(_primaryValue),
      600: Color(0xFFb72529),
      700: Color(0xFFae1f23),
      800: Color(0xFFa6191d),
      900: Color(0xFF980f12),
    },
  );

  // Secondary Color (Açık Gri)
  static const MaterialColor secondaryColor = MaterialColor(
    _secondaryValue,
    <int, Color>{
      50: Color(0xFFF4F6F6),
      100: Color(0xFFE3E8E8),
      200: Color(0xFFD1D8D9),
      300: Color(0xFFBFC8C9),
      400: Color(0xFFB2BEBF),
      500: Color(_secondaryValue),
      600: Color(0xFFA5B1B2),
      700: Color(0xFF95A1A2),
      800: Color(0xFF859293),
      900: Color(0xFF677777),
    },
  );

  // Dark Grey Color (#3B3936)
  static const MaterialColor darkGreyColor = MaterialColor(
    _darkGreyValue,
    <int, Color>{
      50: Color(0xFFE8E8E7),
      100: Color(0xFFC6C5C3),
      200: Color(0xFFA0A09C),
      300: Color(0xFF7A7974),
      400: Color(0xFF5D5C57),
      500: Color(_darkGreyValue),
      600: Color(0xFF353330),
      700: Color(0xFF2D2B28),
      800: Color(0xFF262422),
      900: Color(0xFF1A1816),
    },
  );

  // Light Grey Color (#889C9B)
  static const MaterialColor lightGreyColor = MaterialColor(
    _lightGreyValue,
    <int, Color>{
      50: Color(0xFFF0F3F3),
      100: Color(0xFFD9E0E0),
      200: Color(0xFFC0CCCC),
      300: Color(0xFFA6B7B7),
      400: Color(0xFF93A7A6),
      500: Color(_lightGreyValue),
      600: Color(0xFF808F8E),
      700: Color(0xFF747F7E),
      800: Color(0xFF687070),
      900: Color(0xFF535857),
    },
  );

  // Teal Color (#486966)
  static const MaterialColor tealColor = MaterialColor(
    _tealValue,
    <int, Color>{
      50: Color(0xFFE9EDED),
      100: Color(0xFFC8D3D2),
      200: Color(0xFFA4B6B4),
      300: Color(0xFF7F9896),
      400: Color(0xFF638280),
      500: Color(_tealValue),
      600: Color(0xFF41615E),
      700: Color(0xFF385553),
      800: Color(0xFF2F4847),
      900: Color(0xFF213332),
    },
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: primaryColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.grey[50], // Çok açık gri arka plan
      useMaterial3: true, // Material 3 tasarım sistemini kullan
      
      // AppBar Teması
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Başlığı ortala
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Text Teması
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, 
          fontWeight: FontWeight.bold, 
          color: darkGreyColor,
          letterSpacing: -1.5
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkGreyColor,
          letterSpacing: -0.5
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkGreyColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, 
          color: darkGreyColor,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkGreyColor,
          letterSpacing: 0.25,
        ),
      ),

      // Elevated Button Teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(88, 48), // Minimum buton boyutu
        ),
      ),

      // Text Button Teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Outlined Button Teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration Teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
        ),
        labelStyle: const TextStyle(color: darkGreyColor),
        hintStyle: TextStyle(color: darkGreyColor.withValues()),
      ),

      // Card Teması
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Floating Action Button Teması
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar Teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkGreyColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // Divider Teması
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
        space: 24,
      ),

      // Checkbox Teması
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey[300]!;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch Teması
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey[300]!;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues();
          }
          return Colors.grey[300]!;
        }),
      ),

      // Dialog Teması
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkGreyColor,
        ),
      ),

      // Snackbar Teması
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkGreyColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
      ).copyWith(
        secondary: secondaryColor,
        error: Colors.red[700],
        surface: Colors.white,
      ),
    );
  }
  }
