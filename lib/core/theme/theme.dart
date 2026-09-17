import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color yemeksepetiPink = Color(0xFFEA004B);
  static const Color darkPink = Color(0xFFC4003E);
  static const Color lightPink = Color(0xFFFDE6ED);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: yemeksepetiPink,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: yemeksepetiPink,
        secondary: darkPink,
        surface: lightPink,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: yemeksepetiPink,
        foregroundColor: Colors.white,
      ),
    );
  }
}
