import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryLight = Color(0xFF8D552D);
  static const secondaryLight = Color(0xFF6F4E37);
  static const tertiaryLight = Color(0xFFD4A574);

  static const primaryDark = Color(0xFFFBBC6B);
  static const secondaryDark = Color(0xFFE0C290);
  static const tertiaryDark = Color(0xFF6F4E37);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFDBC9),
      onPrimaryContainer: Color(0xFF3A0D00),
      secondary: secondaryLight,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFF1DFD4),
      onSecondaryContainer: Color(0xFF231915),
      tertiary: tertiaryLight,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFDBC9),
      onTertiaryContainer: Color(0xFF3A0D00),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFFF8F6),
      onSurface: Color(0xFF231915),
      onSurfaceVariant: Color(0xFF52443D),
      outline: Color(0xFF84746B),
      outlineVariant: Color(0xFFD7C3BA),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF392E29),
      inversePrimary: Color(0xFFFFB595),
      surfaceDim: Color(0xFFEAE1DC),
      surfaceBright: Color(0xFFFFF8F6),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFFF1ED),
      surfaceContainer: Color(0xFFF7EAE4),
      surfaceContainerHigh: Color(0xFFF1E5DF),
      surfaceContainerHighest: Color(0xFFEBDFDA),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: Color(0xFF231915),
      displayColor: Color(0xFF231915),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      foregroundColor: Color(0xFF231915),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: false,
      labelStyle: TextStyle(color: Color(0xFF231915)),
      hintStyle: TextStyle(color: Color(0xFF888888)),
      fillColor: Color(0xFFF5F5F5),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF562700),
      primaryContainer: Color(0xFF703C17),
      onPrimaryContainer: Color(0xFFFFDBC9),
      secondary: secondaryDark,
      onSecondary: Color(0xFF392E29),
      secondaryContainer: Color(0xFF52443D),
      onSecondaryContainer: Color(0xFFF1DFD4),
      tertiary: tertiaryDark,
      onTertiary: Color(0xFFFFB595),
      tertiaryContainer: Color(0xFF8D552D),
      onTertiaryContainer: Color(0xFFFFDBC9),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF1A110F),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFE0E0E0),
      outline: Color(0xFF9F8E85),
      outlineVariant: Color(0xFF52443D),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFEBDFDA),
      inversePrimary: Color(0xFF8D552D),
      surfaceDim: Color(0xFF1A110F),
      surfaceBright: Color(0xFF423731),
      surfaceContainerLowest: Color(0xFF140C0A),
      surfaceContainerLow: Color(0xFF231915),
      surfaceContainer: Color(0xFF271D19),
      surfaceContainerHigh: Color(0xFF322823),
      surfaceContainerHighest: Color(0xFF3D322D),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: Color(0xFFFFFFFF),
      displayColor: Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      foregroundColor: Color(0xFFFFFFFF),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: false,
      labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
      hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
      fillColor: Color(0xFF2A2A2A),
    ),
  );
}
