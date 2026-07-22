import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'taylor_colors.dart';
import 'taylor_typography.dart';

/// Radios de esquina. El lenguaje "liquid glass" pide curvas continuas y
/// generosas; nada en Taylor usa esquinas duras.
abstract final class TaylorRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 26;
  static const double xl = 34;
  static const double pill = 999;
}

abstract final class TaylorSpacing {
  static const double xs = 6;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 26;
  static const double xl = 40;

  /// Alto que ocupa la barra flotante inferior, incluido su margen.
  /// Las pantallas lo usan como padding inferior para no quedar tapadas.
  static const double navBarClearance = 108;
}

abstract final class TaylorMotion {
  /// Curva base. Suave al entrar, con un asentamiento tranquilo — nada
  /// rebota agresivamente, la marca es serena.
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  static const Duration fast = Duration(milliseconds: 220);
  static const Duration normal = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 620);
}

abstract final class TaylorTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final onSurface = isDark ? TaylorColors.white : TaylorColors.obsidian;
    final surface = isDark ? TaylorColors.canvasDark : TaylorColors.canvas;
    final textTheme = TaylorTypography.textTheme(onSurface);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: TaylorColors.raspberry,
      onPrimary: TaylorColors.white,
      primaryContainer: TaylorColors.razzmatazz,
      onPrimaryContainer: TaylorColors.white,
      secondary: TaylorColors.razzmatazz,
      onSecondary: TaylorColors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest:
          isDark ? TaylorColors.surfaceDark : TaylorColors.white,
      error: TaylorColors.emergency,
      onError: TaylorColors.white,
      outline: isDark ? const Color(0x26FFFFFF) : TaylorColors.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      fontFamily: TaylorTypography.fontFamily,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: onSurface),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TaylorColors.raspberry,
          foregroundColor: TaylorColors.white,
          disabledBackgroundColor: TaylorColors.raspberry.withValues(alpha: 0.35),
          disabledForegroundColor: TaylorColors.white.withValues(alpha: 0.8),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaylorRadius.md),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaylorRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // brandText y no raspberry: el texto de un TextButton es de tamaño
          // normal y sobre fondo claro. Ver TaylorColors.brandText.
          foregroundColor:
              isDark ? TaylorColors.raspberry : TaylorColors.brandText,
          textStyle: textTheme.labelLarge,
          // WCAG y ambas plataformas piden 48/44 dp mínimos de área táctil.
          // Los TextButton con etiquetas cortas se quedan por debajo si no se
          // fuerza aquí.
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0x14FFFFFF) : TaylorColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: textTheme.bodyLarge?.copyWith(color: TaylorColors.inkFaint),
        border: _inputBorder(scheme.outline),
        enabledBorder: _inputBorder(scheme.outline),
        focusedBorder: _inputBorder(TaylorColors.raspberry, width: 1.6),
        errorBorder: _inputBorder(TaylorColors.emergency),
        focusedErrorBorder: _inputBorder(TaylorColors.emergency, width: 1.6),
      ),

      cardTheme: CardThemeData(
        color: isDark ? TaylorColors.surfaceDark : TaylorColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaylorRadius.lg),
          side: BorderSide(color: scheme.outline),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? TaylorColors.surfaceDark : TaylorColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TaylorRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: TaylorColors.inkFaint.withValues(alpha: 0.4),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _SoftPageTransitionBuilder(),
          TargetPlatform.iOS: _SoftPageTransitionBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(TaylorRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Transición global: la pantalla entrante se desliza apenas 6% del ancho y
/// hace fade, mientras la saliente se hunde ligeramente en escala.
///
/// El desplazamiento corto es intencional — transiciones largas hacen que la
/// app se sienta lenta, y el brand book exige "rendimiento de alto nivel".
class _SoftPageTransitionBuilder extends PageTransitionsBuilder {
  const _SoftPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: TaylorMotion.emphasized,
      reverseCurve: Curves.easeInCubic,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: TaylorMotion.emphasized,
    );

    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(enter),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.96).animate(exit),
          child: child,
        ),
      ),
    );
  }
}
