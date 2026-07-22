import 'package:flutter/material.dart' show TimeOfDay;

/// Una empleada que la empresa puede transportar.
///
/// El área de destino se guarda a nivel de zona, no de domicilio exacto: la
/// coordinadora necesita planificar rutas, pero la dirección de casa de una
/// empleada no tiene por qué ser visible para su empleador. La dirección real
/// solo la conoce Taylor y la conductora asignada.
class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.phone,
    this.department,
    this.homeArea,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String phone;
  final String? department;

  /// Zona aproximada de destino ("Coyoacán", "Iztapalapa").
  final String? homeArea;

  final bool isActive;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Employee copyWith({bool? isActive}) => Employee(
        id: id,
        name: name,
        phone: phone,
        department: department,
        homeArea: homeArea,
        isActive: isActive ?? this.isActive,
      );
}

/// Una programación recurrente: "de lunes a viernes, a las 22:00, estas
/// empleadas salen desde la planta".
class RideSeries {
  const RideSeries({
    required this.id,
    required this.label,
    required this.days,
    required this.pickupTime,
    required this.originAddress,
    required this.employeeIds,
    this.isActive = true,
  });

  final String id;
  final String label;

  /// Días activos, convención de DateTime: 1 = lunes … 7 = domingo.
  final Set<int> days;

  final TimeOfDay pickupTime;
  final String originAddress;
  final List<String> employeeIds;
  final bool isActive;

  bool runsOn(int weekday) => isActive && days.contains(weekday);

  RideSeries copyWith({
    String? label,
    Set<int>? days,
    TimeOfDay? pickupTime,
    List<String>? employeeIds,
    bool? isActive,
  }) {
    return RideSeries(
      id: id,
      label: label ?? this.label,
      days: days ?? this.days,
      pickupTime: pickupTime ?? this.pickupTime,
      originAddress: originAddress,
      employeeIds: employeeIds ?? this.employeeIds,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Estado de una empleada dentro de un traslado concreto.
///
/// El estado que importa de verdad es [arrived]: la responsabilidad de la
/// empresa no termina cuando la empleada se sube al coche, termina cuando
/// llega a su casa.
enum EmployeeRideStatus {
  /// Programada, aún no empieza.
  scheduled,

  /// Buscando conductora.
  assigning,

  /// Conductora en camino al punto de encuentro.
  driverAssigned,

  /// En ruta a casa.
  inTransit,

  /// Llegó a su destino.
  arrived,

  /// No se presentó al punto de encuentro.
  noShow,

  /// Cancelada.
  cancelled,
}

extension EmployeeRideStatusX on EmployeeRideStatus {
  /// Si sigue en curso y por tanto requiere atención de la coordinadora.
  bool get isOpen => switch (this) {
        EmployeeRideStatus.assigning ||
        EmployeeRideStatus.driverAssigned ||
        EmployeeRideStatus.inTransit =>
          true,
        _ => false,
      };

  bool get needsAttention => this == EmployeeRideStatus.noShow;
}

/// Un traslado individual de una empleada en una noche concreta.
class EmployeeRide {
  const EmployeeRide({
    required this.id,
    required this.employee,
    required this.status,
    required this.scheduledFor,
    this.driverName,
    this.etaMinutes,
    this.arrivedAt,
    this.fare,
  });

  final String id;
  final Employee employee;
  final EmployeeRideStatus status;
  final DateTime scheduledFor;
  final String? driverName;
  final int? etaMinutes;
  final DateTime? arrivedAt;
  final double? fare;

  EmployeeRide copyWith({
    EmployeeRideStatus? status,
    String? driverName,
    int? etaMinutes,
    DateTime? arrivedAt,
  }) {
    return EmployeeRide(
      id: id,
      employee: employee,
      status: status ?? this.status,
      scheduledFor: scheduledFor,
      driverName: driverName ?? this.driverName,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      fare: fare,
    );
  }
}

/// La cuenta empresarial completa.
class BusinessAccount {
  const BusinessAccount({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.city,
    this.employees = const [],
    this.series = const [],
    this.monthToDateSpend = 0,
    this.monthToDateRides = 0,
  });

  final String id;
  final String companyName;
  final String contactName;
  final String city;
  final List<Employee> employees;
  final List<RideSeries> series;
  final double monthToDateSpend;
  final int monthToDateRides;

  List<Employee> get activeEmployees =>
      employees.where((e) => e.isActive).toList(growable: false);

  Employee? employeeById(String id) {
    for (final employee in employees) {
      if (employee.id == id) return employee;
    }
    return null;
  }

  /// Series que corren hoy.
  List<RideSeries> seriesForToday(DateTime now) => series
      .where((s) => s.runsOn(now.weekday))
      .toList(growable: false);

  BusinessAccount copyWith({
    List<Employee>? employees,
    List<RideSeries>? series,
  }) {
    return BusinessAccount(
      id: id,
      companyName: companyName,
      contactName: contactName,
      city: city,
      employees: employees ?? this.employees,
      series: series ?? this.series,
      monthToDateSpend: monthToDateSpend,
      monthToDateRides: monthToDateRides,
    );
  }
}
