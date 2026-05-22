import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color tokens ─────────────────────────────────────────────────────────────
class AppColors {
  // Brand
  static const primary = Color(0xFF5B5FEF);
  static const secondary = Color(0xFF7C80F2);
  static const accent = Color(0xFF00C2A8); // teal

  // Light surface
  static const lightBG = Color(0xFFF7F8FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE6E8EF);
  static const lightText1 = Color(0xFF1F2937);
  static const lightText2 = Color(0xFF6B7280);

  // Dark surface
  static const darkBG = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkBorder = Color(0xFF374151);
  static const darkText1 = Color(0xFFF9FAFB);
  static const darkText2 = Color(0xFF9CA3AF);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const accentGradient = LinearGradient(
    colors: [accent, Color(0xFF00D4BA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const heroGradient = LinearGradient(
    colors: [primary, Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Adaptive helpers ─────────────────────────────────────────────────────────
// Use these in widgets instead of AppColors constants for dark-mode support.
extension AppColorsContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get appBG => isDark ? AppColors.darkBG : AppColors.lightBG;
  Color get appSurface =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get appBorder => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get appText1 => isDark ? AppColors.darkText1 : AppColors.lightText1;
  Color get appText2 => isDark ? AppColors.darkText2 : AppColors.lightText2;
}

// ─── Spacing ──────────────────────────────────────────────────────────────────
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

// ─── Radii ────────────────────────────────────────────────────────────────────
class AppRadius {
  static const card = 16.0;
  static const button = 14.0;
  static const input = 12.0;
  static const chip = 20.0;
  static const badge = 8.0;
}

// ─── Shadows ──────────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> card(BuildContext context) => context.isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ]
      : [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];

  static List<BoxShadow> elevated(BuildContext context) => context.isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ]
      : [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

  // Static shadows (for const contexts / splash page, etc.)
  static const cardStatic = [
    BoxShadow(color: Color(0x125B5FEF), blurRadius: 20, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

// ─── AppTheme ─────────────────────────────────────────────────────────────────
// Legacy aliases kept for backward compatibility.
class AppTheme {
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color accent = AppColors.accent;
  static const Color background = AppColors.lightBG;
  static const Color surface = AppColors.lightSurface;
  static const Color border = AppColors.lightBorder;
  static const Color textPrimary = AppColors.lightText1;
  static const Color textSecondary = AppColors.lightText2;
  static const Color error = AppColors.error;

  static const LinearGradient primaryGradient = AppColors.primaryGradient;
  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFEEEFFC), Color(0xFFF3E8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get cardShadow => AppShadows.cardStatic;
  static List<BoxShadow> get elevatedShadow => [
    const BoxShadow(
      color: Color(0x2D5B5FEF),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const double cardRadius = AppRadius.card;
  static const double cardPadding = 20.0;
  static const double buttonRadius = AppRadius.button;
  static const double inputRadius = AppRadius.input;

  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double xxl = AppSpacing.xxl;

  // ─── Light theme ────────────────────────────────────────────────────────────
  static ThemeData light() => _build(Brightness.light);

  // ─── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBG : AppColors.lightBG;
    final surf = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderC = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text1 = isDark ? AppColors.darkText1 : AppColors.lightText1;
    final text2 = isDark ? AppColors.darkText2 : AppColors.lightText2;
    final fillC = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F8);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surf,
      onSurface: text1,
    );

    final base = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,

      textTheme: base.copyWith(
        headlineLarge: base.headlineLarge?.copyWith(
          color: text1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          color: text1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          color: text1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: base.titleLarge?.copyWith(
          color: text1,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: base.titleMedium?.copyWith(
          color: text1,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: base.titleSmall?.copyWith(
          color: text1,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.bodyLarge?.copyWith(color: text1),
        bodyMedium: base.bodyMedium?.copyWith(color: text1),
        bodySmall: base.bodySmall?.copyWith(color: text2),
        labelSmall: base.labelSmall?.copyWith(letterSpacing: 0.4, color: text2),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: surf,
        foregroundColor: text1,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: text1,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: text1),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surf,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: borderC, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          elevation: 0,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillC,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: borderC, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: text2),
        hintStyle: TextStyle(color: text2.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: text2,
        indicatorColor: AppColors.primary,
        dividerColor: borderC,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
        selectedColor: AppColors.primary.withValues(alpha: 0.18),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),

      dividerTheme: DividerThemeData(color: borderC, thickness: 1, space: 1),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: text2, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.inter(fontSize: 11, color: text2);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
