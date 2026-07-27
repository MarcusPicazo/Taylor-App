import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/ride_tier.dart';

/// Capa de despacho **en vivo** sobre Firestore.
///
/// Es lo que convierte la demo de un solo teléfono en una de dos: la pasajera
/// escribe una solicitud en Firestore, el teléfono de la conductora —otro
/// dispositivo, otra persona— la ve aparecer en tiempo real, la acepta, y la
/// pasajera ve la aceptación al instante. Sin servidor propio: Firestore hace
/// de intermediario.
///
/// Toda la escritura pasa por aquí y toda la lectura son streams, así que la
/// interfaz reacciona sola a lo que escribe el otro lado.
///
/// **Alcance de demostración.** El esquema es el mínimo para el pitch: una
/// sola colección, sin autenticación real, sin particionar por ciudad ni
/// controlar concurrencia más allá de la transacción de aceptación. Un
/// producto real necesita reglas por usuaria, matching por proximidad y
/// expiración de solicitudes en servidor. Ver `firestore.rules`.
class LiveDispatch {
  LiveDispatch(this._db);

  final FirebaseFirestore _db;

  /// Colección de solicitudes/viajes. Un documento por viaje, que va mutando
  /// su `status` a lo largo del trayecto — pasajera y conductora observan el
  /// mismo documento.
  CollectionReference<Map<String, dynamic>> get _rides =>
      _db.collection('demo_rides');

  // --- Lado pasajera -----------------------------------------------------

  /// Crea una solicitud y devuelve su id. Nace en estado `searching`, que es
  /// lo que la hace visible para las conductoras en línea.
  Future<String> requestRide({
    required String passengerName,
    required LatLng origin,
    required String originAddress,
    required LatLng destination,
    required String destinationName,
    required RideTier tier,
    required double fare,
    required double distanceKm,
    required int minutes,
  }) async {
    final doc = await _rides.add({
      'status': 'searching',
      'passengerName': passengerName,
      'origin': _geo(origin),
      'originAddress': originAddress,
      'destination': _geo(destination),
      'destinationName': destinationName,
      'tier': tier.name,
      'fare': fare,
      'distanceKm': distanceKm,
      'minutes': minutes,
      'driverId': null,
      'driverName': null,
      // serverTimestamp y no DateTime.now(): los relojes de los dos teléfonos
      // no coinciden, y el orden de las solicitudes debe ser el del servidor.
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Observa un viaje concreto. La pasajera escucha aquí para ver la
  /// asignación de conductora y los cambios de estado que ella provoca.
  Stream<LiveRide?> watchRide(String rideId) {
    return _rides.doc(rideId).snapshots().map(
          (snap) => snap.exists ? LiveRide.fromDoc(snap) : null,
        );
  }

  // --- Lado conductora ---------------------------------------------------

  /// Solicitudes abiertas, más recientes primero. La conductora en línea
  /// escucha aquí; cuando la pasajera crea una, aparece sin recargar.
  Stream<List<LiveRide>> watchOpenRequests() {
    return _rides
        .where('status', isEqualTo: 'searching')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map(LiveRide.fromDoc).toList(growable: false));
  }

  /// Acepta una solicitud.
  ///
  /// Va en transacción y comprueba que siga en `searching`: si dos conductoras
  /// la tocan casi a la vez, solo la primera gana y la segunda recibe `false`
  /// en lugar de robarle el viaje a la otra.
  Future<bool> acceptRequest({
    required String rideId,
    required String driverId,
    required String driverName,
  }) async {
    final ref = _rides.doc(rideId);

    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return false;
      if (snap.data()!['status'] != 'searching') return false;

      tx.update(ref, {
        'status': 'assigned',
        'driverId': driverId,
        'driverName': driverName,
      });
      return true;
    });
  }

  /// Avanza el estado del viaje. Lo llama la conductora; la pasajera lo ve.
  Future<void> setStatus(String rideId, LiveRideStatus status) {
    return _rides.doc(rideId).update({'status': status.name});
  }

  /// Descarta un viaje (cancelación desde cualquiera de los dos lados).
  Future<void> cancel(String rideId) {
    return _rides.doc(rideId).update({'status': 'cancelled'});
  }

  Map<String, dynamic> _geo(LatLng p) => {
        'lat': p.latitude,
        'lng': p.longitude,
      };
}

enum LiveRideStatus {
  searching,
  assigned,
  arriving,
  inProgress,
  completed,
  cancelled;

  static LiveRideStatus parse(String? raw) {
    for (final s in values) {
      if (s.name == raw) return s;
    }
    return LiveRideStatus.searching;
  }
}

/// Instantánea de un viaje tal como está en Firestore.
class LiveRide {
  const LiveRide({
    required this.id,
    required this.status,
    required this.passengerName,
    required this.origin,
    required this.originAddress,
    required this.destination,
    required this.destinationName,
    required this.tier,
    required this.fare,
    required this.distanceKm,
    required this.minutes,
    this.driverId,
    this.driverName,
  });

  final String id;
  final LiveRideStatus status;
  final String passengerName;
  final LatLng origin;
  final String originAddress;
  final LatLng destination;
  final String destinationName;
  final RideTier tier;
  final double fare;
  final double distanceKm;
  final int minutes;
  final String? driverId;
  final String? driverName;

  bool get isOpen => status == LiveRideStatus.searching;

  factory LiveRide.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data()!;
    return LiveRide(
      id: snap.id,
      status: LiveRideStatus.parse(d['status'] as String?),
      passengerName: (d['passengerName'] as String?) ?? '',
      origin: _geo(d['origin']),
      originAddress: (d['originAddress'] as String?) ?? '',
      destination: _geo(d['destination']),
      destinationName: (d['destinationName'] as String?) ?? '',
      tier: RideTier.values.firstWhere(
        (t) => t.name == d['tier'],
        orElse: () => RideTier.go,
      ),
      fare: (d['fare'] as num?)?.toDouble() ?? 0,
      distanceKm: (d['distanceKm'] as num?)?.toDouble() ?? 0,
      minutes: (d['minutes'] as num?)?.toInt() ?? 0,
      driverId: d['driverId'] as String?,
      driverName: d['driverName'] as String?,
    );
  }

  static LatLng _geo(dynamic raw) {
    final m = (raw as Map?) ?? const {};
    return LatLng(
      (m['lat'] as num?)?.toDouble() ?? 0,
      (m['lng'] as num?)?.toDouble() ?? 0,
    );
  }
}
