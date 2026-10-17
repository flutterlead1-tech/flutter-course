import 'package:flutter/material.dart';

// Colours and shapes from the Paws & Homes design.
// (The design uses Fredoka and Nunito Sans; this app uses Poppins, which is
// already in the project, so there are no extra font files to download.)
const _primary = Color(0xFF2F5D50);
const _ink = Color(0xFF1E2A26);
const _line = Color(0xFFDCE1DD);
const _error = Color(0xFFB3261E);

ThemeData buildPawsTheme() {
  final colors = ColorScheme.fromSeed(seedColor: _primary).copyWith(
    primary: _primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE3EEE9),
    secondary: const Color(0xFFF2A65A),
    onSecondary: _ink,
    surface: Colors.white,
    onSurface: _ink,
    onSurfaceVariant: const Color(0xFF5F6B66),
    outlineVariant: _line,
    error: _error,
    errorContainer: const Color(0xFFFBE4E2),
  );

  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: const Color(0xFFF5F6F1),
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 15),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: border(_line, 1.5),
      focusedBorder: border(_primary, 2),
      errorBorder: border(_error, 2),
      focusedErrorBorder: border(_error, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        side: const BorderSide(color: _primary, width: 1.5),
        textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
