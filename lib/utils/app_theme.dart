import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primaryColor = Color(0xFF42A5F5); // Blue 400
  static const Color _lightBackgroundColor = Color(0xFFE3F2FD); // Blue 50
  static const Color _lightScaffoldBackgroundColor = Color(0xFFFFFFFF); // White
  static const Color _lightAppBarColor = _primaryColor;
  static const Color _lightTextColor = Color(0xFF000000); // Black
  static const Color _lightAccentColor = Color(0xFF1E88E5); // Blue 600

  static const Color _darkBackgroundColor = Color(0xFF121212); // Dark grey
  static const Color _darkScaffoldBackgroundColor = Color(0xFF1E1E1E); // Slightly lighter dark grey
  static const Color _darkAppBarColor = Color(0xFF1F1F1F); // Darker grey for AppBar
  static const Color _darkTextColor = Color(0xFFFFFFFF); // White
  static const Color _darkAccentColor = Color(0xFF64B5F6); // Lighter blue for dark theme accent

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _lightScaffoldBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      secondary: _lightAccentColor, // Accent color
      surface: _lightBackgroundColor, // Background for cards, dialogs
      background: _lightScaffoldBackgroundColor, // Overall background
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightTextColor,
      onBackground: _lightTextColor,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      color: _lightAppBarColor,
      elevation: 4.0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.ptSans(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.ptSansTextTheme().apply(
      bodyColor: _lightTextColor,
      displayColor: _lightTextColor,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: _primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.ptSans(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _primaryColor),
      ),
      labelStyle: GoogleFonts.ptSans(color: _lightTextColor.withOpacity(0.7)),
    ),
     visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryColor, // Using same primary for consistency, but can be adjusted
    scaffoldBackgroundColor: _darkScaffoldBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor, // Or a darker shade like Colors.blue[700]
      secondary: _darkAccentColor,
      surface: _darkBackgroundColor, // Background for cards, dialogs
      background: _darkScaffoldBackgroundColor, // Overall background
      error: Colors.redAccent,
      onPrimary: Colors.black, // Text on primary color
      onSecondary: Colors.black, // Text on accent color
      onSurface: _darkTextColor,
      onBackground: _darkTextColor,
      onError: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      color: _darkAppBarColor,
      elevation: 4.0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.ptSans(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.ptSansTextTheme().apply(
      bodyColor: _darkTextColor,
      displayColor: _darkTextColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: _darkAccentColor,
      textTheme: ButtonTextTheme.primary,
      colorScheme: ColorScheme.dark(
        primary: _darkAccentColor,
        onPrimary: _darkTextColor,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkAccentColor,
      foregroundColor: _darkBackgroundColor, // Or Colors.black
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkAccentColor,
        foregroundColor: _darkBackgroundColor, // Or Colors.black
        textStyle: GoogleFonts.ptSans(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: _darkAccentColor),
      ),
      labelStyle: GoogleFonts.ptSans(color: _darkTextColor.withOpacity(0.7)),
      hintStyle: GoogleFonts.ptSans(color: _darkTextColor.withOpacity(0.5)),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
