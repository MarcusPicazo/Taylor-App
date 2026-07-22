import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';

/// Botón SOS con activación por presión sostenida.
///
/// Mantener presionado —en lugar de un solo toque— evita llamadas accidentales
/// desde el bolsillo, que es el riesgo real de un botón de emergencia siempre
/// visible. El anillo que se completa le dice a la usuaria cuánto falta, y
/// soltar antes de tiempo cancela sin consecuencias.
class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    required this.label,
    required this.hint,
    required this.callingLabel,
    required this.onTriggered,
  });

  final String label;
  final String hint;
  final String callingLabel;
  final Future<void> Function() onTriggered;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();

    _hold = AnimationController(
      vsync: this,
      // 1.6 s: suficiente para descartar un roce, corto para una emergencia.
      duration: const Duration(milliseconds: 1600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _fire();
      });
  }

  Future<void> _fire() async {
    if (_triggered) return;
    setState(() => _triggered = true);
    HapticFeedback.heavyImpact();
    await widget.onTriggered();
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) {
            HapticFeedback.selectionClick();
            _hold.forward();
          },
          onTapUp: (_) => _hold.reverse(),
          onTapCancel: () => _hold.reverse(),
          child: AnimatedBuilder(
            animation: _hold,
            builder: (context, child) {
              return SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: _hold.value,
                        strokeWidth: 5,
                        backgroundColor:
                            TaylorColors.emergency.withValues(alpha: 0.16),
                        valueColor: const AlwaysStoppedAnimation(
                          TaylorColors.emergency,
                        ),
                      ),
                    ),
                    Transform.scale(
                      // Se hunde levemente mientras se sostiene: refuerza que
                      // el gesto está siendo registrado.
                      scale: 1 - _hold.value * 0.06,
                      child: child,
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                color: TaylorColors.emergency,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TaylorColors.emergency.withValues(alpha: 0.4),
                    blurRadius: 34,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: TaylorColors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: TaylorSpacing.sm),
        Text(
          _triggered ? widget.callingLabel : widget.hint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: _triggered ? TaylorColors.emergency : null,
          ),
        ),
      ],
    );
  }
}
