import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../core/widgets/taylor_logo.dart';
import '../../data/models/taylor_user.dart';
import '../../data/session_controller.dart';

/// Pantalla de apertura.
///
/// Un punto recorre un trazo horizontal —la idea de trayecto— y al llegar se
/// disuelve en el wordmark. Dura poco más de dos segundos: el brand book pide
/// que la app se sienta rápida, así que el splash sugiere movilidad y se quita
/// de en medio en lugar de lucirse.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _trail;
  late final Animation<double> _dotFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    // El trazo se dibuja primero, el punto se desvanece al llegar al final, y
    // solo entonces entra el logo. Los intervalos se solapan ligeramente para
    // que la secuencia se lea como un gesto continuo y no como tres pasos.
    _trail = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.55, curve: TaylorMotion.emphasized),
    );
    _dotFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.62, curve: Curves.easeOut),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.78, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.85, curve: TaylorMotion.emphasized),
      ),
    );

    _controller.forward().whenComplete(_goNext);
  }

  void _goNext() {
    if (!mounted) return;

    final session = ref.read(sessionControllerProvider);
    if (!session.isSignedIn) {
      context.go(Routes.login);
    } else if (session.user!.stage != VerificationStage.verified) {
      context.go(Routes.onboarding);
    } else {
      context.go(Routes.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: TaylorColors.brandGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SizedBox(
                width: 240,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 1 - _dotFade.value,
                      child: CustomPaint(
                        size: const Size(240, 120),
                        painter: _TrailPainter(progress: _trail.value),
                      ),
                    ),
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: const TaylorLogo(
                          size: 56,
                          color: TaylorColors.white,
                          includeClearSpace: false,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dibuja una estela que se acorta por detrás mientras el punto avanza,
/// como el rastro de un vehículo en un mapa.
class _TrailPainter extends CustomPainter {
  _TrailPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final startX = size.width * 0.12;
    final endX = size.width * 0.88;
    final headX = startX + (endX - startX) * progress;

    // La cola arranca pegada al punto y se estira conforme avanza, luego se
    // recoge: da la sensación de aceleración sin animar la velocidad.
    final tailLength = size.width * 0.30 * (1 - (progress - 0.5).abs() * 2)
        .clamp(0.0, 1.0);
    final tailX = (headX - tailLength).clamp(startX, endX);

    if (headX > tailX) {
      final trail = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5
        ..shader = LinearGradient(
          colors: [
            TaylorColors.white.withValues(alpha: 0.0),
            TaylorColors.white.withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromLTRB(tailX, y - 3, headX, y + 3));

      canvas.drawLine(Offset(tailX, y), Offset(headX, y), trail);
    }

    canvas.drawCircle(
      Offset(headX, y),
      7,
      Paint()..color = TaylorColors.white,
    );
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
