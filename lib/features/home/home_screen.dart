import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/taylor_theme.dart';
import '../../data/models/trip.dart';
import '../../data/session_controller.dart';
import 'ride_controller.dart';
import 'widgets/driver_assigned_card.dart';
import 'widgets/map_view.dart';
import 'widgets/ride_request_sheet.dart';
import 'widgets/searching_driver_card.dart';

/// Pantalla de Inicio: el mapa ocupa todo y las tarjetas flotan encima.
///
/// La tarjeta inferior cambia según el estado del viaje. Todas comparten
/// posición y forma, así que la transición entre "pedir", "buscando" y
/// "conductora asignada" se lee como una sola superficie que se transforma,
/// no como tres pantallas distintas.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).user;
    final trip = ref.watch(rideControllerProvider);

    return Stack(
      children: [
        Positioned.fill(child: MapView(trip: trip)),

        // Degradado superior: da contraste al saludo sobre un mapa claro.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0.9),
                    Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0),
                  ],
                ),
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
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (trip?.status) {
              null || TripStatus.completed || TripStatus.cancelled =>
                RideRequestSheet(
                  key: const ValueKey('request'),
                  userName: user?.firstName ?? '',
                  onRequest: (origin, destination) => ref
                      .read(rideControllerProvider.notifier)
                      .requestRide(origin: origin, destination: destination),
                ),
              TripStatus.searching => SearchingDriverCard(
                  key: const ValueKey('searching'),
                  onCancel: () =>
                      ref.read(rideControllerProvider.notifier).cancel(),
                ),
              _ => DriverAssignedCard(
                  key: const ValueKey('assigned'),
                  trip: trip!,
                  onCancel: () =>
                      ref.read(rideControllerProvider.notifier).cancel(),
                ),
            },
          ),
        ),
      ],
    );
  }
}
