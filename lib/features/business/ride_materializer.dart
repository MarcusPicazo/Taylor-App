import 'package:flutter/foundation.dart';

import '../../data/models/business_account.dart';

/// Dos o más programaciones activas reclaman a la misma empleada la misma
/// noche.
///
/// No se resuelve en silencio: una persona no puede ir en dos coches a la vez,
/// pero descartar uno de los traslados sin avisar dejaría a la coordinadora
/// creyendo que alguien tiene transporte cuando quizá no lo tiene a la hora
/// que ella supone.
@immutable
class ScheduleConflict {
  const ScheduleConflict({
    required this.employee,
    required this.series,
    required this.resolvedTo,
  });

  final Employee employee;

  /// Todas las series que la reclamaban, en orden de hora de salida.
  final List<RideSeries> series;

  /// La que finalmente generó el traslado.
  final RideSeries resolvedTo;
}

@immutable
class MaterializationResult {
  const MaterializationResult({
    required this.rides,
    required this.conflicts,
  });

  final List<EmployeeRide> rides;
  final List<ScheduleConflict> conflicts;

  bool get hasConflicts => conflicts.isNotEmpty;

  static const MaterializationResult empty =
      MaterializationResult(rides: [], conflicts: []);
}

/// Convierte las programaciones recurrentes de una empresa en los traslados
/// concretos de un día.
///
/// Es el puente que faltaba: hasta ahora la Agenda describía intenciones
/// ("lunes a viernes a las 22:00") pero nadie las convertía en viajes reales.
///
/// La función es **pura y determinista**: mismos datos de entrada, mismos
/// identificadores de salida. Eso es lo que permite ejecutarla más de una vez
/// por noche —al abrir la app, al editar una serie, tras un reinicio— sin
/// duplicar traslados.
abstract final class RideMaterializer {
  /// Genera los traslados de [date] para [account].
  static MaterializationResult materialize({
    required BusinessAccount account,
    required DateTime date,
  }) {
    final series = account.seriesForToday(date);
    if (series.isEmpty) return MaterializationResult.empty;

    // Una empleada solo puede tener un traslado por noche. Se agrupa por
    // persona para detectar quién está reclamada por más de una serie.
    final claims = <String, List<RideSeries>>{};

    for (final s in series) {
      for (final employeeId in s.employeeIds) {
        final employee = account.employeeById(employeeId);

        // Se ignora a quien ya no está activa. El filtro se aplica aquí, en
        // la materialización, y no más tarde: una empleada desactivada a
        // media noche conserva el traslado que ya tenía en marcha.
        if (employee == null || !employee.isActive) continue;

        claims.putIfAbsent(employeeId, () => []).add(s);
      }
    }

    final rides = <EmployeeRide>[];
    final conflicts = <ScheduleConflict>[];

    for (final entry in claims.entries) {
      final employee = account.employeeById(entry.key)!;
      final claiming = [...entry.value]..sort(_byPickupTime);

      // Gana la salida más temprana: llegar antes a casa nunca es peor, y
      // dejar a alguien esperando el turno tardío sí puede serlo.
      final winner = claiming.first;

      if (claiming.length > 1) {
        conflicts.add(
          ScheduleConflict(
            employee: employee,
            series: claiming,
            resolvedTo: winner,
          ),
        );
      }

      rides.add(
        EmployeeRide(
          id: rideId(date: date, seriesId: winner.id, employeeId: employee.id),
          employee: employee,
          status: EmployeeRideStatus.scheduled,
          scheduledFor: DateTime(
            date.year,
            date.month,
            date.day,
            winner.pickupTime.hour,
            winner.pickupTime.minute,
          ),
        ),
      );
    }

    // Orden estable por hora y luego por nombre, para que el panel no baile
    // entre ejecuciones.
    rides.sort((a, b) {
      final byTime = a.scheduledFor.compareTo(b.scheduledFor);
      return byTime != 0 ? byTime : a.employee.name.compareTo(b.employee.name);
    });

    return MaterializationResult(rides: rides, conflicts: conflicts);
  }

  static int _byPickupTime(RideSeries a, RideSeries b) {
    final aMinutes = a.pickupTime.hour * 60 + a.pickupTime.minute;
    final bMinutes = b.pickupTime.hour * 60 + b.pickupTime.minute;
    if (aMinutes != bMinutes) return aMinutes.compareTo(bMinutes);
    // Desempate por id para que el resultado sea determinista aunque dos
    // series salgan a la misma hora.
    return a.id.compareTo(b.id);
  }

  /// Identificador determinista de un traslado.
  ///
  /// Derivarlo de (fecha, serie, empleada) en lugar de generarlo al azar es lo
  /// que hace idempotente a [materialize]: volver a ejecutarla produce los
  /// mismos ids y por tanto no duplica nada.
  @visibleForTesting
  static String rideId({
    required DateTime date,
    required String seriesId,
    required String employeeId,
  }) {
    final day = '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    return '$day-$seriesId-$employeeId';
  }
}
