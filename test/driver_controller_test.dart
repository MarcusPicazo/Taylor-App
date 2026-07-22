import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/data/models/trip.dart';
import 'package:taylor/features/driver/driver_controller.dart';

/// Estado operativo de la conductora.
///
/// Las transiciones de fase tienen guardas —`markArrived` solo desde
/// `headingToPickup`, etc.— y eso no es defensivo de más: la conductora pulsa
/// estos controles en movimiento, y un doble toque o un evento tardío del
/// backend no puede saltarse una fase del viaje.
void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  /// Despacho instantáneo: esperar tres segundos reales por caso convertiría
  /// la suite en algo que nadie ejecuta.
  DriverController controller() {
    final c = DriverController(dispatchDelay: Duration.zero);
    addTearDown(c.dispose);
    return c;
  }

  /// Deja correr el temporizador de despacho.
  Future<void> waitForDispatch() =>
      Future<void>.delayed(const Duration(milliseconds: 30));

  test('arranca desconectada y sin viaje', () {
    final c = controller();

    expect(c.state.isOnline, isFalse);
    expect(c.state.hasActiveTrip, isFalse);
    expect(c.state.incomingRequest, isNull);
  });

  test('ponerse en línea es inmediato', () {
    final c = controller();

    c.goOnline();

    // No depende del permiso de notificaciones: si esperásemos su respuesta,
    // el interruptor se congelaría mientras la usuaria decide, y denegarlo le
    // impediría trabajar.
    expect(c.state.isOnline, isTrue);
  });

  test('estando en línea llega una solicitud', () async {
    final c = controller();

    c.goOnline();
    await waitForDispatch();

    expect(c.state.incomingRequest, isNotNull);
    expect(c.state.incomingRequest!.passengerName, isNotEmpty);
  });

  test('desconectarse limpia todo el estado', () async {
    final c = controller();

    c.goOnline();
    await waitForDispatch();
    c.goOffline();

    expect(c.state.isOnline, isFalse);
    expect(c.state.hasActiveTrip, isFalse);
    expect(c.state.incomingRequest, isNull);
  });

  group('con una solicitud entrante', () {
    Future<DriverController> onlineWithRequest() async {
      final c = controller();
      c.goOnline();
      await waitForDispatch();
      expect(c.state.incomingRequest, isNotNull);
      return c;
    }

    test('aceptar crea el viaje y arranca camino al encuentro', () async {
      final c = await onlineWithRequest();

      c.acceptRequest();

      expect(c.state.hasActiveTrip, isTrue);
      expect(c.state.phase, DriverTripPhase.headingToPickup);
      expect(c.state.incomingRequest, isNull);
      expect(c.state.activeTrip!.status, TripStatus.driverAssigned);
    });

    test('rechazar descarta la solicitud sin crear viaje', () async {
      final c = await onlineWithRequest();

      c.declineRequest();

      expect(c.state.hasActiveTrip, isFalse);
      // Rechazar no la saca de servicio.
      expect(c.state.isOnline, isTrue);
    });

    test('el viaje recorre las fases en orden', () async {
      final c = await onlineWithRequest();
      c.acceptRequest();

      c.markArrived();
      expect(c.state.phase, DriverTripPhase.waitingForPassenger);

      c.startTrip();
      expect(c.state.phase, DriverTripPhase.inTransit);
      expect(c.state.activeTrip!.status, TripStatus.inProgress);

      c.completeTrip();
      expect(c.state.phase, DriverTripPhase.completed);
      expect(c.state.activeTrip!.status, TripStatus.completed);
    });

    test('no se puede saltar una fase', () async {
      final c = await onlineWithRequest();
      c.acceptRequest();

      // Iniciar sin haber marcado la llegada no hace nada: la pasajera aún no
      // ha subido al coche.
      c.startTrip();
      expect(c.state.phase, DriverTripPhase.headingToPickup);

      c.completeTrip();
      expect(c.state.phase, DriverTripPhase.headingToPickup);
    });

    test('marcar la llegada dos veces no avanza dos fases', () async {
      final c = await onlineWithRequest();
      c.acceptRequest();

      c.markArrived();
      c.markArrived();

      expect(c.state.phase, DriverTripPhase.waitingForPassenger);
    });

    test('cerrar el resumen libera el viaje y la deja en cola', () async {
      final c = await onlineWithRequest();
      c.acceptRequest();
      c.markArrived();
      c.startTrip();
      c.completeTrip();

      c.dismissSummary();

      expect(c.state.hasActiveTrip, isFalse);
      expect(c.state.phase, isNull);
      expect(c.state.isOnline, isTrue);
    });

    test('una solicitud nueva no interrumpe un viaje en curso', () async {
      final c = await onlineWithRequest();
      c.acceptRequest();

      await waitForDispatch();

      expect(c.state.incomingRequest, isNull);
      expect(c.state.phase, DriverTripPhase.headingToPickup);
    });
  });

  test('aceptar o rechazar sin solicitud no explota', () {
    final c = controller();

    c.acceptRequest();
    c.declineRequest();

    expect(c.state.hasActiveTrip, isFalse);
  });
}
