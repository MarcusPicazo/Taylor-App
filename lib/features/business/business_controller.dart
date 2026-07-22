import 'dart:async';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/notifications/taylor_notifications.dart';
import '../../data/models/business_account.dart';

/// Cuenta empresarial activa.
final businessAccountProvider =
    StateNotifierProvider<BusinessController, BusinessAccount?>(
  (ref) => BusinessController(),
);

class BusinessController extends StateNotifier<BusinessAccount?> {
  BusinessController() : super(null);

  void load(BusinessAccount account) => state = account;

  void clear() => state = null;

  void addEmployee({
    required String name,
    required String phone,
    String? department,
    String? homeArea,
  }) {
    final account = state;
    if (account == null) return;

    state = account.copyWith(
      employees: [
        ...account.employees,
        Employee(
          id: const Uuid().v4(),
          name: name,
          phone: phone,
          department: department,
          homeArea: homeArea,
        ),
      ],
    );
  }

  /// Desactiva en lugar de borrar.
  ///
  /// Una empleada que sale de la empresa debe dejar de poder pedir viajes, pero
  /// su historial de traslados sigue siendo parte de la facturación y del
  /// registro de seguridad. Borrarla dejaría huecos en ambos.
  void setEmployeeActive(String employeeId, bool isActive) {
    final account = state;
    if (account == null) return;

    state = account.copyWith(
      employees: [
        for (final employee in account.employees)
          if (employee.id == employeeId)
            employee.copyWith(isActive: isActive)
          else
            employee,
      ],
    );
  }

  void saveSeries(RideSeries series) {
    final account = state;
    if (account == null) return;

    final existing =
        account.series.indexWhere((s) => s.id == series.id);

    state = account.copyWith(
      series: existing >= 0
          ? [
              for (var i = 0; i < account.series.length; i++)
                i == existing ? series : account.series[i],
            ]
          : [...account.series, series],
    );
  }

  void deleteSeries(String seriesId) {
    final account = state;
    if (account == null) return;

    state = account.copyWith(
      series: account.series
          .where((s) => s.id != seriesId)
          .toList(growable: false),
    );
  }

  void toggleSeriesActive(String seriesId) {
    final account = state;
    if (account == null) return;

    state = account.copyWith(
      series: [
        for (final s in account.series)
          if (s.id == seriesId) s.copyWith(isActive: !s.isActive) else s,
      ],
    );
  }
}

/// Traslados de esta noche, con su estado en vivo.
///
/// Es el corazón del panel: la coordinadora quiere saber, ahora mismo, quién
/// sigue fuera. Los traslados avanzan solos por temporizador mientras no haya
/// backend; después se sustituye por un stream de Firestore.
final tonightRidesProvider =
    StateNotifierProvider<TonightRidesController, List<EmployeeRide>>(
  (ref) => TonightRidesController(),
);

class TonightRidesController extends StateNotifier<List<EmployeeRide>> {
  TonightRidesController() : super(const []);

  Timer? _ticker;

  void load(List<EmployeeRide> rides) {
    state = rides;
    _startSimulation();
  }

  /// Hace avanzar un traslado abierto cada pocos segundos, para que el panel
  /// se vea vivo durante una demostración.
  void _startSimulation() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 6), (_) {
      final open = state.where((r) => r.status.isOpen).toList();
      if (open.isEmpty) {
        _ticker?.cancel();
        return;
      }

      final target = open.first;
      state = [
        for (final ride in state)
          if (ride.id == target.id) _advance(ride) else ride,
      ];

      _notifyIfEveryoneHome();
    });
  }

  /// Avisa cuando ya no queda nadie fuera.
  ///
  /// Este es el aviso que justifica el panel: la coordinadora no debería tener
  /// que mirar la pantalla para saber que su equipo llegó. Se emite una sola
  /// vez por noche — repetirlo lo convertiría en ruido y dejaría de leerse.
  bool _everyoneHomeNotified = false;

  void _notifyIfEveryoneHome() {
    if (_everyoneHomeNotified) return;

    final total = state.length;
    final arrived =
        state.where((r) => r.status == EmployeeRideStatus.arrived).length;
    if (total == 0 || arrived != total) return;

    _everyoneHomeNotified = true;
    TaylorNotifications.instance.showBusinessAlert(
      title: 'Todas en casa',
      body: 'Los $total traslados de esta noche terminaron bien.',
    );
  }

  /// Alerta de que alguien no se presentó al punto de encuentro.
  void reportNoShow(String rideId) {
    final matches = state.where((r) => r.id == rideId);
    if (matches.isEmpty) return;
    final ride = matches.first;

    state = [
      for (final r in state)
        if (r.id == rideId)
          r.copyWith(status: EmployeeRideStatus.noShow)
        else
          r,
    ];

    TaylorNotifications.instance.showBusinessAlert(
      title: '${ride.employee.name} no se presentó',
      body: 'No llegó al punto de encuentro de las '
          '${ride.scheduledFor.hour.toString().padLeft(2, '0')}:'
          '${ride.scheduledFor.minute.toString().padLeft(2, '0')}. '
          'Conviene contactarla.',
      urgent: true,
    );
  }

  EmployeeRide _advance(EmployeeRide ride) => switch (ride.status) {
        EmployeeRideStatus.assigning => ride.copyWith(
            status: EmployeeRideStatus.driverAssigned,
            driverName: 'Ana Lucía M.',
            etaMinutes: 4,
          ),
        EmployeeRideStatus.driverAssigned =>
          ride.copyWith(status: EmployeeRideStatus.inTransit, etaMinutes: 17),
        EmployeeRideStatus.inTransit => ride.copyWith(
            status: EmployeeRideStatus.arrived,
            arrivedAt: DateTime.now(),
          ),
        _ => ride,
      };

  void clear() {
    _ticker?.cancel();
    state = const [];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Resumen de la noche, derivado de los traslados.
///
/// Se calcula aquí y no en la pantalla para que el mismo recuento lo puedan
/// consumir el panel, una futura notificación y el reporte por correo sin
/// arriesgarse a que cada uno cuente distinto.
class TonightSummary {
  const TonightSummary({
    required this.total,
    required this.arrived,
    required this.open,
    required this.needsAttention,
  });

  final int total;
  final int arrived;
  final int open;
  final int needsAttention;

  /// Todas llegaron: no queda nadie en tránsito ni pendiente.
  bool get everyoneHome => total > 0 && arrived == total;

  double get progress => total == 0 ? 0 : arrived / total;
}

final tonightSummaryProvider = Provider<TonightSummary>((ref) {
  final rides = ref.watch(tonightRidesProvider);

  return TonightSummary(
    total: rides.length,
    arrived:
        rides.where((r) => r.status == EmployeeRideStatus.arrived).length,
    open: rides.where((r) => r.status.isOpen).length,
    needsAttention:
        rides.where((r) => r.status.needsAttention).length,
  );
});

/// Construye una serie nueva con identificador propio.
RideSeries newSeries({
  required String label,
  required Set<int> days,
  required TimeOfDay pickupTime,
  required String originAddress,
  required List<String> employeeIds,
}) {
  return RideSeries(
    id: const Uuid().v4(),
    label: label,
    days: days,
    pickupTime: pickupTime,
    originAddress: originAddress,
    employeeIds: employeeIds,
  );
}
