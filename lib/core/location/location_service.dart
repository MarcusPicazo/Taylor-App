import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// En qué situación está el permiso de ubicación.
enum LocationStatus {
  /// Todavía no se ha preguntado.
  unknown,

  /// Concedido: se puede mostrar el punto azul y centrar el mapa.
  granted,

  /// Denegado esta vez. Se puede volver a pedir.
  denied,

  /// Denegado permanentemente: solo se arregla desde los ajustes del sistema.
  deniedForever,

  /// El servicio de ubicación del teléfono está apagado.
  serviceDisabled,
}

class LocationState {
  const LocationState({
    this.status = LocationStatus.unknown,
    this.position,
  });

  final LocationStatus status;
  final LatLng? position;

  bool get isGranted => status == LocationStatus.granted;

  /// Si tiene sentido volver a pedirlo. Con `deniedForever` no: insistir solo
  /// produce diálogos que el sistema ya no muestra.
  bool get canRetry =>
      status == LocationStatus.denied || status == LocationStatus.unknown;
}

/// Ubicación de la usuaria.
///
/// Taylor pide el permiso **en contexto**, no al arrancar: se solicita cuando
/// se abre el mapa, que es donde se explica solo. Y si lo deniega, la app
/// sigue siendo usable — puede escribir su punto de encuentro a mano. La
/// ubicación mejora la experiencia; no es un peaje para entrar.
class LocationController extends StateNotifier<LocationState> {
  LocationController() : super(const LocationState());

  StreamSubscription<Position>? _stream;

  /// Posición por defecto mientras no hay permiso: centro de Ciudad de México.
  static const LatLng fallback = LatLng(19.4326, -99.1332);

  LatLng get positionOrFallback => state.position ?? fallback;

  /// Pide permiso si hace falta y obtiene la posición actual.
  ///
  /// No lanza nunca: un fallo de ubicación deja el mapa en el centro de la
  /// ciudad, que es peor experiencia pero no una pantalla rota.
  Future<void> ensurePermissionAndLocate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        state = const LocationState(status: LocationStatus.serviceDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        state = const LocationState(status: LocationStatus.deniedForever);
        return;
      }

      if (permission == LocationPermission.denied) {
        state = const LocationState(status: LocationStatus.denied);
        return;
      }

      await refreshPosition();
      _startStream();
    } catch (_) {
      state = const LocationState(status: LocationStatus.denied);
    }
  }

  /// Sigue la posición mientras la app está abierta.
  ///
  /// Sin esto el punto se quedaba clavado donde estaba al abrir: la usuaria ve
  /// su posición de hace diez minutos mientras camina hacia el punto de
  /// encuentro. `distanceFilter` evita reconstruir por cada micro-oscilación
  /// del GPS —que en ciudad son constantes— y ahorra batería.
  void _startStream() {
    _stream?.cancel();

    _stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    ).listen(
      (position) {
        state = LocationState(
          status: LocationStatus.granted,
          position: LatLng(position.latitude, position.longitude),
        );
      },
      // Un error del stream no debe dejar la app sin ubicación: se conserva
      // la última conocida, que sigue siendo mejor que el centro de la ciudad.
      onError: (_) {},
    );
  }

  /// Vuelve a leer la posición. Se usa al pulsar "recentrar".
  Future<void> refreshPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // Sin límite de tiempo el botón de recentrar puede quedarse girando
        // indefinidamente bajo techo o en un estacionamiento.
        timeLimit: const Duration(seconds: 12),
      );

      state = LocationState(
        status: LocationStatus.granted,
        position: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      // Si ya había una posición previa se conserva: una lectura fallida no
      // debería mandar el mapa de vuelta al centro de la ciudad.
      state = LocationState(
        status: LocationStatus.granted,
        position: state.position,
      );
    }
  }

  /// Abre los ajustes del sistema, para el caso de denegación permanente.
  Future<void> openSystemSettings() => Geolocator.openAppSettings();

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }
}

final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationState>(
  (ref) => LocationController(),
);
