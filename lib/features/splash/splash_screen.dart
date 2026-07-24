import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/widgets/taylor_logo.dart';
import '../../data/models/taylor_user.dart';
import '../../data/session_controller.dart';

/// Pantalla de apertura.
///
/// La animación cuenta una idea en tres tiempos: **línea → gota → logo**.
///
/// 1. Una línea cruza la pantalla acelerando y frenando, como un vehículo que
///    arranca y llega. Ese perfil de velocidad es lo que la hace leer como
///    movimiento real y no como una barra que se desplaza.
/// 2. Al detenerse, la cola alcanza a la cabeza y la línea **se recoge en una
///    gota**: la masa se conserva, solo cambia de forma.
/// 3. La gota se derrama a lo ancho y el wordmark cuaja sobre ella.
///
/// El objeto nunca desaparece ni se sustituye por otro. Esa continuidad es
/// exactamente lo que separa un motion graphic de una secuencia de fundidos.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _travel;
  late final Animation<double> _gather;
  late final Animation<double> _spread;
  late final Animation<double> _shapeFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Recorrido con aceleración y frenada. easeInOutCubic es justo eso: sale
    // despacio, gana velocidad en el centro y se detiene con suavidad.
    _travel = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.46, curve: Curves.easeInOutCubic),
    );

    // La cola alcanza a la cabeza y la línea se recoge en gota. Con un ligero
    // rebote: la masa que venía en movimiento no frena en seco.
    _gather = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.64, curve: Curves.easeOutBack),
    );

    // La gota se derrama hasta el ancho del wordmark.
    _spread = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.84, curve: Curves.easeInOutCubic),
    );

    _shapeFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.76, 0.90, curve: Curves.easeOut),
    );

    // El logo entra mientras la forma aún está extendiéndose: el solape es lo
    // que lo hace leer como transformación y no como relevo.
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.90, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.96, curve: Curves.easeOutBack),
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
                width: 260,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 1 - _shapeFade.value,
                      child: CustomPaint(
                        size: const Size(260, 120),
                        painter: _MorphPainter(
                          travel: _travel.value,
                          gather: _gather.value,
                          spread: _spread.value,
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

/// Dibuja las tres fases sobre una sola forma continua.
///
/// En todo momento se pinta **una cápsula**: un rectángulo de esquinas
/// completamente redondeadas. Lo único que cambia es su centro, su longitud y
/// su grosor. Que las tres fases sean la misma primitiva es lo que hace que
/// la transición no tenga costuras.
class _MorphPainter extends CustomPainter {
  _MorphPainter({
    required this.travel,
    required this.gather,
    required this.spread,
  });

  /// 0..1 — recorrido de la línea.
  final double travel;

  /// 0..1 — la línea se recoge en gota.
  final double gather;

  /// 0..1 — la gota se derrama en la forma del wordmark.
  final double spread;

  /// Grosor de la línea en movimiento.
  static const double _lineThickness = 9;

  /// Diámetro de la gota ya recogida.
  static const double _dropSize = 20;

  /// Ancho final, el del wordmark "taylor" a 56 px.
  static const double _logoWidth = 172;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final startX = size.width * 0.14;
    final endX = size.width * 0.86;
    final centerX = size.width / 2;

    // --- Fase 1: la línea viaja -------------------------------------------
    // La cabeza avanza con el recorrido; la cola arranca pegada, se descuelga
    // al acelerar y vuelve a alcanzarla al frenar. Esa distancia variable es
    // lo que dibuja la aceleración sin necesidad de animar nada más.
    final headX = startX + (endX - startX) * travel;

    // Campana: máxima separación a mitad de recorrido, cero en los extremos.
    //
    // Se le suma un mínimo para que en el instante cero la forma sea una gota
    // y no un punto de ancho nulo: sin él, la animación arranca con la
    // pantalla vacía durante unos fotogramas y parece que se ha colgado.
    final stretch = _bell(travel);
    final length = _lineThickness + (endX - startX) * 0.34 * stretch;
    final tailX = headX - length;

    var thickness = _lineThickness;
    var left = tailX;
    var right = headX;

    // --- Fase 2: se recoge en gota ----------------------------------------
    if (gather > 0) {
      // La cola alcanza a la cabeza y la forma se contrae sobre su centro.
      final t = gather.clamp(0.0, 1.0);
      final lineCenter = (tailX + headX) / 2;
      final target = centerX;

      final currentCenter = lineCenter + (target - lineCenter) * t;
      final currentLength = (headX - tailX) * (1 - t) + _dropSize * t;

      // Al recogerse engorda: el volumen que pierde a lo largo lo gana a lo
      // alto, como haría una masa real.
      thickness = _lineThickness + (_dropSize - _lineThickness) * t;

      left = currentCenter - currentLength / 2;
      right = currentCenter + currentLength / 2;
    }

    // --- Fase 3: se derrama en el logo ------------------------------------
    if (spread > 0) {
      final t = spread.clamp(0.0, 1.0);
      final width = _dropSize + (_logoWidth - _dropSize) * t;

      // Al extenderse adelgaza, otra vez conservando la masa.
      thickness = _dropSize - (_dropSize - 11) * t;

      left = centerX - width / 2;
      right = centerX + width / 2;
    }

    final rect = Rect.fromLTRB(
      left,
      y - thickness / 2,
      right,
      y + thickness / 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(thickness / 2)),
      Paint()..color = TaylorColors.white,
    );

    // Estela: solo mientras viaja, y solo si hay velocidad. Refuerza la
    // dirección del movimiento sin ensuciar las fases quietas.
    if (gather == 0 && stretch > 0.05) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            tailX - 26 * stretch,
            y - thickness * 0.28,
            tailX + 4,
            y + thickness * 0.28,
          ),
          Radius.circular(thickness),
        ),
        Paint()..color = TaylorColors.white.withValues(alpha: 0.30 * stretch),
      );
    }

    // Gotas satélite al recogerse: se desprenden y se reabsorben. Es el
    // detalle que comunica tensión superficial, y lo que hace que la forma se
    // lea líquida y no elástica.
    if (gather > 0.1 && gather < 0.95 && spread == 0) {
      final pop = _bell(gather);
      for (final dx in [-1.0, 1.0]) {
        canvas.drawCircle(
          Offset(centerX + dx * (_dropSize * 0.9 + 14 * pop), y),
          3.4 * pop,
          Paint()..color = TaylorColors.white.withValues(alpha: 0.8 * pop),
        );
      }
    }
  }

  /// Campana simétrica: 0 en los extremos, 1 en el centro.
  double _bell(double t) {
    final clamped = t.clamp(0.0, 1.0);
    return 1 - (clamped - 0.5).abs() * 2;
  }

  @override
  bool shouldRepaint(_MorphPainter oldDelegate) =>
      oldDelegate.travel != travel ||
      oldDelegate.gather != gather ||
      oldDelegate.spread != spread;
}
