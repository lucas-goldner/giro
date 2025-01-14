import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MaterialAppTheme {
  static const Color _brandBlue = Color(0xFF1D3557); // Dark blue
  static const Color _brandBeige = Color(0xFFF4F0EA); // Greyish beige
  static const Color _neutralBlack = Color(0xFF1A1A1A);
  static const Color _neutralWhite = Color(0xFFFFFFFF);

  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _brandBlue,
    onPrimary: _neutralWhite,
    secondary: Colors.blueGrey.shade600,
    onSecondary: _neutralWhite,
    error: Colors.red.shade400,
    onError: _neutralWhite,
    surface: _brandBeige,
    onSurface: _neutralBlack,
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _brandBlue,
    onPrimary: _neutralWhite,
    secondary: Colors.blueGrey.shade200,
    onSecondary: _neutralBlack,
    error: Colors.red.shade300,
    onError: _neutralBlack,
    surface: const Color(0xFF1E1E1E),
    onSurface: _neutralWhite,
  );

  static ThemeData lightThemeData = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: _lightColorScheme.surface,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      primaryColor: _lightColorScheme.primary,
    ),
  );

  static ThemeData darkThemeData = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: _darkColorScheme.surface,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
    ),
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      primaryColor: _darkColorScheme.primary,
    ),
  );
}

class CupertinoAppTheme {
  static const Color _brandBlue = Color(0xFF1D3557); // Dark blue
  static const Color _brandBeige = Color(0xFFF4F0EA); // Greyish beige
  static const Color _neutralBlack = Color(0xFF1A1A1A);
  static const Color _neutralWhite = Color(0xFFFFFFFF);

  static const Color _darkSurface = Color(0xFF1E1E1E); // Dark surface
  static const Color _lightSurface = _brandBeige;

  static const CupertinoThemeData lightCupertinoThemeData = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: _brandBlue,
    scaffoldBackgroundColor: _lightSurface,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        color: _neutralBlack,
      ),
      navTitleTextStyle: TextStyle(
        color: _neutralBlack,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      navActionTextStyle: TextStyle(
        color: _brandBlue,
        fontSize: 18,
      ),
      navLargeTitleTextStyle: TextStyle(
        color: _neutralBlack,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
    barBackgroundColor: _lightSurface,
  );

  // 4) Dark theme (Cupertino)
  static const CupertinoThemeData darkCupertinoThemeData = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: _brandBlue,
    primaryContrastingColor: _neutralWhite,
    scaffoldBackgroundColor: _darkSurface,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        color: _neutralWhite,
      ),
      navTitleTextStyle: TextStyle(
        color: _neutralWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      navActionTextStyle: TextStyle(
        color: _brandBlue,
        fontSize: 18,
      ),
      navLargeTitleTextStyle: TextStyle(
        color: _neutralWhite,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
    barBackgroundColor: _darkSurface,
  );

  static CupertinoThemeData fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkCupertinoThemeData
        : lightCupertinoThemeData;
  }
}
