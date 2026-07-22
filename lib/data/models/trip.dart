import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TripStatus {
  searching,
  driverAssigned,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

class TaylorDriver {
  const TaylorDriver({
    required this.id,
    required this.name,
    required this.rating,
    required this.tripCount,
    required this.carModel,
    required this.plate,
    this.photoUrl,
    this.yearsWithTaylor = 1,
  });

  final String id;
  final String name;
  final double rating;
  final int tripCount;
  final String carModel;
  final String plate;

  /// Foto profesional de frente. Para conductoras es obligatoria y no puede
  /// sustituirse por una imagen decorativa: la pasajera necesita reconocerla
  /// sin ambigüedad al subir al coche.
  final String? photoUrl;

  final int yearsWithTaylor;
}

class TripLocation {
  const TripLocation({
    required this.label,
    required this.address,
    required this.position,
  });

  final String label;
  final String address;
  final LatLng position;
}

class Trip {
  const Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.status,
    required this.requestedAt,
    this.driver,
    this.fare,
    this.distanceKm,
    this.durationMinutes,
    this.rating,
  });

  final String id;
  final TripLocation origin;
  final TripLocation destination;
  final TripStatus status;
  final DateTime requestedAt;
  final TaylorDriver? driver;
  final double? fare;
  final double? distanceKm;
  final int? durationMinutes;
  final double? rating;

  bool get isActive =>
      status != TripStatus.completed && status != TripStatus.cancelled;

  Trip copyWith({
    TripStatus? status,
    TaylorDriver? driver,
    double? fare,
    double? rating,
  }) {
    return Trip(
      id: id,
      origin: origin,
      destination: destination,
      status: status ?? this.status,
      requestedAt: requestedAt,
      driver: driver ?? this.driver,
      fare: fare ?? this.fare,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      rating: rating ?? this.rating,
    );
  }
}
