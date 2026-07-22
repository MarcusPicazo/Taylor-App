import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_mode.dart';
import '../../data/models/chat_message.dart';
import '../driver/driver_controller.dart';
import '../home/ride_controller.dart';
import 'chat_screen.dart';

/// Resuelve qué chat mostrar según quién está usando la app.
///
/// El chat es el mismo para ambas partes, pero el rol cambia de qué lado se
/// pintan los mensajes, qué respuestas rápidas se ofrecen y si el teclado
/// está disponible. Resolverlo aquí —y no pasarlo por parámetro de ruta—
/// evita que el rol pueda quedar desincronizado del modo real de la app.
class TripChatRoute extends ConsumerWidget {
  const TripChatRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    if (mode == AppMode.driver) {
      final driver = ref.watch(driverControllerProvider);
      final trip = driver.activeTrip;
      if (trip == null) return const _NoActiveTrip();

      return ChatScreen(
        tripId: trip.id,
        role: ChatSender.driver,
        otherPartyName: driver.incomingRequest?.passengerName ?? 'Pasajera',
        // El teclado solo se bloquea con el coche efectivamente en ruta.
        // Mientras espera en el punto de encuentro está detenida y puede
        // escribir sin riesgo; bloquearlo también ahí sería paternalista.
        keyboardLocked: driver.phase == DriverTripPhase.inTransit,
      );
    }

    final trip = ref.watch(rideControllerProvider);
    if (trip == null || !trip.isActive) return const _NoActiveTrip();

    return ChatScreen(
      tripId: trip.id,
      role: ChatSender.passenger,
      otherPartyName: trip.driver?.name ?? '',
    );
  }
}

/// Sin viaje activo no hay conversación posible: el chat de Taylor está atado
/// al viaje y no existe fuera de él.
class _NoActiveTrip extends StatelessWidget {
  const _NoActiveTrip();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
