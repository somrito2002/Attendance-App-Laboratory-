import 'package:flutter/material.dart';

// ── Brand palette ────────────────────────────────────────────────────────────
const Color brandTeal900 = Color(0xFF003D3B);
const Color brandTeal800 = Color(0xFF005552);
const Color brandTeal700 = Color(0xFF006E6A);
const Color brandTeal600 = Color(0xFF008682);
const Color brandTeal400 = Color(0xFF00BDB7);
const Color brandTeal200 = Color(0xFF80DED9);

const Color accentAmber     = Color(0xFFFFC107);
const Color accentAmberDark = Color(0xFFE65100);

const Color neutralGray900 = Color(0xFF1A1A1A);
const Color neutralGray800 = Color(0xFF2C2C2C);
const Color neutralGray300 = Color(0xFFBDBDBD);
const Color neutralGray100 = Color(0xFFF5F5F5);

const Color surfaceLight = Color(0xFFF0FAFA);
const Color errorRed     = Color(0xFFB00020);

// ── Material 3 colour scheme ──────────────────────────────────────────────────
ColorScheme get appColorScheme => ColorScheme.light(
  primary:                  brandTeal700,
  onPrimary:                Colors.white,
  primaryContainer:         brandTeal200,
  onPrimaryContainer:       brandTeal900,
  secondary:                accentAmber,
  onSecondary:              neutralGray900,
  secondaryContainer:       const Color(0xFFFFE082),
  onSecondaryContainer:     const Color(0xFF3E2900),
  surface:                  Colors.white,
  onSurface:                neutralGray900,
  surfaceContainerHighest:  const Color(0xFFDAF4F3),
  onSurfaceVariant:         brandTeal900,
  error:                    errorRed,
  onError:                  Colors.white,
);

// ── App themes ─────────────────────────────────────────────────────────────────
ThemeData get appTheme => ThemeData(
  useMaterial3:  true,
  brightness: Brightness.light,
  colorScheme:   appColorScheme,
  scaffoldBackgroundColor: surfaceLight,
  fontFamily:    'Roboto',
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brandTeal800,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

// ── Dark Material 3 colour scheme ─────────────────────────────────────────────
ColorScheme get appDarkColorScheme => ColorScheme.dark(
  primary:                  brandTeal400,
  onPrimary:                neutralGray900,
  primaryContainer:         brandTeal800,
  onPrimaryContainer:       Colors.white,
  secondary:                accentAmber,
  onSecondary:              neutralGray900,
  secondaryContainer:       accentAmberDark,
  onSecondaryContainer:     Colors.white,
  surface:                  neutralGray900,
  onSurface:                neutralGray100,
  surfaceContainerHighest:  neutralGray800,
  onSurfaceVariant:         neutralGray300,
  error:                    const Color(0xFFCF6679),
  onError:                  neutralGray900,
);

ThemeData get appDarkTheme => ThemeData(
  useMaterial3:  true,
  brightness: Brightness.dark,
  colorScheme:   appDarkColorScheme,
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily:    'Roboto',
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: neutralGray800,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brandTeal400,
      foregroundColor: neutralGray900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);
