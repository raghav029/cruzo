import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'dls/typography.dart';
import 'dls/radii.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Color(0xFF0D2421),
      secondary: AppColors.accent,
      onSecondary: Color(0xFF0D2421),
      surface: AppColors.darkBg2,
      onSurface: AppColors.darkFg0,
      error: AppColors.error,
      onError: AppColors.darkBg0,
      outline: AppColors.darkLine,
      surfaceContainerHighest: AppColors.darkBg3,
    ),
    scaffoldBackgroundColor: AppColors.darkBg1,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg1,
      foregroundColor: AppColors.darkFg0,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.darkBg2,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
        side: BorderSide(color: AppColors.darkLine),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkLine,
      space: 1,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.darkLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.darkLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.darkFg3, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF0D2421),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: AppTypography.label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkFg1,
        side: const BorderSide(color: AppColors.darkLine),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.darkFg2, size: 18),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.darkFg2,
        highlightColor: AppColors.darkBg3,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.darkBg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.darkLine),
      ),
      elevation: 12,
      textStyle: const TextStyle(fontSize: 13, color: AppColors.darkFg1),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkBg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: const BorderSide(color: AppColors.darkLineStrong),
      ),
      elevation: 24,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkBg3,
      contentTextStyle: const TextStyle(color: AppColors.darkFg0, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.transparent,
      ),
      side: const BorderSide(color: AppColors.darkLine, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.darkBg3),
      trackColor: WidgetStateProperty.all(AppColors.transparent),
      radius: const Radius.circular(AppRadii.sm),
      thickness: WidgetStateProperty.all(6),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkFg0,
      unselectedLabelColor: AppColors.darkFg3,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
      ),
      dividerColor: AppColors.darkLine,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkBg3,
      selectedColor: AppColors.accentBg,
      labelStyle: AppTypography.body.copyWith(color: AppColors.darkFg1),
      side: const BorderSide(color: AppColors.darkLine),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  );

  // Keep `light` as alias so existing callsites compile.
  static ThemeData get light => dark;
}
