import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from Stitch "Modern Lounge Obsidian" system.
class AppColors {
  static const background              = Color(0xFF141312);
  static const surface                 = Color(0xFF141312);
  static const surfaceContainerLowest  = Color(0xFF0F0E0D);
  static const surfaceContainerLow     = Color(0xFF1D1B1A);
  static const surfaceContainer        = Color(0xFF211F1E);
  static const surfaceContainerHigh    = Color(0xFF2B2A28);
  static const surfaceContainerHighest = Color(0xFF363433);
  static const onSurface               = Color(0xFFE6E1DF);
  static const onSurfaceVariant        = Color(0xFFD0C5AF);
  static const primary                 = Color(0xFFF2CA50);
  static const onPrimary               = Color(0xFF3C2F00);
  static const primaryContainer        = Color(0xFFD4AF37);
  static const onPrimaryContainer      = Color(0xFF554300);
  static const secondary               = Color(0xFFD4C78F);
  static const onSecondary             = Color(0xFF383006);
  static const secondaryContainer      = Color(0xFF4F471B);
  static const onSecondaryContainer    = Color(0xFFC2B57F);
  static const tertiary                = Color(0xFFF1C97D);
  static const onTertiary              = Color(0xFF412D00);
  static const tertiaryContainer       = Color(0xFFD3AD65);
  static const onTertiaryContainer     = Color(0xFF5B4000);
  static const error                   = Color(0xFFFFB4AB);
  static const onError                 = Color(0xFF690005);
  static const errorContainer          = Color(0xFF93000A);
  static const onErrorContainer        = Color(0xFFFFDAD6);
  static const outline                 = Color(0xFF99907C);
  static const outlineVariant          = Color(0xFF4D4635);
  static const surfaceTint             = Color(0xFFE9C349);
  static const inverseSurface          = Color(0xFFE6E1DF);
  static const inverseOnSurface        = Color(0xFF32302F);
  static const inversePrimary          = Color(0xFF735C00);

  // Extra brand accent colors
  static const vermouthRed  = Color(0xFFE05A47);
  static const mintGreen    = Color(0xFF2D6A4F);
  static const lemonYellow  = Color(0xFFF4D35E);
  static const stoneDark    = Color(0xFF1C1917);
  static const stoneMid     = Color(0xFF2E2A27);
  static const textPrimary  = Color(0xFFF5F2EB);
  static const textSecondary = Color(0xFFB5ADA0);

  // Glass effects
  static Color get glassBg       => stoneDark.withAlpha(166);  // 0.65
  static Color get glassNavBg    => stoneDark.withAlpha(191);  // 0.75
  static Color get glassBorder   => primary.withAlpha(38);     // 0.15
  static Color get whiskeySurface => primary.withAlpha(31);    // 0.12
}

class AppTheme {
  static ThemeData dark() {
    const cs = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    );

    final textTheme = _textTheme(cs);

    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: _appBarTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      chipTheme: _chipTheme(cs),
      dividerTheme: const DividerThemeData(color: AppColors.outlineVariant, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: GoogleFonts.outfit(color: AppColors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      displayLarge:  GoogleFonts.playfairDisplay(fontSize: 57, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.02),
      displayMedium: GoogleFonts.playfairDisplay(fontSize: 45, fontWeight: FontWeight.w700, color: cs.onSurface),
      displaySmall:  GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w700, color: cs.onSurface),
      headlineLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.02),
      headlineMedium:GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w500, color: cs.onSurface, height: 1.2),
      headlineSmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w500, color: cs.onSurface, height: 1.3),
      titleLarge:    GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: cs.onSurface),
      titleMedium:   GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.4),
      titleSmall:    GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface, letterSpacing: 0.1),
      bodyLarge:     GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: cs.onSurface, height: 1.6),
      bodyMedium:    GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant, height: 1.5),
      bodySmall:     GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
      labelLarge:    GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface, letterSpacing: 0.1),
      labelMedium:   GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant, letterSpacing: 0.08),
      labelSmall:    GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant, letterSpacing: 0.05),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme cs) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: cs.primary,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: cs.primary),
      actionsIconTheme: IconThemeData(color: cs.primary),
    );
  }

  static NavigationBarThemeData _navBarTheme(ColorScheme cs) {
    return NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      indicatorColor: cs.primary.withAlpha(38),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.05),
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      color: AppColors.stoneDark.withAlpha(166),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withAlpha(38), width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme cs) {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.stoneMid,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary),
      hintStyle: GoogleFonts.outfit(color: AppColors.textSecondary.withAlpha(128)),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary.withAlpha(100)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme cs) {
    return ChipThemeData(
      backgroundColor: cs.primary.withAlpha(25),
      labelStyle: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: cs.primary,
        letterSpacing: 0.08,
      ),
      shape: const StadiumBorder(),
      side: BorderSide(color: cs.primary.withAlpha(51)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
