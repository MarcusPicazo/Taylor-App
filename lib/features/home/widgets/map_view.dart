import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../data/models/trip.dart';
import 'map_style.dart';

/// Google Map con el estilo de Taylor.
///
/// El mapa se despoja de todo lo que no ayuda a orientarse —POIs, negocios,
/// tránsito— para que los únicos elementos con color sean el origen, el
/// destino y la ruta. Es el "minimalismo funcional" del brand book aplicado a
/// la cartografía.
///
/// **Si el mapa se ve gris**, falta la API key: ver README → "Configurar
/// Google Maps". Sin ella los tiles no cargan, aunque el resto de la app
/// funcione con normalidad.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    this.trip,
    this.origin,
    this.destination,
    this.showMyLocation = false,
  });

  final Trip? trip;

  /// Punto de encuentro cuando aún no hay viaje creado.
  final LatLng? origin;

  /// Destino elegido antes de confirmar el viaje.
  final LatLng? destination;

  /// Punto azul de la posición propia. Requiere permiso concedido: activarlo
  /// sin él hace que el SDK registre un error en cada arranque.
  final bool showMyLocation;

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  GoogleMapController? _controller;

  static const CameraPosition _initial = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 15.2,
  );

  LatLng? get _origin => widget.trip?.origin.position ?? widget.origin;
  LatLng? get _destination =>
      widget.trip?.destination.position ?? widget.destination;

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previous = oldWidget.trip?.destination.position ??
        oldWidget.destination;
    final current = _destination;
    final origin = _origin;

    // Al aparecer o cambiar el destino, encuadra los dos extremos.
    if (current != null && current != previous && origin != null) {
      _fitBounds(origin, current);
    }
  }

  /// Centra la cámara en una posición. La usa el botón de recentrar.
  Future<void> moveTo(LatLng position, {double zoom = 16}) async {
    await _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  Future<void> _fitBounds(LatLng a, LatLng b) async {
    final controller = _controller;
    if (controller == null) return;

    // Dos puntos casi idénticos producen un bounds degenerado que el SDK
    // rechaza; puede pasar al elegir un destino muy cercano.
    if ((a.latitude - b.latitude).abs() < 0.0005 &&
        (a.longitude - b.longitude).abs() < 0.0005) {
      await moveTo(a);
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            math.min(a.latitude, b.latitude),
            math.min(a.longitude, b.longitude),
          ),
          northeast: LatLng(
            math.max(a.latitude, b.latitude),
            math.max(a.longitude, b.longitude),
          ),
        ),
        // Margen amplio alrededor de la ruta. El panel de tarifas ocupa casi
        // la mitad inferior de la pantalla, así que sin esto el marcador de
        // origen queda escondido detrás y la ruta parece empezar de la nada.
        140,
      ),
    );
  }

  /// Traza una curva suave entre dos puntos.
  ///
  /// La ruta real necesita la Directions API, que se cobra por petición. Una
  /// línea recta se lee como un error de dibujo, así que se arquea un poco:
  /// comunica "trayecto" sin fingir una precisión que no tenemos. Al integrar
  /// Directions, esto se sustituye por la polilínea real.
  List<LatLng> _routePoints(LatLng a, LatLng b) {
    const segments = 24;

    final dx = b.longitude - a.longitude;
    final dy = b.latitude - a.latitude;
    final curvature = math.sqrt(dx * dx + dy * dy) * 0.12;

    // Punto de control desplazado perpendicularmente al segmento.
    final midLat = (a.latitude + b.latitude) / 2 - dx * curvature;
    final midLng = (a.longitude + b.longitude) / 2 + dy * curvature;

    return [
      for (var i = 0; i <= segments; i++)
        _quadratic(a, LatLng(midLat, midLng), b, i / segments),
    ];
  }

  LatLng _quadratic(LatLng a, LatLng control, LatLng b, double t) {
    final u = 1 - t;
    return LatLng(
      u * u * a.latitude + 2 * u * t * control.latitude + t * t * b.latitude,
      u * u * a.longitude + 2 * u * t * control.longitude + t * t * b.longitude,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final origin = _origin;
    final destination = _destination;

    return GoogleMap(
      initialCameraPosition: _initial,
      style: isDark ? TaylorMapStyle.dark : TaylorMapStyle.light,
      myLocationEnabled: widget.showMyLocation,
      // Se oculta el botón nativo: Taylor tiene el suyo, con el estilo de la
      // marca y colocado donde no lo tapa el panel inferior.
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      // Gestos completos: la usuaria tiene que poder recorrer la ciudad.
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: false,
      // Desplaza el área útil del mapa hacia arriba para que el panel no tape
      // ni el contenido ni el logo de Google —taparlo incumple los términos
      // de uso—. Con destino elegido el panel crece, así que el margen sube.
      padding: EdgeInsets.only(
        bottom: destination != null ? 260 : 120,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        if (origin != null && destination != null) {
          _fitBounds(origin, destination);
        }
      },
      markers: {
        if (origin != null)
          Marker(
            markerId: const MarkerId('origin'),
            position: origin,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
            infoWindow: InfoWindow(title: widget.trip?.origin.label ?? ''),
          ),
        if (destination != null)
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            infoWindow:
                InfoWindow(title: widget.trip?.destination.label ?? ''),
          ),
      },
      polylines: {
        if (origin != null && destination != null) ...{
          // Trazo claro y grueso por debajo: separa la ruta del mapa igual
          // que un contorno separa el texto de una fotografía.
          Polyline(
            polylineId: const PolylineId('route_casing'),
            points: _routePoints(origin, destination),
            color: TaylorColors.white.withValues(alpha: 0.9),
            width: 11,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
          Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints(origin, destination),
            color: TaylorColors.raspberry,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        },
      },
    );
  }
}
