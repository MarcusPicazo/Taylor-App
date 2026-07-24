import 'package:flutter/material.dart';

import '../theme/taylor_colors.dart';
import '../../data/models/ride_tier.dart';

/// Silueta de coche en perfil, dibujada a mano para cada categoría.
///
/// Se dibujan en lugar de usar iconos de Material por dos razones. La primera
/// es que Material no tiene tres coches distinguibles entre sí —un sedán, un
/// sedán de lujo y una van— y usar «estrella» para Pro no comunica lo que es.
/// La segunda es que a 36 px un icono genérico se vuelve una mancha: estas
/// siluetas están ajustadas para que la diferencia de perfil se lea a ese
/// tamaño.
///
/// El perfil lateral es la vista más reconocible de un coche. Un frontal en
/// pequeño se confunde con cualquier otra cosa.
class CarIcon extends StatelessWidget {
  const CarIcon({
    super.key,
    required this.tier,
    this.size = 40,
    this.color,
  });

  final RideTier tier;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Proporción de un coche en perfil: ancho más del doble que alto.
      width: size,
      height: size * 0.5,
      child: CustomPaint(
        painter: _CarPainter(
          tier: tier,
          color: color ?? TaylorColors.raspberry,
        ),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  _CarPainter({required this.tier, required this.color});

  final RideTier tier;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Alturas relativas del techo y del capó, que es lo que distingue las
    // tres categorías de un vistazo:
    //   Go   — proporciones de sedán compacto
    //   Pro  — más bajo y largo, techo retrasado: lectura de coche de lujo
    //   Max  — techo alto y plano, morro corto: lectura de van
    final (roofTop, roofStart, roofEnd, bonnetY) = switch (tier) {
      RideTier.go => (0.16, 0.28, 0.66, 0.46),
      RideTier.pro => (0.22, 0.24, 0.72, 0.50),
      RideTier.max => (0.06, 0.20, 0.74, 0.34),
    };

    final body = Path();

    // Morro delantero, redondeado.
    body.moveTo(w * 0.03, h * 0.78);
    body.quadraticBezierTo(w * 0.02, h * bonnetY, w * 0.13, h * bonnetY);

    // Parabrisas: inclinado en Go y Pro, casi vertical en Max.
    body.lineTo(w * roofStart, h * roofTop);

    // Techo.
    body.lineTo(w * roofEnd, h * roofTop);

    // Luneta trasera.
    body.lineTo(w * 0.90, h * bonnetY);

    // Cola.
    body.quadraticBezierTo(w * 0.98, h * bonnetY, w * 0.97, h * 0.78);
    body.lineTo(w * 0.03, h * 0.78);
    body.close();

    canvas.drawPath(body, Paint()..color = color);

    // Ventanillas: se recortan del cuerpo en color de fondo para que se lean
    // como cristal sin necesidad de un segundo tono.
    final glass = Paint()..color = TaylorColors.white;
    final windowTop = h * (roofTop + 0.06);
    final windowBottom = h * (bonnetY - 0.02);

    if (windowBottom > windowTop) {
      // Delantera.
      final front = Path()
        ..moveTo(w * (roofStart + 0.02), windowTop)
        ..lineTo(w * 0.46, windowTop)
        ..lineTo(w * 0.46, windowBottom)
        ..lineTo(w * (roofStart - 0.05), windowBottom)
        ..close();
      canvas.drawPath(front, glass);

      // Trasera. En Max es más larga: es lo que comunica «caben más».
      final rearEnd = tier == RideTier.max ? 0.84 : 0.80;
      final rear = Path()
        ..moveTo(w * 0.51, windowTop)
        ..lineTo(w * (roofEnd - 0.02), windowTop)
        ..lineTo(w * rearEnd, windowBottom)
        ..lineTo(w * 0.51, windowBottom)
        ..close();
      canvas.drawPath(rear, glass);
    }

    // Ruedas. Se dibujan sobre la línea inferior de la carrocería para que
    // el coche parezca apoyado y no flotando.
    final wheelY = h * 0.80;
    final wheelR = h * 0.17;
    final wheelPaint = Paint()..color = color;
    final hubPaint = Paint()..color = TaylorColors.white;

    for (final cx in [w * 0.26, w * 0.75]) {
      canvas.drawCircle(Offset(cx, wheelY), wheelR, wheelPaint);
      canvas.drawCircle(Offset(cx, wheelY), wheelR * 0.42, hubPaint);
    }

    // Pro lleva una línea de carácter a lo largo del costado — el recurso
    // que usan las marcas premium para sugerir longitud y estilizar el perfil.
    if (tier == RideTier.pro) {
      canvas.drawLine(
        Offset(w * 0.14, h * 0.62),
        Offset(w * 0.88, h * 0.62),
        Paint()
          ..color = TaylorColors.white.withValues(alpha: 0.55)
          ..strokeWidth = h * 0.045
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CarPainter oldDelegate) =>
      oldDelegate.tier != tier || oldDelegate.color != color;
}
