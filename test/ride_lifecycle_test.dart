import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taylor/data/models/trip.dart';
import 'package:taylor/features/home/ride_controller.dart';

/// Ciclo de vida del viaje de la pasajera.
///
/// Estas transiciones son la columna vertebral de la pantalla de Inicio: qué
/// tarjeta se muestra depende enteramente de ellas. Antes de este test el
/// viaje nunca llegaba a `completed` —`startTrip` y `completeTrip` existían
/// pero nadie los llamaba— y nadie se dio cuenta durante tres fases de
/// desarrollo, porque ninguna pantalla falla visiblemente: simplemente se
/// queda esperando para siempre.
void main() {
  const origin = TripLocation(
    label: 'Casa',
    address: 'Av. Amsterdam 240',
    position: LatLng(19.4110, -99.1710),
  );
  const destination = TripLocation(
    label: 'Oficina',
    address: 'Torre Reforma 483',
    position: LatLng(19.4260, -99.1677),
  );

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // El controlador notifica en cada cambio de estado. En un test no hay
    // plataforma detrás del plugin, así que se silencia el canal: lo que se
    // está probando es la máquina de estados, no las notificaciones.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (call) async => null,
    );
  });

  test('un viaje nuevo arranca buscando conductora', () {
    final controller = RideController();
    addTearDown(controller.dispose);

    expect(controller.state, isNull);

    controller.requestRide(origin: origin, destination: destination);

    expect(controller.state, isNotNull);
    expect(controller.state!.status, TripStatus.searching);
    expect(controller.state!.origin.label, 'Casa');
    expect(controller.state!.isActive, isTrue);
  });

  test('el viaje recorre el ciclo completo hasta completado', () {
    final controller = RideController();
    addTearDown(controller.dispose);

    controller.requestRide(origin: origin, destination: destination);

    controller.startTrip();
    expect(controller.state!.status, TripStatus.inProgress);
    expect(controller.state!.isActive, isTrue);

    controller.completeTrip();
    expect(controller.state!.status, TripStatus.completed);

    // Terminado ya no es "activo", pero el viaje sigue existiendo: es lo que
    // permite mostrar la tarjeta de calificación antes de limpiar.
    expect(controller.state!.isActive, isFalse);
    expect(controller.state, isNotNull);
  });

  test('calificar guarda la puntuación sin cerrar el viaje', () {
    final controller = RideController();
    addTearDown(controller.dispose);

    controller.requestRide(origin: origin, destination: destination);
    controller.completeTrip();

    expect(controller.state!.rating, isNull);

    controller.rate(4);

    expect(controller.state!.rating, 4);
    expect(controller.state!.status, TripStatus.completed);
  });

  test('descartar cierra el viaje y devuelve Inicio a su estado inicial', () {
    final controller = RideController();
    addTearDown(controller.dispose);

    controller.requestRide(origin: origin, destination: destination);
    controller.completeTrip();
    controller.rate(5);

    controller.dismiss();

    expect(controller.state, isNull);
  });

  test('cancelar durante la búsqueda descarta el viaje', () {
    final controller = RideController();
    addTearDown(controller.dispose);

    controller.requestRide(origin: origin, destination: destination);
    controller.cancel();

    expect(controller.state, isNull);
  });

  test('las transiciones sobre un viaje inexistente no explotan', () {
    final controller = RideController();
    addTearDown(controller.dispose);

    // Puede ocurrir si llega un evento tardío del backend después de que la
    // usuaria canceló.
    controller.startTrip();
    controller.completeTrip();
    controller.rate(5);
    controller.dismiss();

    expect(controller.state, isNull);
  });
}
