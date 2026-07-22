import 'package:flutter/material.dart';

import '../theme/taylor_colors.dart';
import '../theme/taylor_typography.dart';

/// El wordmark "taylor".
///
/// Siempre en minúsculas y con tracking muy cerrado, siguiendo el logo del
/// brand book. El brand book exige un área de respiro alrededor del logo, así
/// que el widget la reserva por sí mismo: quien lo use no tiene que recordarlo.
class TaylorLogo extends StatelessWidget {
  const TaylorLogo({
    super.key,
    this.size = 44,
    this.color,
    this.includeClearSpace = true,
  });

  final double size;
  final Color? color;
  final bool includeClearSpace;

  @override
  Widget build(BuildContext context) {
    final resolved = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? TaylorColors.white
            : TaylorColors.obsidian);

    // El brand book define el área de respiro como ~0.28x la altura del logo.
    final clearSpace = includeClearSpace ? size * 0.28 : 0.0;

    return Padding(
      padding: EdgeInsets.all(clearSpace),
      child: Text(
        'taylor',
        style: TaylorTypography.wordmark.copyWith(
          fontSize: size,
          color: resolved,
          letterSpacing: -size * 0.045,
        ),
      ),
    );
  }
}

/// Marca reducida a la inicial, para avatares, el app icon y espacios chicos.
class TaylorMark extends StatelessWidget {
  const TaylorMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: TaylorColors.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        't',
        style: TaylorTypography.wordmark.copyWith(
          fontSize: size * 0.62,
          color: TaylorColors.white,
        ),
      ),
    );
  }
}
