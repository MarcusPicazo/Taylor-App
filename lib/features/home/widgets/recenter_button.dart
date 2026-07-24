import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';

/// Botón para volver a la posición propia.
///
/// Existe porque el mapa se puede explorar libremente, y quien se aleja
/// buscando una calle necesita una forma de volver que no sea adivinar. Es el
/// contrapeso de haber dejado los gestos de desplazamiento abiertos.
class RecenterButton extends StatelessWidget {
  const RecenterButton({
    super.key,
    required this.onPressed,
    this.isLocating = false,
  });

  final VoidCallback onPressed;

  /// Mientras se obtiene la primera posición: el icono gira para indicar que
  /// el sistema está trabajando y no que el botón está roto.
  final bool isLocating;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: (isDark ? TaylorColors.surfaceDark : TaylorColors.white)
              .withValues(alpha: isDark ? 0.45 : 0.72),
          shape: CircleBorder(
            side: BorderSide(
              color: TaylorColors.white.withValues(alpha: isDark ? 0.2 : 0.8),
            ),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onPressed();
            },
            customBorder: const CircleBorder(),
            child: SizedBox(
              // 52 dp: por encima del mínimo de 48 y cómodo de alcanzar con
              // el pulgar sin mirar.
              width: 52,
              height: 52,
              child: isLocating
                  ? const Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: TaylorColors.raspberry,
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      size: 23,
                      color: TaylorColors.raspberry,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
