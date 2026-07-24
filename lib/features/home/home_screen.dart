import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/location/location_service.dart';
import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/ride_tier.dart';
import '../../data/models/trip.dart';
import '../../data/places_repository.dart';
import '../../data/recent_destinations.dart';
import '../../data/session_controller.dart';
import '../trips/rating_card.dart';
import 'destination_search_screen.dart';
import 'pin_picker_screen.dart';
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

  /// Punto de encuentro marcado a mano. Si es nulo se usa la posición GPS.
  PlaceSuggestion? _pickup;

  RideTier _tier = RideTier.go;

  /// Se centra el mapa en la usuaria en cuanto hay posición, una sola vez.
  ///
  /// Sin esto la app abría sobre el centro de la ciudad y había que pulsar
  /// recentrar a mano cada vez, aunque el permiso ya estuviera concedido.
  bool _centeredOnUser = false;

  /// Cuánto ha crecido el panel plegable, reportado en cada fotograma.
  ///
  /// Es un [ValueNotifier] y no estado del widget a propósito: con `setState`
  /// se reconstruiría toda la pantalla —incluido el mapa— sesenta veces por
  /// segundo durante el arrastre. Así solo se repinta el botón.
  final _sheetExpansion = ValueNotifier<double>(0);

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

    // El buscador puede devolver una petición de marcar en el mapa en lugar
    // de un lugar: se distingue por su placeId reservado.
    if (result.placeId == kDropPinRequest) {
      await _pickOnMap(isPickup: false);
      return;
    }

    _selectDestination(result);
  }

  /// Abre el mapa para marcar un punto a mano.
  Future<void> _pickOnMap({required bool isPickup}) async {
    final start = isPickup
        ? (_pickup?.position ??
            ref.read(locationControllerProvider.notifier).positionOrFallback)
        : (_destination?.position ??
            ref.read(locationControllerProvider.notifier).positionOrFallback);

    final result = await Navigator.of(context).push<PlaceSuggestion>(
      MaterialPageRoute(
        builder: (_) => PinPickerScreen(
          initialPosition: start,
          isPickup: isPickup,
        ),
      ),
    );

    if (result == null || !mounted) return;

    if (isPickup) {
      setState(() => _pickup = result);
    } else {
      _selectDestination(result);
    }
  }

  /// Pide confirmación antes de cancelar.
  ///
  /// Cancelar tiene consecuencias del otro lado —una conductora que ya venía
  /// en camino— y el botón está cerca de otros que se pulsan a menudo. Un
  /// toque accidental no puede deshacer un viaje.
  Future<void> _confirmCancel() async {
    final l10n = L10n.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelTripTitle),
        content: Text(l10n.cancelTripBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelTripKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TaylorColors.emergency,
            ),
            child: Text(l10n.cancelTripConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(rideControllerProvider.notifier).cancel();
    }
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

    final pickup = _pickup;
    final gps = ref.read(locationControllerProvider.notifier);

    ref.read(rideControllerProvider.notifier).requestRide(
          origin: TripLocation(
            label: pickup?.name ?? 'Origen',
            address: pickup?.address ?? 'Tu ubicación',
            position: pickup?.position ?? gps.positionOrFallback,
          ),
          destination: TripLocation(
            label: destination.name,
            address: destination.address,
            position: destination.position,
          ),
        );

    setState(() {
      _destination = null;
      _pickup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionControllerProvider).user;
    final trip = ref.watch(rideControllerProvider);
    final location = ref.watch(locationControllerProvider);

    // Primer centrado automático, en cuanto llega la posición. Solo una vez:
    // después la usuaria manda, y recentrar en cada actualización del GPS le
    // arrebataría el mapa mientras lo explora.
    if (!_centeredOnUser && location.position != null) {
      _centeredOnUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapKey.currentState?.moveTo(location.position!);
      });
    }

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
        ValueListenableBuilder<double>(
          valueListenable: _sheetExpansion,
          builder: (context, expansion, child) {
            // Con viaje activo el panel no se arrastra, así que la expansión
            // del plegable no aplica.
            final extra = trip == null && _destination == null ? expansion : 0.0;

            return Positioned(
              right: TaylorSpacing.md,
              bottom: TaylorSpacing.navBarClearance +
                  _panelHeight(trip) +
                  extra,
              // Sin AnimatedPositioned: la altura ya llega interpolada en cada
              // fotograma, desde el dedo o desde la curva de asentamiento del
              // panel. Animarla otra vez añadiría un retraso elástico que hace
              // que el botón parezca perseguir al panel en lugar de moverse
              // con él.
              child: child!,
            );
          },
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
          // Separación constante entre el panel y la barra, sea cual sea el
          // estado del flujo: los dos bloques flotan como un grupo.
          bottom: TaylorSpacing.navBarClearance - TaylorSpacing.xl,
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

  /// Alto del panel inferior según el momento del flujo.
  ///
  /// Se estima en lugar de medirse porque medir obligaría a un fotograma
  /// extra: el botón se colocaría mal primero y saltaría después. Estas cifras
  /// vienen de los paneles reales y solo necesitan ser aproximadas — el botón
  /// tiene que quedar por encima, no pegado.
  ///
  /// Al panel plegable se le suma su expansión real, que llega por callback en
  /// cada fotograma del arrastre.
  double _panelHeight(Trip? trip) {
    if (trip?.status == TripStatus.completed) return 300;
    if (trip?.status == TripStatus.searching) return 250;
    if (trip != null && trip.isActive) return 300;
    if (_destination != null) return 400;

    // Plegado: campo de destino + chips de acceso rápido. La expansión se
    // suma aparte, en el ValueListenableBuilder del botón.
    return 150;
  }

  Widget _panel(Trip? trip, String firstName) {
    // Viaje terminado: calificar es lo que cierra el ciclo.
    if (trip?.status == TripStatus.completed) {
      return RatingCard(key: const ValueKey('rating'), trip: trip!);
    }

    if (trip?.status == TripStatus.searching) {
      return SearchingDriverCard(
        key: const ValueKey('searching'),
        onCancel: _confirmCancel,
      );
    }

    if (trip != null && trip.isActive) {
      return DriverAssignedCard(
        key: const ValueKey('assigned'),
        trip: trip,
        onCancel: _confirmCancel,
      );
    }

    // Con destino elegido: se muestran las categorías y el precio.
    final destination = _destination;
    if (destination != null) {
      return RideConfirmSheet(
        key: const ValueKey('confirm'),
        origin: _pickup?.position ??
            ref.read(locationControllerProvider.notifier).positionOrFallback,
        pickupLabel: _pickup?.name,
        destination: destination,
        selectedTier: _tier,
        onTierSelected: (tier) => setState(() => _tier = tier),
        onConfirm: _confirmRide,
        onClear: () => setState(() => _destination = null),
        onEditPickup: () => _pickOnMap(isPickup: true),
      );
    }

    return HomeSheet(
      key: const ValueKey('idle'),
      userName: firstName,
      recents: ref.watch(recentDestinationsProvider),
      onDestinationTap: _openSearch,
      onSavedPlaceTap: _pickSavedPlace,
      onRecentTap: _selectDestination,
      onExpansionChanged: (height) => _sheetExpansion.value = height,
    );
  }
}
