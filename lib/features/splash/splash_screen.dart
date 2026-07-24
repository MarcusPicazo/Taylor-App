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
  late final Animation<double> _morph;
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

    // El punto recorre la pantalla, y al llegar al centro **se derrama** hacia
    // los lados hasta convertirse en el wordmark.
    //
    // Los tramos se solapan a propósito: mientras la gota aún se está
    // extendiendo, el logo ya empieza a aparecer. Ese solapamiento es lo que
    // hace que se lea como una transformación en lugar de como "una cosa se
    // va, otra llega".
    _trail = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.52, curve: TaylorMotion.emphasized),
    );

    // Fase líquida: la gota se estira horizontalmente hasta ocupar el ancho
    // del logo, y en ese momento se desvanece.
    _morph = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.76, curve: Curves.easeInOutCubic),
    );
    _dotFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.80, curve: Curves.easeOut),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.84, curve: Curves.easeOut),
    );
    // Entra con un rebote mínimo, como si la tensión superficial del líquido
    // se soltara al cuajar en la forma final.
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.92, curve: Curves.easeOutBack),
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
                        painter: _TrailPainter(
                          progress: _trail.value,
                          morph: _morph.value,
                        ),
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

/// Estela de movilidad.
///
/// Un punto recorre la pantalla dejando rastro y **rebota** al llegar, como
/// una gota con inercia. Detrás quedan dos líneas de velocidad que se
/// desvanecen, el recurso clásico de motion graphics para comunicar
/// desplazamiento con lo mínimo.
///
/// Todo el vocabulario es geométrico —punto, línea, arco— sin dibujar un
/// coche: a esta escala una silueta reconocible competiría con el wordmark, y
/// la marca es minimalista antes que literal.
class _TrailPainter extends CustomPainter {
  _TrailPainter({required this.progress, required this.morph});

  final double progress;

  /// 0 = gota viajando · 1 = derramada en la forma del wordmark.
  final double morph;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final startX = size.width * 0.12;
    final endX = size.width * 0.88;

    // Fase de derrame: la gota deja de viajar, se recoge al centro y se
    // extiende a lo ancho hasta convertirse en la base del wordmark.
    if (morph > 0) {
      _paintMorph(canvas, size, y);
      return;
    }

    // Rebote al final del recorrido: se pasa un poco y vuelve. Es lo que da
    // el carácter juguetón — un desplazamiento lineal se lee mecánico.
    final eased = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));
    final headX = startX + (endX - startX) * eased;

    // El punto se aplasta al acelerar y se redondea al frenar, conservando el
    // área: la deformación es lo que sugiere masa y velocidad.
    final speed = (1 - (progress - 0.45).abs() * 2.2).clamp(0.0, 1.0);
    final rx = 7 + speed * 5;
    final ry = 7 - speed * 2.2;

    // Estela principal: se estira al acelerar y se recoge al frenar.
    final tailLength = size.width * 0.34 * speed;
    final tailX = (headX - tailLength).clamp(startX - 20, endX);

    if (headX > tailX) {
      canvas.drawLine(
        Offset(tailX, y),
        Offset(headX, y),
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = ry * 1.6
          ..shader = LinearGradient(
            colors: [
              TaylorColors.white.withValues(alpha: 0),
              TaylorColors.white.withValues(alpha: 0.85),
            ],
          ).createShader(Rect.fromLTRB(tailX, y - 4, headX, y + 4)),
      );
    }

    // Líneas de velocidad, arriba y abajo, desfasadas y más cortas.
    for (final (offsetY, scale) in [(-13.0, 0.62), (12.0, 0.48)]) {
      final lineLength = tailLength * scale;
      final lineEnd = headX - 14 - (1 - speed) * 20;
      final lineStart = lineEnd - lineLength;

      if (lineLength > 4 && lineEnd > startX) {
        canvas.drawLine(
          Offset(lineStart.clamp(startX - 30, endX), y + offsetY),
          Offset(lineEnd, y + offsetY),
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 3
            ..color = TaylorColors.white.withValues(alpha: 0.42 * speed),
        );
      }
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headX, y),
        width: rx * 2,
        height: ry * 2,
      ),
      Paint()..color = TaylorColors.white,
    );
  }

  /// La gota se derrama hasta tomar la forma del wordmark.
  ///
  /// Se estira a lo ancho mientras se adelgaza —conservando aproximadamente el
  /// área, como haría un fluido— y las esquinas pasan de círculo a cápsula. Al
  /// final queda una barra del ancho exacto del logo, sobre la que este entra.
  ///
  /// Es un morph de forma, no un fundido cruzado: el objeto nunca desaparece,
  /// solo cambia de silueta. Esa continuidad es lo que lo hace leer como
  /// líquido.
  void _paintMorph(Canvas canvas, Size size, double y) {
    final t = morph.clamp(0.0, 1.0);
    final centerX = size.width / 2;

    // De 14 px de diámetro a 170 px de ancho: la anchura del wordmark.
    final width = 14 + (170 - 14) * t;
    // Se adelgaza al extenderse, pero nunca a cero: por debajo de ~10 px se
    // rompería la lectura de masa continua.
    final height = 14 - 4 * t;

    final rect = Rect.fromCenter(
      center: Offset(centerX, y),
      width: width,
      height: height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(height / 2)),
      Paint()..color = TaylorColors.white,
    );

    // Dos gotas satélite que se separan del cuerpo principal y se reabsorben:
    // el detalle que da la sensación de tensión superficial.
    if (t > 0.15 && t < 0.85) {
      final spread = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
      final satelliteR = 3.2 * spread;
      final offset = width * 0.5 + 10 * spread;

      for (final dx in [-offset, offset]) {
        canvas.drawCircle(
          Offset(centerX + dx, y),
          satelliteR,
          Paint()..color = TaylorColors.white.withValues(alpha: spread * 0.85),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.morph != morph;
}
