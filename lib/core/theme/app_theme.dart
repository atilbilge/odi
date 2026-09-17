import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Odi Design System ───────────────────────────────────────────────────────
// Based on system_design.md

class OdiColors {
  OdiColors._();

  // Primary — Coral gradient
  static const coral   = Color(0xFFFF6B35); // Odi Coral — energy & CTA
  static const sunset  = Color(0xFFE8481D); // Odi Sunset — pressed/active
  static const coralGradient = LinearGradient(
    colors: [coral, sunset],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary — Ocean gradient
  static const ocean   = Color(0xFF51B5BA); // Odi Ocean — AI / listening
  static const deepSea = Color(0xFF3A8094); // Odi Deep Sea — pressed
  static const oceanGradient = LinearGradient(
    colors: [ocean, deepSea],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Brand gradient (logo colours, left→right)
  static const brandGradient = LinearGradient(
    colors: [coral, ocean],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Neutrals
  static const anthracite = Color(0xFF2A2D34); // headings & body text
  static const midGrey    = Color(0xFF8A8D93); // secondary text / icons
  static const lightGrey  = Color(0xFFF4F5F7); // page background
  static const cardWhite  = Color(0xFFFFFFFF); // card / input background

  // Semantic
  static const success = Color(0xFF2ECA7F);
  static const warning = Color(0xFFFFB800);
  static const error   = Color(0xFFEF4444);

  // Divider / border
  static const border  = Color(0xFFE8E9EB);
}

class OdiTextStyles {
  OdiTextStyles._();

  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: OdiColors.anthracite,
    height: 1.2,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: OdiColors.anthracite,
    height: 1.3,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: OdiColors.anthracite,
    height: 1.3,
  );

  static TextStyle get body1 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: OdiColors.anthracite,
    height: 1.5,
  );

  static TextStyle get body2 => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: OdiColors.midGrey,
    height: 1.5,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.02 * 16,
    color: Colors.white,
  );

  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: OdiColors.midGrey,
    letterSpacing: 0.5,
  );

  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: OdiColors.midGrey,
  );
}

class OdiDecorations {
  OdiDecorations._();

  // Soft shadow — design spec: 0px 8px 24px rgba(42, 45, 52, 0.06)
  static const cardShadow = [
    BoxShadow(
      color: Color(0x0F2A2D34),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const subtleShadow = [
    BoxShadow(
      color: Color(0x082A2D34),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Card decoration
  static BoxDecoration card({double radius = 16}) => BoxDecoration(
    color: OdiColors.cardWhite,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: cardShadow,
  );

  // Input field decoration
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: OdiTextStyles.label,
        hintStyle: OdiTextStyles.caption,
        filled: true,
        fillColor: OdiColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OdiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OdiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: OdiColors.coral, width: 1.5),
        ),
        suffixIcon: suffix,
      );
}

class OdiTheme {
  OdiTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: OdiColors.lightGrey,
    primaryColor: OdiColors.coral,
    colorScheme: const ColorScheme.light(
      primary: OdiColors.coral,
      secondary: OdiColors.ocean,
      surface: OdiColors.cardWhite,
      error: OdiColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: OdiColors.anthracite,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: OdiColors.anthracite,
      displayColor: OdiColors.anthracite,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: OdiColors.cardWhite,
      foregroundColor: OdiColors.anthracite,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: OdiColors.anthracite,
      ),
      iconTheme: const IconThemeData(color: OdiColors.anthracite),
    ),
    cardTheme: CardThemeData(
      color: OdiColors.cardWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: const Color(0x0F2A2D34),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OdiColors.coral,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: OdiTextStyles.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: OdiColors.anthracite,
        side: const BorderSide(color: OdiColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OdiColors.lightGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OdiColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OdiColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: OdiColors.coral, width: 1.5),
      ),
      labelStyle: OdiTextStyles.label,
      hintStyle: OdiTextStyles.caption,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: OdiColors.cardWhite,
      selectedItemColor: OdiColors.coral,
      unselectedItemColor: OdiColors.midGrey,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: OdiColors.border,
    dividerTheme: const DividerThemeData(
      color: OdiColors.border,
      thickness: 1,
      space: 1,
    ),
  );
}
