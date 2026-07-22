import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/taylor_colors.dart';
import '../theme/taylor_theme.dart';

/// Superficie de vidrio esmerilado, la primitiva del lenguaje "liquid glass".
///
/// Se compone de cuatro capas, y el orden importa:
///   1. el desenfoque del fondo,
///   2. un tinte translúcido que le da cuerpo,
///   3. un barrido diagonal de luz (el "sheen") que simula el grosor del cristal,
///   4. un borde superior claro que hace de reflejo especular.
///
/// El borde de una sola línea no basta: sin el reflejo asimétrico el resultado
/// parece plástico opaco en lugar de vidrio.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blur = 24,
    this.tintOpacity,
    this.showSheen = true,
    this.shadow = true,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double? tintOpacity;
  final bool showSheen;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius =
        borderRadius ?? BorderRadius.circular(TaylorRadius.lg);
    final tint = tintOpacity ?? (isDark ? 0.14 : 0.62);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: TaylorColors.obsidian
                      .withValues(alpha: isDark ? 0.44 : 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: (isDark ? TaylorColors.surfaceDark : TaylorColors.white)
                  .withValues(alpha: tint),
              gradient: showSheen
                  ? (isDark
                      ? TaylorColors.glassSheenDark
                      : TaylorColors.glassSheenLight)
                  : null,
              border: Border.all(
                color: TaylorColors.white.withValues(alpha: isDark ? 0.16 : 0.7),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
