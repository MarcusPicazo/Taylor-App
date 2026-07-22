import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/notifications/taylor_notifications.dart';
import '../../data/models/driver_profile.dart';
import '../../data/models/trip.dart';

/// Fases de un viaje visto desde el lado de la conductora.
///
/// No son las mismas que las de la pasajera: a ella le importa "¿ya viene?",
/// a la conductora le importa "¿qué tengo que hacer ahora?". Por eso el
/// estado se modela aparte en lugar de reutilizar [TripStatus].
enum DriverTripPhase {
  /// Aceptó y va camino al punto de encuentro.
  headingToPickup,

  /// Llegó y espera a la pasajera.
  waitingForPassenger,

  /// Pasajera a bordo, en ruta al destino.
  inTransit,

  /// Viaje terminado, mostrando el resumen.
  completed,
}

/// Una solicitud entrante que la conductora puede aceptar o rechazar.
@immutable
class IncomingRequest {
  const IncomingRequest({
    required this.trip,
    required this.passengerName,
    required this.passengerRating,
    required this.estimatedFare,
    required this.minutesToPickup,
    required this.expiresAt,
  });

  final Trip trip;
  final String passengerName;
  final double passengerRating;
  final double estimatedFare;
  final int minutesToPickup;

  /// Momento en que la solicitud caduca y pasa a otra conductora.
  final DateTime expiresAt;

  Duration get remaining {
    final left = expiresAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }
}

@immutable
class DriverState {
  const DriverState({
    this.isOnline = false,
    this.incomingRequest,
    this.activeTrip,
    this.phase,
  });

  /// Si está disponible para recibir solicitudes.
  final bool isOnline;

  final IncomingRequest? incomingRequest;
  final Trip? activeTrip;
  final DriverTripPhase? phase;

  bool get hasActiveTrip => activeTrip != null;

  DriverState copyWith({
    bool? isOnline,
    IncomingRequest? incomingRequest,
    Trip? activeTrip,
    DriverTripPhase? phase,
    bool clearRequest = false,
    bool clearTrip = false,
  }) {
    return DriverState(
      isOnline: isOnline ?? this.isOnline,
      incomingRequest:
          clearRequest ? null : (incomingRequest ?? this.incomingRequest),
      activeTrip: clearTrip ? null : (activeTrip ?? this.activeTrip),
      phase: clearTrip ? null : (phase ?? this.phase),
    );
  }
}

/// Estado operativo de la conductora.
///
/// Los temporizadores simulan el despacho mientras no exista backend. Cuando
/// llegue, `_scheduleIncomingRequest` se reemplaza por una suscripción push y
/// el resto de la clase no cambia.
class DriverController extends StateNotifier<DriverState> {
  DriverController() : super(const DriverState());

  Timer? _dispatchTimer;
  Timer? _expiryTimer;

  /// Ventana para aceptar. Corta a propósito: la pasajera está esperando, y
  /// una solicitud que envejece se le debe pasar a otra conductora.
  static const Duration _acceptWindow = Duration(seconds: 15);

  void goOnline() {
    // Ponerse en línea es inmediato y NO depende del permiso.
    //
    // Es deliberado: si esperásemos a la respuesta del diálogo, el interruptor
    // se quedaría congelado mientras la usuaria decide, y si denegara no
    // podría trabajar en absoluto. No recibir notificaciones degrada la
    // experiencia —tendrá que mirar la pantalla— pero nunca debe impedirle
    // conducir.
    state = state.copyWith(isOnline: true);
    _scheduleIncomingRequest();

    // El permiso se pide aquí y no al abrir la app: en este momento la
    // conductora acaba de declarar que quiere recibir viajes, así que la
    // petición se explica sola. Pedirlo en el primer arranque es la forma
    // más rápida de que diga que no para siempre.
    //
    // Sin await y con el error tragado: es una mejora, no un requisito.
    unawaited(
      TaylorNotifications.instance.requestPermission().catchError((_) => false),
    );
  }

  void goOffline() {
    _dispatchTimer?.cancel();
    _expiryTimer?.cancel();
    TaylorNotifications.instance.cancelRideRequest();
    state = const DriverState();
  }

