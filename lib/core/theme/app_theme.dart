import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Material Green 600 — a smooth, mid-tone green used as the M3 seed.
  // Material's tonal-palette generator derives the full ColorScheme from it,
  // so changing only this constant re-skins the whole app.
  static const Color _seed = Color(0xFF43A047);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // AppBar painted in the primary green with white-on-green text/icons.
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        // Disable M3's surface tint so the appbar reads as solid primary,
        // not a translucent overlay over the body.
        scrolledUnderElevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
