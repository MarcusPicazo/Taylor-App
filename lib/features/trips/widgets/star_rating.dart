import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';

/// Selector de estrellas.
///
/// Sin media estrella: la precisión decimal invita a deliberar y lo que se
/// busca aquí es una respuesta inmediata. Cinco objetivos grandes y un háptico
/// por toque.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 44,
  });

  /// 0 = sin calificar.
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var star = 1; star <= 5; star++)
          Semantics(
            button: true,
            label: '$star',
            selected: star <= value,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(star);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  duration: TaylorMotion.fast,
                  curve: TaylorMotion.emphasized,
                  scale: star <= value ? 1.0 : 0.88,
                  child: Icon(
                    star <= value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: size,
                    color: star <= value
                        ? TaylorColors.caution
                        : TaylorColors.inkFaint.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
