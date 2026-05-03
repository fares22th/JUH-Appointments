import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'sizes.dart';

class JuhTheme {
  JuhTheme._();

  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: JuhColors.primary,
      onPrimary: Colors.white,
      primaryContainer: JuhColors.primarySoft,
      onPrimaryContainer: JuhColors.primaryInk,
      secondary: JuhColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: JuhColors.accentSoft,
      onSecondaryContainer: JuhColors.accentInk,
      tertiary: JuhColors.success,
      onTertiary: Colors.white,
      error: JuhColors.error,
      onError: Colors.white,
      errorContainer: JuhColors.errorSoft,
      onErrorContainer: JuhColors.error,
      surface: isDark ? JuhColors.surfaceDark : JuhColors.surface,
      onSurface: isDark ? JuhColors.textPrimaryDark : JuhColors.textPrimary,
      surfaceContainerHighest: isDark ? JuhColors.borderDark : JuhColors.border,
      onSurfaceVariant: isDark ? JuhColors.textSecondaryDark : JuhColors.textSecondary,
      outline: isDark ? JuhColors.borderDark : JuhColors.border,
      outlineVariant: isDark ? const Color(0xFF193344) : const Color(0xFFEBF3F6),
      scrim: Colors.black54,
      inverseSurface: isDark ? JuhColors.surface : JuhColors.surfaceDark,
      onInverseSurface: isDark ? JuhColors.textPrimary : JuhColors.textPrimaryDark,
      inversePrimary: JuhColors.primarySoft,
    );

    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? JuhColors.bgDark : JuhColors.bg,
      textTheme: _textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? JuhColors.surfaceDark : JuhColors.surface,
        foregroundColor: isDark ? JuhColors.textPrimaryDark : JuhColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: JuhSizes.fontMd,
          fontWeight: FontWeight.w600,
          color: isDark ? JuhColors.textPrimaryDark : JuhColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? JuhColors.surfaceDark : JuhColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          side: BorderSide(
            color: isDark ? JuhColors.borderDark : JuhColors.border,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JuhColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, JuhSizes.btnHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: JuhSizes.fontBase,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JuhColors.primary,
          minimumSize: const Size(double.infinity, JuhSizes.btnHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JuhSizes.radiusLg),
          ),
          side: const BorderSide(color: JuhColors.primary),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: JuhSizes.fontBase,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JuhColors.primary,
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: JuhSizes.fontSm,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? JuhColors.borderDark.withValues(alpha: 0.4) : JuhColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
          borderSide: BorderSide(
            color: isDark ? JuhColors.borderDark : JuhColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
          borderSide: BorderSide(
            color: isDark ? JuhColors.borderDark : JuhColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(JuhSizes.radiusMd),
          borderSide: const BorderSide(color: JuhColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: JuhSizes.md,
          vertical: JuhSizes.sm + 4,
        ),
        hintStyle: TextStyle(
          color: isDark ? JuhColors.textSecondaryDark : JuhColors.textMuted,
          fontSize: JuhSizes.fontBase,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? JuhColors.borderDark : JuhColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? JuhColors.surfaceDark : JuhColors.surface,
        selectedItemColor: JuhColors.primary,
        unselectedItemColor: isDark ? JuhColors.textSecondaryDark : JuhColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? JuhColors.borderDark : JuhColors.primarySoft,
        selectedColor: JuhColors.primary,
        labelStyle: GoogleFonts.ibmPlexSansArabic(fontSize: JuhSizes.fontSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JuhSizes.radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: JuhSizes.sm, vertical: 2),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    final font = (String text, double size, FontWeight w) =>
        GoogleFonts.ibmPlexSansArabic(
          textStyle: TextStyle(
            fontSize: size,
            fontWeight: w,
            color: cs.onSurface,
          ),
        );

    return TextTheme(
      displayLarge: font('', JuhSizes.fontXxl, FontWeight.w700),
      displayMedium: font('', JuhSizes.fontXl, FontWeight.w700),
      displaySmall: font('', JuhSizes.fontLg, FontWeight.w700),
      headlineLarge: font('', JuhSizes.fontXl, FontWeight.w600),
      headlineMedium: font('', JuhSizes.fontLg, FontWeight.w600),
      headlineSmall: font('', JuhSizes.fontMd, FontWeight.w600),
      titleLarge: font('', JuhSizes.fontMd, FontWeight.w600),
      titleMedium: font('', JuhSizes.fontBase, FontWeight.w600),
      titleSmall: font('', JuhSizes.fontSm, FontWeight.w600),
      bodyLarge: font('', JuhSizes.fontBase, FontWeight.w400),
      bodyMedium: font('', JuhSizes.fontSm, FontWeight.w400),
      bodySmall: font('', JuhSizes.fontXs, FontWeight.w400),
      labelLarge: font('', JuhSizes.fontBase, FontWeight.w500),
      labelMedium: font('', JuhSizes.fontSm, FontWeight.w500),
      labelSmall: font('', JuhSizes.fontXs, FontWeight.w500),
    );
  }
}
