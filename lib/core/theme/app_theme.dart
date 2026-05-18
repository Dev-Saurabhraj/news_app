import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const orange = Color(0xFFFF6600);
  static const ink = Color(0xFF121417);
  static const charcoal = Color(0xFF181B20);
  static const mist = Color(0xFFF6F7F9);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        brightness: Brightness.light,
        surface: const Color(0xFFFFFFFF),
      ),
    );
    return _compose(
      base,
      const Color(0xFFFAFAFB),
      const Color(0xFFFFFFFF),
      const Color(0xFFE8EAEE),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        brightness: Brightness.dark,
        surface: charcoal,
      ),
    );
    return _compose(
      base,
      const Color(0xFF101215),
      const Color(0xFF181B20),
      const Color(0xFF2A2F38),
    );
  }

  static ThemeData _compose(
    ThemeData base,
    Color scaffold,
    Color surface,
    Color outline,
  ) {
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.5,
        height: 1.45,
        letterSpacing: 0,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffold,
        foregroundColor: base.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: base.colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: base.colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: base.colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: base.colorScheme.primary.withValues(alpha: 0.1),
        side: BorderSide(color: outline),
        labelStyle: textTheme.labelLarge,
      ),
      dividerTheme: DividerThemeData(color: outline),
      extensions: <ThemeExtension<dynamic>>[
        AppColors(surfaceRaised: surface, subtleBorder: outline),
      ],
    );
  }
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.surfaceRaised, required this.subtleBorder});

  final Color surfaceRaised;
  final Color subtleBorder;

  @override
  ThemeExtension<AppColors> copyWith({
    Color? surfaceRaised,
    Color? subtleBorder,
  }) {
    return AppColors(
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      subtleBorder: subtleBorder ?? this.subtleBorder,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
    );
  }
}
