import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:taylor/data/models/business_account.dart';
import 'package:taylor/features/business/business_controller.dart';

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  const ana = Employee(id: 'e1', name: 'Ana Ruiz', phone: '+52 1');
  const bea = Employee(id: 'e2', name: 'Bea Soto', phone: '+52 2');

  const nightShift = RideSeries(
    id: 's1',
    label: 'Turno noche',
    days: {1, 2, 3, 4, 5},
    pickupTime: TimeOfDay(hour: 22, minute: 0),
    originAddress: 'Planta',
    employeeIds: ['e1', 'e2'],
  );

  const account = BusinessAccount(
    id: 'biz',
    companyName: 'Empresa',
    contactName: 'Contacto',
    city: 'CDMX',
    employees: [ana, bea],
    series: [nightShift],
  );

  // 2026-07-20 fue lunes.
  final monday = DateTime(2026, 7, 20);

  BusinessController controller() {
    final c = BusinessController();
    addTearDown(c.dispose);
    c.load(account);
    return c;
  }

  group('padrón de empleadas', () {
    test('agregar una la añade activa', () {
      final c = controller();

      c.addEmployee(name: 'Cris Lara', phone: '+52 3', department: 'Calidad');

      expect(c.state!.employees.length, 3);
      expect(c.state!.activeEmployees.length, 3);
      expect(c.state!.employees.last.name, 'Cris Lara');
    });

    test('dar de baja NO borra: desactiva', () {
      final c = controller();

      c.setEmployeeActive('e1', false);

      // El historial de traslados de una empleada sigue siendo parte de la
      // facturación y del registro de seguridad. Borrarla dejaría huecos en
      // ambos.
      expect(c.state!.employees.length, 2);
      expect(c.state!.activeEmployees.length, 1);
      expect(
        c.state!.employeeById('e1')!.isActive,
        isFalse,
      );
    });

    test('se puede reactivar', () {
      final c = controller();

      c.setEmployeeActive('e1', false);
      c.setEmployeeActive('e1', true);

      expect(c.state!.activeEmployees.length, 2);
    });
  });

  group('programaciones', () {
    test('guardar una serie con id existente la actualiza, no la duplica', () {
      final c = controller();

      c.saveSeries(nightShift.copyWith(label: 'Turno noche · B'));

      expect(c.state!.series.length, 1);
      expect(c.state!.series.single.label, 'Turno noche · B');
    });

    test('guardar una serie nueva la añade', () {
      final c = controller();

      c.saveSeries(
        newSeries(
          label: 'Fin de semana',
          days: {6},
          pickupTime: const TimeOfDay(hour: 23, minute: 0),
          originAddress: 'Planta',
          employeeIds: ['e1'],
        ),
      );

      expect(c.state!.series.length, 2);
    });

    test('eliminar quita solo esa serie', () {
      final c = controller();
      c.saveSeries(
        newSeries(
          label: 'Otra',
          days: {6},
          pickupTime: const TimeOfDay(hour: 23, minute: 0),
          originAddress: 'Planta',
          employeeIds: ['e1'],
        ),
      );

      c.deleteSeries('s1');

      expect(c.state!.series.length, 1);
      expect(c.state!.series.single.label, 'Otra');
    });

    test('pausar una serie la mantiene pero inactiva', () {
      final c = controller();

      c.toggleSeriesActive('s1');

      expect(c.state!.series.length, 1);
      expect(c.state!.series.single.isActive, isFalse);
    });
  });

  group('traslados de la noche', () {
    TonightRidesController rides() {
      final c = TonightRidesController();
      addTearDown(c.dispose);
      return c;
    }

    test('materializar genera un traslado por empleada activa', () {
      final c = rides();

      c.materialize(account: account, date: monday);

      expect(c.state.length, 2);
      expect(c.state.every((r) => r.status == EmployeeRideStatus.scheduled),
          isTrue);
    });

    test('materializar de nuevo NO reinicia los que ya van en camino', () {
      final c = rides();
      c.materialize(account: account, date: monday);

      // Una empleada ya subió al coche.
      final inTransitId = c.state.first.id;
      c.load([
        for (final r in c.state)
          if (r.id == inTransitId)
            r.copyWith(
              status: EmployeeRideStatus.inTransit,
              driverName: 'Regina C.',
            )
          else
            r,
      ]);

      c.materialize(account: account, date: monday);

      // Este es el invariante que hace segura la re-materialización: los
      // identificadores son deterministas y el controlador fusiona en lugar
      // de reemplazar.
      final preserved = c.state.firstWhere((r) => r.id == inTransitId);
      expect(preserved.status, EmployeeRideStatus.inTransit);
      expect(preserved.driverName, 'Regina C.');
      expect(c.state.length, 2);
    });

    test('marcar una ausencia cambia el estado de ese traslado', () {
      final c = rides();
      c.materialize(account: account, date: monday);
      final target = c.state.first.id;

      c.reportNoShow(target);

      expect(
        c.state.firstWhere((r) => r.id == target).status,
        EmployeeRideStatus.noShow,
      );
    });

    test('limpiar vacía la lista', () {
      final c = rides();
      c.materialize(account: account, date: monday);

      c.clear();

      expect(c.state, isEmpty);
    });
  });
}
