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
  ///
  /// Las pantallas lo usan como padding inferior para no quedar tapadas, y los
  /// paneles flotantes de Inicio se apoyan en él.
  ///
  /// Pegada al borde, la barra caía en la franja del gesto de navegación del
  /// sistema —donde los toques se disputan— y el panel de destino quedaba
  /// incómodamente bajo para el pulgar. Se separó en dos pasos, de 108 a 132 y
  /// de ahí a 156, hasta que ambos quedaron en la zona cómoda de alcance.
  static const double navBarClearance = 156;

  /// Separación entre la barra inferior y el panel que flota sobre ella.
  static const double panelGap = 10;
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

/// Transición global entre pantallas.
///
/// La entrante llega deslizándose desde la derecha mientras crece desde un 94 %
/// y aparece; la saliente se aleja hacia el fondo y se atenúa. Las dos capas se
/// mueven a la vez pero a distinta profundidad, que es lo que produce la
/// sensación de una superficie pasando sobre otra en lugar de un corte.
///
/// El desplazamiento es corto (8 % del ancho) a propósito: recorridos largos
/// hacen que la app se sienta lenta, y el brand book exige "rendimiento de alto
/// nivel". Lo que da elegancia es la curva y la profundidad, no la distancia.
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
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      // Capa saliente: retrocede un poco hacia la izquierda, como si la nueva
      // pantalla la empujara.
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.14, 0),
      ).animate(exit),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.94).animate(exit),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0.4).animate(exit),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(enter),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(enter),
              child: FadeTransition(opacity: enter, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
