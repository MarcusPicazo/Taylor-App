import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/notifications/taylor_notifications.dart';
import '../../data/demo_data.dart';
import '../../data/models/trip.dart';

/// Máquina de estados del viaje activo.
///
/// Los temporizadores simulan el backend mientras no exista. Cuando llegue el
/// real, solo cambia [_advanceAfter] por una suscripción a Firestore: el resto
/// de la app observa `Trip` y no necesita enterarse.
class RideController extends StateNotifier<Trip?> {
  RideController() : super(null);

  Timer? _timer;

  static const LatLng defaultOrigin = LatLng(19.4110, -99.1710);

  void requestRide({
    required TripLocation origin,
    required TripLocation destination,
  }) {
    _timer?.cancel();

    state = Trip(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      origin: origin,
      destination: destination,
      status: TripStatus.searching,
      requestedAt: DateTime.now(),
      distanceKm: 4.2,
      durationMinutes: 18,
      fare: 128.50,
    );

    // Asignación de conductora tras unos segundos de búsqueda.
    _advanceAfter(const Duration(seconds: 4), () {
      final driver = TaylorDemo.drivers.first;
      state = state?.copyWith(
        status: TripStatus.driverAssigned,
        driver: driver,
      );

      // Notificar importa aquí porque la pasajera suele guardar el teléfono
      // mientras espera. Se incluye placa y coche: es lo que necesita para
      // identificar el vehículo sin volver a abrir la app.
      TaylorNotifications.instance.showTripStatus(
        tripId: state?.id ?? '',
        title: '${driver.name} va en camino',
        body: '${driver.carModel} · ${driver.plate}',
      );

      _advanceAfter(const Duration(seconds: 5), () {
        state = state?.copyWith(status: TripStatus.driverArriving);

        TaylorNotifications.instance.showTripStatus(
          tripId: state?.id ?? '',
          title: 'Tu conductora llegó',
          body: '${driver.carModel} · ${driver.plate}',
        );

        // Sube al coche y arranca el trayecto.
        _advanceAfter(const Duration(seconds: 6), () {
          startTrip();

          // Y llega a destino. En producción esto lo dispara la conductora
          // desde su lado, no un temporizador.
          _advanceAfter(const Duration(seconds: 8), completeTrip);
        });
      });
    });
  }

  void _advanceAfter(Duration delay, void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (state == null) return;
      action();
    });
  }

  void startTrip() {
    state = state?.copyWith(status: TripStatus.inProgress);

    TaylorNotifications.instance.showTripStatus(
      tripId: state?.id ?? '',
      title: 'Viaje iniciado',
      body: 'Rumbo a ${state?.destination.address ?? ''}',
    );
  }

  void completeTrip() {
    _timer?.cancel();
    state = state?.copyWith(status: TripStatus.completed);
  }

  /// Guarda la calificación de la pasajera sobre la conductora.
  void rate(double stars) {
    state = state?.copyWith(rating: stars);
  }

  /// Cierra el viaje terminado y devuelve la pantalla de Inicio a su estado
  /// inicial.
  ///
  /// Separado de [completeTrip] a propósito: entre "llegué" y "ya terminé de
  /// calificar" hay un momento en el que el viaje sigue siendo el viaje
  /// activo, y la pantalla necesita saber distinguirlos.
  void dismiss() {
    _timer?.cancel();
    state = null;
  }

  void cancel() {
    _timer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final rideControllerProvider =
    StateNotifierProvider<RideController, Trip?>((ref) => RideController());
