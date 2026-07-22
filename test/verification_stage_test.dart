import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/data/models/taylor_user.dart';

/// El embudo de verificación.
///
/// Estas reglas parecen obvias hasta que alguien inserta una etapa nueva en
/// medio —como acaba de pasar con la red de confianza— y olvida ajustar los
/// valores de progreso, dejando la barra del onboarding retrocediendo.
void main() {
  /// Etapas del embudo, en el orden en que se recorren. `rejected` queda
  /// fuera: es una salida, no un punto del camino.
  const funnel = [
    VerificationStage.registered,
    VerificationStage.phoneConfirmed,
    VerificationStage.documentCaptured,
    VerificationStage.biometricMatched,
    VerificationStage.backgroundCheckPending,
    VerificationStage.safetyNetworkReady,
    VerificationStage.verified,
  ];

  test('el progreso nunca retrocede al avanzar de etapa', () {
    for (var i = 1; i < funnel.length; i++) {
      expect(
        funnel[i].progress,
        greaterThan(funnel[i - 1].progress),
        reason: '${funnel[i].name} no avanza respecto a ${funnel[i - 1].name}',
      );
    }
  });

  test('el progreso se mantiene entre 0 y 1', () {
    for (final stage in VerificationStage.values) {
      expect(stage.progress, inInclusiveRange(0, 1));
    }
  });

  test('solo una cuenta verificada puede pedir viajes', () {
    for (final stage in VerificationStage.values) {
      expect(
        stage.canRequestRides,
        stage == VerificationStage.verified,
        reason: '${stage.name} no debería poder pedir viajes',
      );
    }
  });

  test('el embudo cubre todas las etapas salvo el rechazo', () {
    // Si alguien añade una etapa y no la mete en el embudo, este test avisa:
    // de lo contrario quedaría fuera de la comprobación de monotonía.
    expect(
      VerificationStage.values.length,
      funnel.length + 1,
      reason: 'hay una etapa nueva que no está en el embudo del test',
    );
  });

  test('la red de confianza va después de los antecedentes', () {
    // El orden importa: se pide cuando la identidad ya está confirmada y la
    // usuaria está invertida, para que se lea como algo para ella y no como
    // más trámite.
    expect(
      VerificationStage.safetyNetworkReady.progress,
      greaterThan(VerificationStage.backgroundCheckPending.progress),
    );
    expect(
      VerificationStage.safetyNetworkReady.progress,
      lessThan(VerificationStage.verified.progress),
    );
  });
}
