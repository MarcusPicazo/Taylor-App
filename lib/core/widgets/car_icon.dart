import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models/ride_tier.dart';
import '../theme/taylor_colors.dart';

/// Ilustración de coche en perfil, una por categoría.
///
/// Se dibujan en lugar de usar iconos de Material porque Material no tiene
/// tres coches distinguibles entre sí, y porque un pictograma plano no
/// comunica la diferencia entre un sedán estándar y uno de lujo.
///
/// El volumen sale de cuatro recursos que usa cualquier ilustración de coche:
/// un degradado vertical en la carrocería (la luz viene de arriba), un
/// reflejo claro en la línea de cintura, pasos de rueda hundidos en tono más
/// oscuro, y una sombra elíptica en el suelo que lo asienta.
///
/// El perfil lateral es la vista más reconocible de un coche; un frontal a
/// este tamaño se confunde con cualquier otra cosa.
class CarIcon extends StatelessWidget {
  const CarIcon({
    super.key,
    required this.tier,
    this.size = 56,
    this.color,
    this.muted = false,
  });

  final RideTier tier;
  final double size;
  final Color? color;

  /// Versión apagada, para las categorías no elegidas.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Proporción de un coche en perfil, con hueco para la sombra.
      width: size,
      height: size * 0.52,
      child: CustomPaint(
        painter: _CarPainter(
          tier: tier,
          base: color ?? TaylorColors.raspberry,
          muted: muted,
        ),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  _CarPainter({
    required this.tier,
    required this.base,
    required this.muted,
  });

  final RideTier tier;
  final Color base;
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Geometría por categoría. Lo que distingue a las tres de un vistazo es la
    // relación entre altura de techo, longitud de la cabina y voladizos:
    //
    //   Go  — sedán compacto: techo medio, morro y cola cortos.
    //   Pro — berlina de lujo: más baja, cabina retrasada, cola larga.
    //   Max — van: techo alto y plano, morro corto, mucho vidrio lateral.
    final g = switch (tier) {
      RideTier.go => const _Geometry(
          roofY: 0.20,
          beltY: 0.52,
          sillY: 0.72,
          noseX: 0.05,
          tailX: 0.95,
          aPillarX: 0.30,
          cPillarX: 0.68,
          frontWheelX: 0.27,
          rearWheelX: 0.76,
        ),
      RideTier.pro => const _Geometry(
          roofY: 0.26,
          beltY: 0.56,
          sillY: 0.74,
          noseX: 0.03,
          tailX: 0.97,
          aPillarX: 0.32,
          cPillarX: 0.74,
          frontWheelX: 0.25,
          rearWheelX: 0.79,
        ),
      RideTier.max => const _Geometry(
          roofY: 0.09,
          beltY: 0.48,
          sillY: 0.72,
          noseX: 0.05,
          tailX: 0.96,
          aPillarX: 0.24,
          cPillarX: 0.82,
          frontWheelX: 0.26,
          rearWheelX: 0.78,
        ),
    };

    final body = base;
    final shade = Color.lerp(base, Colors.black, muted ? 0.10 : 0.22)!;
    final light = Color.lerp(base, Colors.white, 0.35)!;

    // --- Sombra en el suelo -------------------------------------------------
    // Elíptica y difusa. Es lo que impide que el coche parezca flotar.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.94),
        width: w * 0.80,
        height: h * 0.13,
      ),
      Paint()
        ..color = base.withValues(alpha: muted ? 0.10 : 0.20)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
    );

    // --- Carrocería ---------------------------------------------------------
    final shell = Path()
      // Morro.
      ..moveTo(w * g.noseX, h * g.sillY)
      ..cubicTo(
        w * (g.noseX - 0.02), h * (g.beltY + 0.04),
        w * (g.noseX + 0.02), h * g.beltY,
        w * (g.noseX + 0.10), h * (g.beltY - 0.02),
      )
      // Capó hacia el parabrisas.
      ..lineTo(w * (g.aPillarX - 0.04), h * (g.beltY - 0.04))
      // Parabrisas.
      ..quadraticBezierTo(
        w * (g.aPillarX + 0.01), h * (g.roofY + 0.04),
        w * (g.aPillarX + 0.08), h * g.roofY,
      )
      // Techo.
      ..lineTo(w * (g.cPillarX - 0.04), h * g.roofY)
      // Luneta trasera.
      ..quadraticBezierTo(
        w * (g.cPillarX + 0.05), h * (g.roofY + 0.05),
        w * (g.cPillarX + 0.10), h * (g.beltY - 0.03),
      )
      // Cola.
      ..lineTo(w * (g.tailX - 0.06), h * (g.beltY - 0.02))
      ..cubicTo(
        w * g.tailX, h * g.beltY,
        w * g.tailX, h * (g.sillY - 0.06),
        w * (g.tailX - 0.02), h * g.sillY,
      )
      ..close();

    canvas.drawPath(
      shell,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, h * g.roofY),
          Offset(0, h * g.sillY),
          [light, body, shade],
          [0.0, 0.45, 1.0],
        ),
    );

    // --- Ventanillas --------------------------------------------------------
    // Recortadas en un tono muy claro: se leen como cristal sin necesidad de
    // un color extra.
    final glass = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, h * g.roofY),
        Offset(0, h * g.beltY),
        [
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.72),
        ],
      );

    final glassTop = h * (g.roofY + 0.07);
    final glassBottom = h * (g.beltY - 0.07);

    if (glassBottom > glassTop) {
      // Delantera.
      canvas.drawPath(
        Path()
          ..moveTo(w * (g.aPillarX + 0.07), glassTop)
          ..lineTo(w * 0.50, glassTop)
          ..lineTo(w * 0.50, glassBottom)
          ..lineTo(w * (g.aPillarX - 0.01), glassBottom)
          ..close(),
        glass,
      );

      // Trasera. En Max se extiende más: es lo que comunica «caben más».
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.545, glassTop)
          ..lineTo(w * (g.cPillarX - 0.05), glassTop)
          ..lineTo(w * (g.cPillarX + 0.03), glassBottom)
          ..lineTo(w * 0.545, glassBottom)
          ..close(),
        glass,
      );
    }

    // --- Línea de cintura ---------------------------------------------------
    // El reflejo horizontal que recorre el costado. Sugiere una superficie
    // curva captando la luz, y es lo que más «acaba» la ilustración.
    canvas.drawLine(
      Offset(w * (g.noseX + 0.10), h * (g.beltY + 0.05)),
      Offset(w * (g.tailX - 0.08), h * (g.beltY + 0.05)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..strokeWidth = h * 0.035
        ..strokeCap = StrokeCap.round,
    );

    // --- Faros --------------------------------------------------------------
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w * (g.noseX + 0.005),
          h * (g.beltY + 0.10),
          w * 0.055,
          h * 0.09,
        ),
        Radius.circular(h * 0.04),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w * (g.tailX - 0.06),
          h * (g.beltY + 0.10),
          w * 0.045,
          h * 0.09,
        ),
        Radius.circular(h * 0.04),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // --- Ruedas -------------------------------------------------------------
    final wheelY = h * (g.sillY + 0.08);
    final wheelR = h * 0.19;

    for (final cx in [w * g.frontWheelX, w * g.rearWheelX]) {
      // Paso de rueda: un arco más oscuro que hunde la rueda en la carrocería
      // en lugar de dejarla pegada encima.
      canvas.drawCircle(
        Offset(cx, wheelY),
        wheelR * 1.24,
        Paint()..color = shade,
      );
      canvas.drawCircle(
        Offset(cx, wheelY),
        wheelR,
        Paint()..color = const Color(0xFF2B2B2E),
      );
      canvas.drawCircle(
        Offset(cx, wheelY),
        wheelR * 0.46,
        Paint()..color = Colors.white.withValues(alpha: 0.92),
      );
    }

    // Pro añade una moldura inferior a lo largo del costado — el recurso con
    // el que las berlinas premium estilizan el perfil y sugieren longitud.
    if (tier == RideTier.pro) {
      canvas.drawLine(
        Offset(w * 0.16, h * (g.sillY - 0.02)),
        Offset(w * 0.88, h * (g.sillY - 0.02)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.30)
          ..strokeWidth = h * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CarPainter oldDelegate) =>
      oldDelegate.tier != tier ||
      oldDelegate.base != base ||
      oldDelegate.muted != muted;
}

/// Puntos de control del perfil, en fracciones del lienzo.
class _Geometry {
  const _Geometry({
    required this.roofY,
    required this.beltY,
    required this.sillY,
    required this.noseX,
    required this.tailX,
    required this.aPillarX,
    required this.cPillarX,
    required this.frontWheelX,
    required this.rearWheelX,
  });

  /// Altura del techo.
  final double roofY;

  /// Línea de cintura: donde termina el vidrio y empieza la chapa.
  final double beltY;

  /// Bajos de la carrocería.
  final double sillY;

  final double noseX;
  final double tailX;

  /// Pilar delantero (parabrisas) y trasero (luneta).
  final double aPillarX;
  final double cPillarX;

  final double frontWheelX;
  final double rearWheelX;
}
