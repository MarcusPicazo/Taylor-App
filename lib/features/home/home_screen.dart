import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/location/location_service.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/models/ride_tier.dart';
import '../../data/models/trip.dart';
import '../../data/places_repository.dart';
import '../../data/recent_destinations.dart';
import '../../data/session_controller.dart';
import '../trips/rating_card.dart';
import 'destination_search_screen.dart';
import 'ride_controller.dart';
import 'widgets/driver_assigned_card.dart';
import 'widgets/home_sheet.dart';
import 'widgets/map_view.dart';
import 'widgets/recenter_button.dart';
import 'widgets/ride_confirm_sheet.dart';
import 'widgets/searching_driver_card.dart';

/// Pantalla de Inicio: el mapa ocupa todo y los paneles flotan encima.
///
/// El panel inferior cambia según el momento del flujo, y todos comparten
/// posición y forma para que la transición se lea como una sola superficie que
/// se transforma, no como pantallas distintas:
///
///   sin destino  →  destino elegido  →  buscando  →  en viaje  →  calificar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _mapKey = GlobalKey<MapViewState>();

  PlaceSuggestion? _destination;
  RideTier _tier = RideTier.go;

  @override
  void initState() {
    super.initState();
    // El permiso se pide al abrir el mapa, no al arrancar la app: aquí la
    // petición se explica sola. Y si lo deniega, la pantalla sigue siendo
    // usable — puede escribir su destino igual.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationControllerProvider.notifier).ensurePermissionAndLocate();
    });
  }

  Future<void> _openSearch() async {
    final result = await Navigator.of(context).push<PlaceSuggestion>(
      MaterialPageRoute(builder: (_) => const DestinationSearchScreen()),
    );
    if (result == null || !mounted) return;
    _selectDestination(result);
  }

  void _selectDestination(PlaceSuggestion place) {
    // Se registra al elegirlo, no al terminar el viaje: aunque cancele, ya
    // demostró interés en ese lugar y es probable que vuelva a buscarlo.
    ref.read(recentDestinationsProvider.notifier).remember(place);
    setState(() => _destination = place);
  }

  void _pickSavedPlace(bool isHome) {
    _selectDestination(
      isHome
          ? const PlaceSuggestion(
              name: 'Casa',
              address: 'Av. Amsterdam 240, Condesa',
              position: LatLng(19.4110, -99.1710),
              isSaved: true,
            )
          : const PlaceSuggestion(
              name: 'Oficina',
              address: 'Torre Reforma, Paseo de la Reforma 483',
              position: LatLng(19.4260, -99.1677),
              isSaved: true,
            ),
    );
  }

  Future<void> _recenter() async {
    // Se mueve YA con la última posición conocida, y solo después se pide una
    // lectura fresca. Antes se esperaba al GPS antes de mover la cámara, y
    // bajo techo eso tardaba segundos: el botón parecía roto.
    final controller = ref.read(locationControllerProvider.notifier);
    final known = ref.read(locationControllerProvider).position;

    if (known != null) {
      await _mapKey.currentState?.moveTo(known);
    }

    await controller.refreshPosition();

    // Si la lectura nueva difiere de la que ya usamos, se ajusta. Suele ser
    // un movimiento de pocos metros, casi imperceptible.
    final fresh = ref.read(locationControllerProvider).position;
    if (fresh != null && fresh != known) {
      await _mapKey.currentState?.moveTo(fresh);
    }
  }

  void _confirmRide() {
    final destination = _destination;
    if (destination == null) return;

    final origin = ref.read(locationControllerProvider.notifier);

    ref.read(rideControllerProvider.notifier).requestRide(
          origin: TripLocation(
            label: 'Origen',
            address: 'Tu ubicación',
            position: origin.positionOrFallback,
          ),
          destination: TripLocation(
            label: destination.name,
            address: destination.address,
            position: destination.position,
          ),
        );

    setState(() => _destination = null);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionControllerProvider).user;
    final trip = ref.watch(rideControllerProvider);
    final location = ref.watch(locationControllerProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: MapView(
            key: _mapKey,
            trip: trip,
            origin: trip == null ? location.position : null,
            destination: trip == null ? _destination?.position : null,
            showMyLocation: location.isGranted,
          ),
        ),

        // Velo superior: da contraste al contenido sobre un mapa claro.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 140,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0.75),
                    Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Recentrar. Se eleva según lo alto que esté el panel de abajo, para
        // no quedar nunca escondido detrás. Antes tenía una posición fija
        // calculada para el panel plegado, así que el de tarifas —mucho más
        // alto— lo tapaba por completo.
        AnimatedPositioned(
          duration: TaylorMotion.normal,
          curve: TaylorMotion.emphasized,
          right: TaylorSpacing.md,
          bottom: TaylorSpacing.navBarClearance + _panelHeight(trip),
          child: SafeArea(
            child: RecenterButton(
              onPressed: _recenter,
              isLocating: location.status == LocationStatus.unknown,
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
            switchOutCurve: Curves.easeInCubic,
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
            child: _panel(trip, user?.firstName ?? ''),
          ),
        ),
      ],
    );
  }

  /// Alto aproximado del panel inferior según el momento del flujo.
  ///
  /// Se estima en lugar de medirse porque medir obligaría a un frame extra:
  /// el botón se colocaría primero mal y saltaría después. Estas cifras están
  /// tomadas de los paneles reales y solo necesitan ser aproximadas —el botón
  /// tiene que quedar por encima, no pegado.
  double _panelHeight(Trip? trip) {
    if (trip?.status == TripStatus.completed) return 300;
    if (trip?.status == TripStatus.searching) return 260;
    if (trip != null && trip.isActive) return 300;
    if (_destination != null) return 380;
    return 96;
  }

  Widget _panel(Trip? trip, String firstName) {
    // Viaje terminado: calificar es lo que cierra el ciclo.
    if (trip?.status == TripStatus.completed) {
      return RatingCard(key: const ValueKey('rating'), trip: trip!);
    }

    if (trip?.status == TripStatus.searching) {
      return SearchingDriverCard(
        key: const ValueKey('searching'),
        onCancel: () => ref.read(rideControllerProvider.notifier).cancel(),
      );
    }

    if (trip != null && trip.isActive) {
      return DriverAssignedCard(
        key: const ValueKey('assigned'),
        trip: trip,
        onCancel: () => ref.read(rideControllerProvider.notifier).cancel(),
      );
    }

    // Con destino elegido: se muestran las categorías y el precio.
    final destination = _destination;
    if (destination != null) {
      return RideConfirmSheet(
        key: const ValueKey('confirm'),
        origin: ref.read(locationControllerProvider.notifier).positionOrFallback,
        destination: destination,
        selectedTier: _tier,
        onTierSelected: (tier) => setState(() => _tier = tier),
        onConfirm: _confirmRide,
        onClear: () => setState(() => _destination = null),
      );
    }

    return HomeSheet(
      key: const ValueKey('idle'),
      userName: firstName,
      recents: ref.watch(recentDestinationsProvider),
      onDestinationTap: _openSearch,
      onSavedPlaceTap: _pickSavedPlace,
      onRecentTap: _selectDestination,
    );
  }
}
