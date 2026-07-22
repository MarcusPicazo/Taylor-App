import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart' show TimeOfDay;

import 'models/business_account.dart';
import 'models/driver_profile.dart';
import 'models/taylor_user.dart';
import 'models/trip.dart';

/// Datos de la cuenta de demostración que se enseña a clientes.
///
/// Vive aparte del resto de la app a propósito: nunca escribe en Firestore, y
/// borrar este archivo desactiva el modo demo por completo.
abstract final class TaylorDemo {
  static const String email = 'test@taylor.com';
  static const String password = 'Taylor123';

  /// Código de acceso B2B de exhibición. En producción el equipo de Taylor
  /// genera uno por empresa; este existe solo para poder enseñar el flujo sin
  /// tener que aprobar una solicitud real.
  static const String businessCode = 'Taylor123';

  static bool matches(String inputEmail, String inputPassword) {
    return inputEmail.trim().toLowerCase() == email &&
        inputPassword == password;
  }

  static const TaylorUser user = TaylorUser(
    id: 'demo-user',
    fullName: 'Valentina Ruiz',
    email: email,
    phoneNumber: '55 1234 5678',
    countryCode: 'MX',
    stage: VerificationStage.verified,
    isDemoAccount: true,
    emergencyContacts: [
      EmergencyContact(
        id: 'c1',
        name: 'Mariana Ruiz',
        phone: '+52 55 8765 4321',
        relationship: 'Hermana',
      ),
      EmergencyContact(
        id: 'c2',
        name: 'Sofía Delgado',
        phone: '+52 55 2233 4455',
        relationship: 'Mejor amiga',
      ),
    ],
  );

  static const List<TaylorDriver> drivers = [
    TaylorDriver(
      id: 'd1',
      name: 'Ana Lucía Moreno',
      rating: 4.96,
      tripCount: 1842,
      carModel: 'Nissan Versa · Blanco',
      plate: 'TYL-482-A',
      yearsWithTaylor: 3,
    ),
    TaylorDriver(
      id: 'd2',
      name: 'Regina Castillo',
      rating: 4.91,
      tripCount: 963,
      carModel: 'Kia Rio · Gris',
      plate: 'TYL-119-C',
      yearsWithTaylor: 2,
    ),
  ];

  // --- Cuenta empresarial de exhibición -----------------------------------

  static const List<Employee> _employees = [
    Employee(
      id: 'emp1',
      name: 'Karla Jiménez',
      phone: '+52 55 1122 3344',
      department: 'Producción',
      homeArea: 'Iztapalapa',
    ),
    Employee(
      id: 'emp2',
      name: 'Diana Salazar',
      phone: '+52 55 2233 4455',
      department: 'Producción',
      homeArea: 'Coyoacán',
    ),
    Employee(
      id: 'emp3',
      name: 'Fernanda Ríos',
      phone: '+52 55 3344 5566',
      department: 'Calidad',
      homeArea: 'Tlalpan',
    ),
    Employee(
      id: 'emp4',
      name: 'Paola Márquez',
      phone: '+52 55 4455 6677',
      department: 'Logística',
      homeArea: 'Azcapotzalco',
    ),
    Employee(
      id: 'emp5',
      name: 'Brenda Ocampo',
      phone: '+52 55 5566 7788',
      department: 'Producción',
      homeArea: 'Gustavo A. Madero',
    ),
    Employee(
      id: 'emp6',
      name: 'Alejandra Vega',
      phone: '+52 55 6677 8899',
      department: 'Administración',
      homeArea: 'Benito Juárez',
    ),
  ];

  static const String _plantAddress = 'Planta Vallejo, Av. Ceylán 450';

  static BusinessAccount businessAccount() {
    return const BusinessAccount(
      id: 'biz-demo',
      companyName: 'Grupo Monreal',
      contactName: 'Demian Monreal',
      city: 'Ciudad de México',
      employees: _employees,
      monthToDateSpend: 18420.00,
      monthToDateRides: 132,
      series: [
        RideSeries(
          id: 'series-night',
          label: 'Salida nocturna · Turno B',
          days: {1, 2, 3, 4, 5},
          pickupTime: TimeOfDay(hour: 22, minute: 0),
          originAddress: _plantAddress,
          employeeIds: ['emp1', 'emp2', 'emp3', 'emp5'],
        ),
        RideSeries(
          id: 'series-weekend',
          label: 'Cierre de fin de semana',
          days: {6},
          pickupTime: TimeOfDay(hour: 23, minute: 30),
          originAddress: _plantAddress,
          employeeIds: ['emp4', 'emp6'],
        ),
      ],
    );
  }

