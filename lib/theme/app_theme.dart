import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   static ThemeData get lightTheme => ThemeData(
//     scaffoldBackgroundColor: AppColors.bg,
//     primaryColor: AppColors.red,
//     textTheme: GoogleFonts.poppinsTextTheme(),
//     cardTheme: CardThemeData(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//     ),
//   );
// }

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primaryRed,

  colorScheme: ColorScheme.light(
    primary: AppColors.primaryRed,
    secondary: AppColors.diuGreen,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    foregroundColor: AppColors.textPrimary,
  ),

  cardTheme: CardThemeData(
    color: AppColors.card,
    elevation: 6,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
);

