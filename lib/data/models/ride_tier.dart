import 'package:flutter/material.dart';

/// Categorías de viaje de Taylor.
///
/// El precio no se guarda: se **calcula** a partir de la distancia y el tiempo,
/// porque una tarifa fija por categoría se desincroniza en cuanto cambia la
/// ruta. Guardar el multiplicador en lugar del importe mantiene una sola
/// fuente de verdad.
enum RideTier {
  /// Equivalente a UberX: el viaje estándar, hasta 4 pasajeras.
  go(
    seats: 4,
    fareMultiplier: 1.0,
    icon: Icons.directions_car_rounded,
  ),

  /// Equivalente a Uber Black: vehículos de gama alta, hasta 4 pasajeras.
  pro(
    seats: 4,
    fareMultiplier: 1.75,
    icon: Icons.auto_awesome_rounded,
  ),

  /// Equivalente a UberXL: vehículos amplios, hasta 6 pasajeras.
  max(
    seats: 6,
    fareMultiplier: 1.45,
    icon: Icons.airport_shuttle_rounded,
  );

  const RideTier({
    required this.seats,
    required this.fareMultiplier,
    required this.icon,
  });

  final int seats;
  final double fareMultiplier;
  final IconData icon;

  /// Nombre comercial. No se traduce: es marca, igual que "Taylor".
  String get displayName => switch (this) {
        RideTier.go => 'Taylor Go',
        RideTier.pro => 'Taylor Pro',
        RideTier.max => 'Taylor Max',
      };

  /// Tarifa estimada para una ruta.
  ///
  /// Estructura base + distancia + tiempo, sobre la que se aplica el
  /// multiplicador de categoría. Los valores son de referencia para Ciudad de
  /// México; en producción vienen del backend, que además aplica demanda,
  /// peajes y promociones.
  double estimateFare({required double distanceKm, required int minutes}) {
    const baseFare = 28.0;
    const perKm = 9.5;
    const perMinute = 2.2;

    final raw = (baseFare + distanceKm * perKm + minutes * perMinute) *
        fareMultiplier;

    // Redondeo al peso: los centavos en una estimación sugieren una precisión
    // que no existe.
    return raw.roundToDouble();
  }

  /// Minutos estimados hasta el punto de encuentro.
  ///
  /// Las categorías premium tienen menos vehículos en circulación, así que
  /// tardan más en llegar. Mostrarlo es parte de la decisión: a veces se elige
  /// Go simplemente porque llega antes.
  int pickupMinutes(int baseMinutes) => switch (this) {
        RideTier.go => baseMinutes,
        RideTier.pro => baseMinutes + 4,
        RideTier.max => baseMinutes + 2,
      };
}
