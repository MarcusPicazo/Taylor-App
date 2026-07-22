import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/data/models/business_account.dart';
import 'package:taylor/features/business/ride_materializer.dart';

/// El materializador convierte programaciones recurrentes en traslados de una
/// noche concreta. Es lógica de dominio pura, así que se prueba entera.
void main() {
  const ana = Employee(id: 'e1', name: 'Ana Ruiz', phone: '+52 1');
  const bea = Employee(id: 'e2', name: 'Bea Soto', phone: '+52 2');
  const cris = Employee(
    id: 'e3',
    name: 'Cris Lara',
    phone: '+52 3',
    isActive: false,
  );

  // 2026-07-20 fue lunes; 2026-07-25, sábado.
  final monday = DateTime(2026, 7, 20);
  final saturday = DateTime(2026, 7, 25);

  BusinessAccount accountWith(List<RideSeries> series) => BusinessAccount(
        id: 'biz',
        companyName: 'Empresa',
        contactName: 'Contacto',
        city: 'CDMX',
        employees: const [ana, bea, cris],
        series: series,
      );

  const weekdayNight = RideSeries(
    id: 's-night',
    label: 'Turno noche',
    days: {1, 2, 3, 4, 5},
    pickupTime: TimeOfDay(hour: 22, minute: 0),
    originAddress: 'Planta',
    employeeIds: ['e1', 'e2'],
  );

  test('genera un traslado por empleada activa en un día que aplica', () {
    final result = RideMaterializer.materialize(
      account: accountWith([weekdayNight]),
      date: monday,
    );

    expect(result.rides.length, 2);
    expect(result.hasConflicts, isFalse);
    expect(
      result.rides.map((r) => r.employee.id),
      containsAll(['e1', 'e2']),
    );
    expect(result.rides.first.status, EmployeeRideStatus.scheduled);
  });

  test('no genera nada en un día que la serie no cubre', () {
    final result = RideMaterializer.materialize(
      account: accountWith([weekdayNight]),
      date: saturday,
    );

    expect(result.rides, isEmpty);
  });

  test('ignora las series pausadas', () {
    final result = RideMaterializer.materialize(
      account: accountWith([weekdayNight.copyWith(isActive: false)]),
      date: monday,
    );

    expect(result.rides, isEmpty);
  });

  test('excluye a las empleadas dadas de baja', () {
    final withInactive = weekdayNight.copyWith(
      employeeIds: const ['e1', 'e3'],
    );

    final result = RideMaterializer.materialize(
      account: accountWith([withInactive]),
      date: monday,
    );

    expect(result.rides.length, 1);
    expect(result.rides.single.employee.id, 'e1');
  });

  test('la hora del traslado combina la fecha con la hora de la serie', () {
    final result = RideMaterializer.materialize(
      account: accountWith([weekdayNight]),
      date: monday,
    );

    final scheduled = result.rides.first.scheduledFor;
    expect(scheduled.year, 2026);
    expect(scheduled.month, 7);
    expect(scheduled.day, 20);
    expect(scheduled.hour, 22);
    expect(scheduled.minute, 0);
  });

  test('es idempotente: dos ejecuciones dan los mismos identificadores', () {
    final account = accountWith([weekdayNight]);

    final first = RideMaterializer.materialize(account: account, date: monday);
    final second = RideMaterializer.materialize(account: account, date: monday);

    expect(
      first.rides.map((r) => r.id).toList(),
      second.rides.map((r) => r.id).toList(),
    );
  });

  group('cuando dos series reclaman a la misma empleada', () {
    const earlyShift = RideSeries(
      id: 's-early',
      label: 'Salida temprana',
      days: {1},
      pickupTime: TimeOfDay(hour: 20, minute: 30),
      originAddress: 'Planta',
      employeeIds: ['e1'],
    );

    test('genera un solo traslado, no dos', () {
      final result = RideMaterializer.materialize(
        account: accountWith([weekdayNight, earlyShift]),
        date: monday,
      );

      final anaRides = result.rides.where((r) => r.employee.id == 'e1');
      expect(anaRides.length, 1);
    });

    test('gana la salida más temprana', () {
      final result = RideMaterializer.materialize(
        account: accountWith([weekdayNight, earlyShift]),
        date: monday,
      );

      final anaRide = result.rides.firstWhere((r) => r.employee.id == 'e1');
      expect(anaRide.scheduledFor.hour, 20);
      expect(anaRide.scheduledFor.minute, 30);
    });

    test('reporta el conflicto en lugar de resolverlo en silencio', () {
      final result = RideMaterializer.materialize(
        account: accountWith([weekdayNight, earlyShift]),
        date: monday,
      );

      expect(result.hasConflicts, isTrue);
      expect(result.conflicts.single.employee.id, 'e1');
      expect(result.conflicts.single.series.length, 2);
      expect(result.conflicts.single.resolvedTo.id, 's-early');
    });

    test('las demás empleadas no se ven afectadas', () {
      final result = RideMaterializer.materialize(
        account: accountWith([weekdayNight, earlyShift]),
        date: monday,
      );

      final beaRide = result.rides.firstWhere((r) => r.employee.id == 'e2');
      expect(beaRide.scheduledFor.hour, 22);
    });
  });

  test('los traslados salen ordenados por hora', () {
    const lateShift = RideSeries(
      id: 's-late',
      label: 'Cierre',
      days: {1},
      pickupTime: TimeOfDay(hour: 23, minute: 30),
      originAddress: 'Planta',
      employeeIds: ['e2'],
    );
    final earlyOnly = weekdayNight.copyWith(employeeIds: const ['e1']);

    final result = RideMaterializer.materialize(
      account: accountWith([lateShift, earlyOnly]),
      date: monday,
    );

    expect(result.rides.first.employee.id, 'e1');
    expect(result.rides.last.employee.id, 'e2');
  });

  test('una empresa sin programaciones no produce traslados', () {
    final result = RideMaterializer.materialize(
      account: accountWith([]),
      date: monday,
    );

    expect(result, same(MaterializationResult.empty));
  });
}
