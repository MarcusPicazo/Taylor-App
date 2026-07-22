import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';

/// Control de deslizar para confirmar.
///
/// Las acciones del viaje —llegué, iniciar, terminar— son irreversibles y se
/// ejecutan con el coche en marcha o recién detenido. Un botón normal se pulsa
/// sin querer con la palma o al dejar el teléfono en el soporte; un gesto de
/// arrastre no ocurre por accidente.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.color = TaylorColors.raspberry,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback onConfirmed;
  final Color color;
  final IconData icon;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double _dragX = 0;
  bool _confirmed = false;

  static const double _height = 64;
  static const double _knobInset = 4;

  /// Fracción del recorrido a partir de la cual se da por confirmado.
  static const double _threshold = 0.85;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const knobSize = _height - _knobInset * 2;
        final maxDrag = constraints.maxWidth - knobSize - _knobInset * 2;
        final progress = maxDrag <= 0 ? 0.0 : (_dragX / maxDrag).clamp(0.0, 1.0);

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              // Pista.
              Container(
                width: double.infinity,
                height: _height,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(TaylorRadius.md),
                ),
                alignment: Alignment.center,
                child: Opacity(
                  // La etiqueta se desvanece conforme avanza el pulgar, para
                  // que no quede texto ilegible bajo el control.
                  opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: widget.color,
                    ),
                  ),
                ),
              ),

              // Relleno que sigue al pulgar.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _dragX + knobSize + _knobInset * 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(TaylorRadius.md),
                  ),
                ),
              ),

              // Pulgar arrastrable.
              Positioned(
                left: _knobInset + _dragX,
                top: _knobInset,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed) return;
                    setState(() {
                      _dragX = (_dragX + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_confirmed) return;

                    if (progress >= _threshold) {
                      setState(() {
                        _confirmed = true;
                        _dragX = maxDrag;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onConfirmed();
                    } else {
                      // No llegó: vuelve al inicio en lugar de quedarse a
                      // medias, para que el estado del control sea inequívoco.
                      setState(() => _dragX = 0);
                    }
                  },
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(TaylorRadius.sm),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _confirmed ? Icons.check_rounded : widget.icon,
                      color: TaylorColors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
