import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors (moyasser-inspired teal) ───
  static const Color primaryColor = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14A3A8);
  static const Color primaryDark = Color(0xFF095456);
  static const Color secondaryColor = Color(0xFFF5A623);
  static const Color secondaryLight = Color(0xFFFFCD69);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentRed = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFFF9800);

  // ─── Social Colors ───
  static const Color whatsappBrand = Color(0xFF25D366);
  static const Color telegramBrand = Color(0xFF0088CC);

  // ─── Neutral Colors ───
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE8ECF0);
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF6B7685);
  static const Color textHint = Color(0xFF9CA5AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Dark Theme Colors ───
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1C2128);
  static const Color darkCard = Color(0xFF242B33);
  static const Color darkTextPrimary = Color(0xFFE8ECF0);
  static const Color darkTextSecondary = Color(0xFF8B95A1);
  static const Color darkDivider = Color(0xFF303840);
  static const Color darkHint = Color(0xFF6B7685);

  // ─── Tier Colors ───
  static const Color tier200 = Color(0xFF10B981);
  static const Color tier300 = Color(0xFF0EA5E9);
  static const Color tier500 = Color(0xFFF59E0B);
  static const Color tier1000 = Color(0xFFEF4444);
  static const Color tier2000 = Color(0xFF8B5CF6);

  // ─── Shimmer ───
  static const Color shimmerBaseLight = Color(0xFFD4E8E8);
  static const Color shimmerHighlightLight = Color(0xFFEAF5F5);
  static const Color shimmerBaseDark = Color(0xFF1A2D2E);
  static const Color shimmerHighlightDark = Color(0xFF284041);

  // ─── Border Radius ───
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // ─── Spacing ───
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ─── Animation Durations ───
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ─── Adaptive Colors ───
  static Color adaptiveTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  static Color adaptiveTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;

  static Color adaptiveTextHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkHint : textHint;

  static Color adaptiveBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : backgroundLight;

  static Color adaptiveCardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : cardColor;

  static Color adaptiveSurfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surfaceColor;

  static Color adaptiveDivider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkDivider : dividerColor;

  static List<BoxShadow>? adaptiveShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return null;
    return softShadow;
  }

  static List<BoxShadow>? adaptiveMediumShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return null;
    return mediumShadow;
  }

  static BoxBorder? adaptiveBorder(BuildContext context, {double alpha = 0.5}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return null;
    return Border.all(color: darkDivider.withValues(alpha: alpha));
  }

  static Color adaptiveDisabled(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF4A5568) : const Color(0xFFBDBDBD);

  static BoxDecoration adaptiveCardDecoration(BuildContext context, {double? borderRadius, BoxShadow? customShadow, BoxBorder? customBorder, Color? customColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: customColor ?? adaptiveCardColor(context),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusLg),
      boxShadow: customShadow != null ? [customShadow] : (isDark ? null : softShadow),
      border: customBorder ?? (isDark ? Border.all(color: darkDivider.withValues(alpha: 0.5)) : null),
    );
  }

  static List<BoxShadow> get softShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // ─── Text Styles ───
  static TextStyle get headingLarge => GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3);
  static TextStyle get headingMedium => GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);
  static TextStyle get headingSmall => GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get titleMedium => GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get bodyLarge => GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
  static TextStyle get labelMedium => GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle get buttonText => GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: textOnPrimary, height: 1.3);

  // ─── Light Theme ───
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: accentRed,
    ),
    textTheme: GoogleFonts.cairoTextTheme().apply(bodyColor: textPrimary, displayColor: textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: buttonText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: accentRed)),
      hintStyle: GoogleFonts.cairo(color: textHint, fontSize: 14),
      labelStyle: GoogleFonts.cairo(color: textSecondary, fontSize: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg))),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.cairo(color: textOnPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: backgroundLight,
      selectedColor: primaryColor.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusRound)),
      side: const BorderSide(color: dividerColor),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primaryColor : textHint),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primaryColor.withValues(alpha: 0.5) : dividerColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    ),
  );

  // ─── Dark Theme ───
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryLight,
      secondary: secondaryColor,
      surface: darkSurface,
      error: accentRed,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData(brightness: Brightness.dark).textTheme.apply(bodyColor: darkTextPrimary, displayColor: darkTextPrimary)),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: darkTextPrimary),
      iconTheme: const IconThemeData(color: darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: textOnPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: buttonText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: darkDivider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: darkDivider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: primaryLight, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd), borderSide: const BorderSide(color: accentRed)),
      hintStyle: GoogleFonts.cairo(color: darkHint, fontSize: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryLight,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: darkDivider, thickness: 1, space: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg))),
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: darkCard,
      contentTextStyle: GoogleFonts.cairo(color: darkTextPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      selectedColor: primaryLight.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusRound)),
      side: BorderSide(color: darkDivider),
    ),
  );

  // ─── Tier color helper ───
  static Color getTierColor(String tier) {
    switch (tier) {
      case '200': return tier200;
      case '300': return tier300;
      case '500': return tier500;
      case '1000': return tier1000;
      case '2000': return tier2000;
      default: return primaryColor;
    }
  }
}
