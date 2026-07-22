/// Estado de la solicitud para conducir con Taylor.
///
/// Ser conductora exige revisión humana, no solo automatizada: la promesa de
/// la marca no se sostiene si el filtro es únicamente algorítmico. Por eso
/// existe [underReview] como estado real y duradero, no como pantalla de carga.
enum DriverApplicationStatus {
  /// Nunca solicitó.
  none,

  /// Documentos enviados, en revisión del equipo (3-5 días hábiles).
  underReview,

  /// Falta corregir o volver a subir algún documento.
  actionRequired,

  /// Aprobada: ya puede conducir.
  approved,

  /// Rechazada por el equipo de confianza y seguridad.
  rejected,

  /// Aprobada en su momento pero suspendida temporalmente.
  suspended,
}

extension DriverApplicationStatusX on DriverApplicationStatus {
  bool get canDrive => this == DriverApplicationStatus.approved;

  /// Si debe verse la entrada a modo conductora en la pestaña de Cuenta.
  bool get hasApplied => this != DriverApplicationStatus.none;
}

class Vehicle {
  const Vehicle({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plate,
  });

  final String make;
  final String model;
  final int year;
  final String color;
  final String plate;

  String get displayName => '$make $model $year · $color';

  Map<String, dynamic> toMap() => {
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'plate': plate,
      };

  factory Vehicle.fromMap(Map<String, dynamic> map) => Vehicle(
        make: map['make'] as String,
        model: map['model'] as String,
        year: map['year'] as int,
        color: map['color'] as String,
        plate: map['plate'] as String,
      );
}

/// Una entrada del historial de ganancias.
class EarningEntry {
  const EarningEntry({
    required this.tripId,
    required this.completedAt,
    required this.gross,
    required this.commission,
    required this.tip,
    required this.distanceKm,
  });

  final String tripId;
  final DateTime completedAt;

  /// Lo que pagó la pasajera, antes de comisión.
  final double gross;

  /// Comisión de Taylor sobre este viaje.
  final double commission;

  final double tip;
  final double distanceKm;

  /// Lo que efectivamente le queda a la conductora.
  ///
  /// La propina no entra en la comisión: es de ella íntegra.
  double get net => gross - commission + tip;
}

class DriverProfile {
  const DriverProfile({
    required this.status,
    this.vehicle,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.acceptanceRate = 1.0,
    this.professionalPhotoUrl,
    this.earnings = const [],
    this.submittedAt,
  });

  final DriverApplicationStatus status;
  final Vehicle? vehicle;
  final double rating;
  final int totalTrips;

  /// Tasa de aceptación 0..1. Se muestra pero NO penaliza automáticamente:
  /// una conductora puede rechazar un viaje por sentirse insegura, y castigar
  /// eso contradiría el producto entero.
  final double acceptanceRate;

  /// Foto profesional de frente. Obligatoria y distinta de la foto de perfil
  /// de pasajera: la pasajera necesita reconocerla al subir al coche.
  final String? professionalPhotoUrl;

  final List<EarningEntry> earnings;
  final DateTime? submittedAt;

  /// Fecha estimada de respuesta: 5 días hábiles desde el envío.
  ///
  /// Se calcula saltando fines de semana en vez de sumar 7 días naturales,
  /// para que la fecha mostrada sea la que el equipo realmente va a cumplir.
  DateTime? get estimatedResponseBy {
    final from = submittedAt;
    if (from == null) return null;

    var date = from;
    var businessDays = 0;
    while (businessDays < 5) {
      date = date.add(const Duration(days: 1));
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        businessDays++;
      }
    }
    return date;
  }

  double earningsSince(DateTime from) => earnings
      .where((e) => e.completedAt.isAfter(from))
      .fold(0.0, (sum, e) => sum + e.net);

  int tripsSince(DateTime from) =>
      earnings.where((e) => e.completedAt.isAfter(from)).length;

  DriverProfile copyWith({
    DriverApplicationStatus? status,
    Vehicle? vehicle,
    double? rating,
    int? totalTrips,
    double? acceptanceRate,
    String? professionalPhotoUrl,
    List<EarningEntry>? earnings,
    DateTime? submittedAt,
  }) {
    return DriverProfile(
      status: status ?? this.status,
      vehicle: vehicle ?? this.vehicle,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      professionalPhotoUrl:
          professionalPhotoUrl ?? this.professionalPhotoUrl,
      earnings: earnings ?? this.earnings,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  static const DriverProfile none =
      DriverProfile(status: DriverApplicationStatus.none);
}
