import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_theme.dart';
import '../home/widgets/map_view.dart';
import 'driver_controller.dart';
import 'widgets/active_trip_panel.dart';
import 'widgets/incoming_request_card.dart';
import 'widgets/online_toggle.dart';
import 'widgets/trip_summary_card.dart';

/// Pantalla principal del modo conductora.
///
/// Todo el diseño de esta sección parte de una restricción que la app de
/// pasajera no tiene: **se usa al volante**. Por eso los controles son mucho
/// más grandes, las acciones se confirman deslizando en lugar de tocando, y
/// cada estado muestra una sola acción posible. Leer una pantalla densa
/// mientras se conduce no es una opción.
class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverControllerProvider);
    final controller = ref.read(driverControllerProvider.notifier);

    return Stack(
      children: [
        Positioned.fill(child: MapView(trip: driver.activeTrip)),

        // Estado de conexión, arriba y siempre visible.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(TaylorSpacing.md),
              child: OnlineToggle(
                isOnline: driver.isOnline,
                // Desconectarse a mitad de un viaje dejaría a la pasajera sin
                // conductora, así que el control se bloquea hasta terminar.
                enabled: !driver.hasActiveTrip,
                onChanged: (online) {
                  if (online) {
                    controller.goOnline();
                  } else {
                    controller.goOffline();
                  }
                },
              ),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: TaylorSpacing.navBarClearance - 12,
          child: AnimatedSwitcher(
            duration: TaylorMotion.normal,
            switchInCurve: TaylorMotion.emphasized,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.14),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _buildPanel(driver, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(DriverState driver, DriverController controller) {
    // El orden de las comprobaciones es la prioridad de atención: un resumen
    // pendiente primero, luego el viaje en curso, luego una solicitud nueva.
    if (driver.phase == DriverTripPhase.completed &&
        driver.activeTrip != null) {
      return TripSummaryCard(
        key: const ValueKey('summary'),
        trip: driver.activeTrip!,
        onDismiss: controller.dismissSummary,
      );
    }

    if (driver.hasActiveTrip && driver.phase != null) {
      return ActiveTripPanel(
        key: const ValueKey('active'),
        trip: driver.activeTrip!,
        phase: driver.phase!,
        onArrived: controller.markArrived,
        onStart: controller.startTrip,
        onComplete: controller.completeTrip,
      );
    }

    if (driver.incomingRequest != null) {
      return IncomingRequestCard(
        key: const ValueKey('incoming'),
        request: driver.incomingRequest!,
        onAccept: controller.acceptRequest,
        onDecline: controller.declineRequest,
      );
    }

    return const SizedBox.shrink(key: ValueKey('idle'));
  }
}