  void _scheduleIncomingRequest() {
    _dispatchTimer?.cancel();

    _dispatchTimer = Timer(const Duration(seconds: 3), () {
      // No interrumpir un viaje en curso con una solicitud nueva.
      if (!state.isOnline || state.hasActiveTrip) return;

      final now = DateTime.now();
      state = state.copyWith(
        incomingRequest: IncomingRequest(
          trip: Trip(
            id: 'req-${now.millisecondsSinceEpoch}',
            origin: const TripLocation(
              label: 'Punto de encuentro',
              address: 'Av. Michoacán 87, Condesa',
              position: LatLng(19.4128, -99.1745),
            ),
            destination: const TripLocation(
              label: 'Destino',
              address: 'Torre Reforma, Paseo de la Reforma 483',
              position: LatLng(19.4260, -99.1677),
            ),
            status: TripStatus.searching,
            requestedAt: now,
            distanceKm: 5.1,
            durationMinutes: 21,
            fare: 154.00,
          ),
          passengerName: 'Valentina R.',
          passengerRating: 4.94,
          estimatedFare: 154.00,
          minutesToPickup: 4,
          expiresAt: now.add(_acceptWindow),
        ),
      );

      // La notificación es lo que hace viable el modo conductora: sin ella,
      // una solicitud con la app en segundo plano —el caso normal mientras se
      // conduce— sencillamente no se enteraría.
      final request = state.incomingRequest!;
      TaylorNotifications.instance.showRideRequest(
        requestId: request.trip.id,
        passengerName: request.passengerName,
        fare: '\$${request.estimatedFare.toStringAsFixed(0)}',
        pickupAddress: request.trip.origin.address,
        timeout: _acceptWindow,
      );

      // Si no responde a tiempo, la solicitud se va sola.
      _expiryTimer = Timer(_acceptWindow, declineRequest);
    });
  }

  void acceptRequest() {
    final request = state.incomingRequest;
    if (request == null) return;

    _expiryTimer?.cancel();
    TaylorNotifications.instance.cancelRideRequest();
    state = state.copyWith(
      activeTrip: request.trip.copyWith(status: TripStatus.driverAssigned),
      phase: DriverTripPhase.headingToPickup,
      clearRequest: true,
    );
  }

  void declineRequest() {
    _expiryTimer?.cancel();
    TaylorNotifications.instance.cancelRideRequest();
    if (state.incomingRequest == null) return;

    state = state.copyWith(clearRequest: true);
    // Vuelve a la cola: rechazar no la saca de servicio.
    if (state.isOnline) _scheduleIncomingRequest();
  }

  void markArrived() {
    if (state.phase != DriverTripPhase.headingToPickup) return;
    state = state.copyWith(phase: DriverTripPhase.waitingForPassenger);
  }

  void startTrip() {
    if (state.phase != DriverTripPhase.waitingForPassenger) return;
    state = state.copyWith(
      phase: DriverTripPhase.inTransit,
      activeTrip: state.activeTrip?.copyWith(status: TripStatus.inProgress),
    );
  }

  void completeTrip() {
    if (state.phase != DriverTripPhase.inTransit) return;
    state = state.copyWith(
      phase: DriverTripPhase.completed,
      activeTrip: state.activeTrip?.copyWith(status: TripStatus.completed),
    );
  }

  /// Cierra el resumen y vuelve a ponerse en cola.
  void dismissSummary() {
    state = state.copyWith(clearTrip: true);
    if (state.isOnline) _scheduleIncomingRequest();
  }

  @override
  void dispose() {
    _dispatchTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }
}

final driverControllerProvider =
    StateNotifierProvider<DriverController, DriverState>(
  (ref) => DriverController(),
);

/// Perfil de la conductora (aprobación, vehículo, ganancias).
///
/// Separado de [DriverController] porque cambia con muchísima menos frecuencia:
/// el estado operativo se actualiza cada segundo, el perfil casi nunca.
final driverProfileProvider =
    StateNotifierProvider<DriverProfileController, DriverProfile>(
  (ref) => DriverProfileController(),
);

class DriverProfileController extends StateNotifier<DriverProfile> {
  DriverProfileController() : super(DriverProfile.none);

  void submitApplication() {
    state = state.copyWith(
      status: DriverApplicationStatus.underReview,
      submittedAt: DateTime.now(),
    );
  }

  void loadDemoProfile(DriverProfile profile) => state = profile;

  void reset() => state = DriverProfile.none;
}
