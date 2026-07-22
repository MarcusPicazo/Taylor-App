import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

/// Verifica que las animaciones Lottie del proyecto son válidas.
///
/// Existe porque la app degrada con elegancia: si un Lottie no se puede
/// cargar, `errorBuilder` dibuja el radar de respaldo y **no se ve ningún
/// error**. Esa robustez es deseable en producción, pero significa que un
/// JSON roto pasaría desapercibido para siempre. Este test es lo que impide
/// que eso ocurra.
void main() {
  test('searching_driver.json es un Lottie válido', () async {
    final file = File('assets/lottie/searching_driver.json');
    expect(file.existsSync(), isTrue,
        reason: 'falta assets/lottie/searching_driver.json');

    final composition = await LottieComposition.fromBytes(
      file.readAsBytesSync(),
    );

    // Cuatro capas: el punto central y las tres ondas desfasadas.
    expect(composition.layers.length, 4);

    // La composición debe durar lo suficiente para leerse como un pulso
    // continuo. Menos de medio segundo se percibiría como parpadeo.
    expect(composition.duration.inMilliseconds, greaterThan(500));

    expect(composition.startFrame, 0);
    expect(composition.endFrame, greaterThan(0));
  });
}
