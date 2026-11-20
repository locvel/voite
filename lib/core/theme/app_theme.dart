import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color orange = Color(0xFFF59A23);
  static const Color orangePressed = Color(0xFFDE8412);
  static const Color recordRed = Color(0xFFD93025);
  static const Color darkBackground = Color(0xFF0A0A0B);
  static const Color lightBackground = Color(0xFFFFF9EF);
  static const Color darkSurface = Color(0xFF1C1C20);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkElevated = Color(0xFF26262B);
  static const Color lightElevated = Color(0xFFFDF3E0);
  static const Color darkBorder = Color(0xFF2C2C31);
  static const Color lightBorder = Color(0xFFEADFCB);
  static const Color darkText = Color(0xFFF7F2E9);
  static const Color lightText = Color(0xFF1D1912);
  static const Color darkSecondaryText = Color(0xFFA9A29B);
  static const Color lightSecondaryText = Color(0xFF6E675E);
  static const Color darkTertiaryText = Color(0xFF7A7570);
  static const Color lightTertiaryText = Color(0xFF9A938A);
  static const Color darkAccentText = Color(0xFFFBB040);
  static const Color lightAccentText = Color(0xFF9A4E00);
  static const Color darkAccentTint = Color(0xFF3A2A12);
  static const Color lightAccentTint = Color(0xFFFDEED3);
  static const Color ink = Color(0xFF1D1912);
  static const Color background = darkBackground;
  static const Color card = darkSurface;
  static const Color bodyText = darkText;
  static const Color mutedText = darkSecondaryText;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? darkBackground : lightBackground;
    final surface = isDark ? darkSurface : lightSurface;
    final elevated = isDark ? darkElevated : lightElevated;
    final border = isDark ? darkBorder : lightBorder;
    final primaryText = isDark ? darkText : lightText;
    final secondaryText = isDark ? darkSecondaryText : lightSecondaryText;
    final accentText = isDark ? darkAccentText : lightAccentText;
    final accentTint = isDark ? darkAccentTint : lightAccentTint;

    final colors = ColorScheme(
      brightness: brightness,
      primary: isDark ? orange : lightAccentText,
      onPrimary: isDark ? ink : Colors.white,
      primaryContainer: accentTint,
      onPrimaryContainer: primaryText,
      secondary: orange,
      onSecondary: ink,
      secondaryContainer: accentTint,
      onSecondaryContainer: primaryText,
      tertiary: accentText,
      onTertiary: ink,
      tertiaryContainer: elevated,
      onTertiaryContainer: primaryText,
      error: recordRed,
      onError: Colors.white,
      errorContainer: isDark
          ? const Color(0xFF3A1713)
          : const Color(0xFFFDE8E5),
      onErrorContainer: isDark
          ? const Color(0xFFFFDAD4)
          : const Color(0xFF410E0B),
      surface: surface,
      onSurface: primaryText,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: elevated,
      surfaceContainerHigh: elevated,
      surfaceContainerHighest: elevated,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
      scrim: isDark
          ? Colors.black.withValues(alpha: 0.60)
          : const Color(0xFF1D1912).withValues(alpha: 0.40),
      inverseSurface: isDark ? lightText : darkSurface,
      onInverseSurface: isDark ? lightBackground : darkText,
      inversePrimary: isDark ? lightAccentText : darkAccentText,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
    );
    final text = base.textTheme.apply(
      bodyColor: primaryText,
      displayColor: primaryText,
      fontFamily: 'Inter',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w700,
          letterSpacing: -0.45,
          color: primaryText,
        ),
      ),
      textTheme: text.copyWith(
        displayLarge: text.displayLarge?.copyWith(fontFamily: 'Sora'),
        displayMedium: text.displayMedium?.copyWith(fontFamily: 'Sora'),
        displaySmall: text.displaySmall?.copyWith(fontFamily: 'Sora'),
        headlineLarge: text.headlineLarge?.copyWith(fontFamily: 'Sora'),
        headlineMedium: text.headlineMedium?.copyWith(fontFamily: 'Sora'),
        headlineSmall: text.headlineSmall?.copyWith(fontFamily: 'Sora'),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: accentTint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            color: selected ? accentText : secondaryText,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: elevated,
        contentTextStyle: text.bodyMedium?.copyWith(color: primaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: orange, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: orange,
        foregroundColor: ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          backgroundColor: orange,
          foregroundColor: ink,
          disabledBackgroundColor: orange.withValues(alpha: 0.45),
          disabledForegroundColor: ink.withValues(alpha: 0.70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          foregroundColor: primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: border),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? ink : secondaryText,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? orange : border,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: accentText,
        textColor: primaryText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: orange,
        linearTrackColor: border,
      ),
      splashColor: orange.withValues(alpha: 0.08),
      highlightColor: orange.withValues(alpha: 0.04),
    );
  }
}