  /// Traslados de esta noche, en distintos estados.
  ///
  /// La mezcla es deliberada: una ya llegó, dos van en camino, una sin
  /// asignar y una que no se presentó. Enseña de un vistazo para qué sirve el
  /// panel, en lugar de una lista uniforme que no comunica nada.
  static List<EmployeeRide> tonightRides() {
    final now = DateTime.now();
    final pickup = DateTime(now.year, now.month, now.day, 22);

    return [
      EmployeeRide(
        id: 'ride1',
        employee: _employees[0],
        status: EmployeeRideStatus.arrived,
        scheduledFor: pickup,
        driverName: 'Ana Lucía M.',
        arrivedAt: now.subtract(const Duration(minutes: 12)),
        fare: 168.00,
      ),
      EmployeeRide(
        id: 'ride2',
        employee: _employees[1],
        status: EmployeeRideStatus.inTransit,
        scheduledFor: pickup,
        driverName: 'Regina C.',
        etaMinutes: 14,
        fare: 142.00,
      ),
      EmployeeRide(
        id: 'ride3',
        employee: _employees[2],
        status: EmployeeRideStatus.driverAssigned,
        scheduledFor: pickup,
        driverName: 'Mariana T.',
        etaMinutes: 3,
        fare: 195.00,
      ),
      EmployeeRide(
        id: 'ride4',
        employee: _employees[4],
        status: EmployeeRideStatus.assigning,
        scheduledFor: pickup,
        fare: 210.00,
      ),
      EmployeeRide(
        id: 'ride5',
        employee: _employees[3],
        status: EmployeeRideStatus.noShow,
        scheduledFor: pickup,
      ),
    ];
  }

  /// Perfil de conductora aprobada para la cuenta de exhibición.
  ///
  /// La misma cuenta demo puede alternar entre pasajera y conductora. En
  /// producción son roles independientes, pero para enseñar el producto a un
  /// cliente conviene poder recorrer los dos lados sin cerrar sesión.
  static DriverProfile driverProfile() {
    final now = DateTime.now();

    return DriverProfile(
      status: DriverApplicationStatus.approved,
      rating: 4.93,
      totalTrips: 1247,
      acceptanceRate: 0.94,
      submittedAt: now.subtract(const Duration(days: 420)),
      vehicle: const Vehicle(
        make: 'Nissan',
        model: 'Versa',
        year: 2022,
        color: 'Blanco',
        plate: 'TYL-482-A',
      ),
      earnings: _demoEarnings(now),
    );
  }

  /// Ganancias de los últimos días, con más viajes en horario nocturno:
  /// es cuando la demanda de Taylor se concentra.
  static List<EarningEntry> _demoEarnings(DateTime now) {
    const shape = [
      // (horas atrás, bruto, propina, km)
      (2, 154.00, 30.0, 5.1),
      (5, 128.50, 0.0, 4.2),
      (8, 212.00, 40.0, 8.6),
      (26, 142.00, 20.0, 4.4),
      (30, 189.50, 0.0, 7.1),
      (52, 315.00, 50.0, 14.8),
      (76, 96.00, 15.0, 2.9),
      (98, 174.00, 0.0, 6.2),
    ];

    // Taylor retiene 18 %, por debajo del estándar del sector: parte del
    // modelo económico de la marca es que la conductora se quede con más.
    const commissionRate = 0.18;

    return [
      for (var i = 0; i < shape.length; i++)
        EarningEntry(
          tripId: 'e$i',
          completedAt: now.subtract(Duration(hours: shape[i].$1)),
          gross: shape[i].$2,
          commission: shape[i].$2 * commissionRate,
          tip: shape[i].$3,
          distanceKm: shape[i].$4,
        ),
    ];
  }

  /// Historial de ejemplo. Las fechas son relativas a "ahora" para que la
  /// demo nunca se vea vieja, sin importar cuándo se enseñe.
  static List<Trip> trips() {
    final now = DateTime.now();
    return [
      Trip(
        id: 't1',
        origin: const TripLocation(
          label: 'Casa',
          address: 'Av. Amsterdam 240, Condesa',
          position: LatLng(19.4110, -99.1710),
        ),
        destination: const TripLocation(
          label: 'Oficina',
          address: 'Torre Reforma, Paseo de la Reforma 483',
          position: LatLng(19.4260, -99.1677),
        ),
        status: TripStatus.completed,
        requestedAt: now.subtract(const Duration(hours: 5)),
        driver: drivers[0],
        fare: 128.50,
        distanceKm: 4.2,
        durationMinutes: 18,
        rating: 5,
      ),
      Trip(
        id: 't2',
        origin: const TripLocation(
          label: 'Oficina',
          address: 'Torre Reforma, Paseo de la Reforma 483',
          position: LatLng(19.4260, -99.1677),
        ),
        destination: const TripLocation(
          label: 'Casa',
          address: 'Av. Amsterdam 240, Condesa',
          position: LatLng(19.4110, -99.1710),
        ),
        status: TripStatus.completed,
        requestedAt: now.subtract(const Duration(days: 1, hours: 3)),
        driver: drivers[1],
        fare: 142.00,
        distanceKm: 4.4,
        durationMinutes: 23,
        rating: 5,
      ),
      Trip(
        id: 't3',
        origin: const TripLocation(
          label: 'Aeropuerto',
          address: 'AICM Terminal 2',
          position: LatLng(19.4361, -99.0719),
        ),
        destination: const TripLocation(
          label: 'Casa',
          address: 'Av. Amsterdam 240, Condesa',
          position: LatLng(19.4110, -99.1710),
        ),
        status: TripStatus.completed,
        requestedAt: now.subtract(const Duration(days: 6)),
        driver: drivers[0],
        fare: 315.00,
        distanceKm: 14.8,
        durationMinutes: 41,
        rating: 4,
      ),
    ];
  }
}
