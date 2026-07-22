import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'step_scaffold.dart';

/// Reconocimiento facial con prueba de vida.
///
/// Pedir que gire la cabeza no es adorno: una foto impresa o una pantalla no
/// pueden responder al gesto, así que el giro es lo que distingue a una persona
/// presente de una suplantación. Después el rostro se compara contra la foto
/// del documento capturado en el paso anterior.
class FaceMatchStep extends StatefulWidget {
  const FaceMatchStep({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<FaceMatchStep> createState() => _FaceMatchStepState();
}

enum _FacePhase { idle, centering, turning, holding, matching, matched }

class _FaceMatchStepState extends State<FaceMatchStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring;
  _FacePhase _phase = _FacePhase.idle;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  Future<void> _runScan() async {
    // Aquí va la captura real con `camera` + google_mlkit_face_detection.
    // Ver README.md → "Integrar verificación de identidad".
    const beats = [
      (_FacePhase.centering, 1200),
      (_FacePhase.turning, 1600),
      (_FacePhase.holding, 900),
      (_FacePhase.matching, 1600),
      (_FacePhase.matched, 0),
    ];

    for (final (phase, ms) in beats) {
      if (!mounted) return;
      setState(() => _phase = phase);
      if (ms > 0) {
        await Future<void>.delayed(Duration(milliseconds: ms));
      }
    }
  }

  String _phaseLabel(L10n l10n) => switch (_phase) {
        _FacePhase.idle => l10n.stepFaceBody,
        _FacePhase.centering => l10n.faceCentering,
        _FacePhase.turning => l10n.faceTurn,
        _FacePhase.holding => l10n.faceHold,
        _FacePhase.matching => l10n.faceMatching,
        _FacePhase.matched => l10n.faceMatched,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final done = _phase == _FacePhase.matched;

    return StepScaffold(
      icon: Icons.face_retouching_natural_rounded,
      title: l10n.stepFace,
      body: l10n.stepFaceBody,
      actionLabel: done ? l10n.continueLabel : l10n.documentCapture,
      actionEnabled: _phase == _FacePhase.idle || done,
      onAction: done ? widget.onDone : _runScan,
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: Center(
              child: AnimatedBuilder(
                animation: _ring,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(220, 260),
                    painter: _FaceRingPainter(
                      progress: _ring.value,
                      active: _phase != _FacePhase.idle && !done,
                      done: done,
                    ),
                    child: child,
                  );
                },
                child: Center(
                  child: Icon(
                    done
                        ? Icons.verified_rounded
                        : Icons.person_rounded,
                    size: 70,
                    color: done
                        ? TaylorColors.verified
                        : TaylorColors.inkFaint.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: TaylorSpacing.md),
          AnimatedSwitcher(
            duration: TaylorMotion.fast,
            child: Text(
              _phaseLabel(l10n),
              key: ValueKey(_phase),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: done ? TaylorColors.verified : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Óvalo guía con un arco que gira mientras el escaneo está activo.
class _FaceRingPainter extends CustomPainter {
  _FaceRingPainter({
    required this.progress,
    required this.active,
    required this.done,
  });

  final double progress;
  final bool active;
  final bool done;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.86,
      height: size.height * 0.86,
    );

    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = TaylorColors.inkFaint.withValues(alpha: 0.28),
    );

    if (done) {
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = TaylorColors.verified,
      );
      return;
    }

    if (!active) return;

    canvas.drawArc(
      rect,
      progress * 2 * math.pi,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [TaylorColors.raspberry, TaylorColors.razzmatazz],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_FaceRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.active != active ||
      oldDelegate.done != done;
}
