import 'package:flutter/material.dart';

import 'taylor_colors.dart';

/// Poppins es la tipografía primaria del brand book.
///
/// El logotipo usa un trazado geométrico redondeado (estilo Lyft); Poppins es
/// la familia geométrica que mejor lo acompaña en producto.
abstract final class TaylorTypography {
  static const String fontFamily = 'Poppins';

  /// Escala tipográfica. Títulos con tracking negativo para que se sientan
  /// densos y premium, cuerpo con tracking neutro para legibilidad.
  static TextTheme textTheme(Color onSurface) {
    final muted = onSurface.withValues(alpha: 0.62);

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.5,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: muted,
      ),
    );
  }

  /// Wordmark del logo: minúsculas siempre, muy apretado.
  static const TextStyle wordmark = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.0,
    height: 1.0,
    color: TaylorColors.white,
  );
}
