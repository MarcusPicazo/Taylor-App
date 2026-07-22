import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../data/models/trip.dart';
import '../ride_controller.dart';
import 'map_style.dart';

/// Google Map con el estilo de Taylor aplicado.
///
/// El mapa se despoja de todo lo que no ayuda a orientarse —POIs, negocios,
/// tránsito— para que los únicos elementos con color sean el origen, el destino
/// y la ruta. Es la misma lógica de "minimalismo funcional" del brand book.
class MapView extends StatefulWidget {
  const MapView({super.key, this.trip});

  final Trip? trip;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;

  static const CameraPosition _initial = CameraPosition(
    target: RideController.defaultOrigin,
    zoom: 15.2,
  );

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Al aparecer una ruta, encuadra origen y destino juntos.
    final trip = widget.trip;
    if (trip != null && oldWidget.trip == null) {
      _fitToTrip(trip);
    }
  }

  Future<void> _fitToTrip(Trip trip) async {
    final controller = _controller;
    if (controller == null) return;

    final a = trip.origin.position;
    final b = trip.destination.position;

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            a.latitude < b.latitude ? a.latitude : b.latitude,
            a.longitude < b.longitude ? a.longitude : b.longitude,
          ),
          northeast: LatLng(
            a.latitude > b.latitude ? a.latitude : b.latitude,
            a.longitude > b.longitude ? a.longitude : b.longitude,
          ),
        ),
        // Padding generoso: las tarjetas flotantes tapan el tercio inferior.
        90,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GoogleMap(
      initialCameraPosition: _initial,
      style: isDark ? TaylorMapStyle.dark : TaylorMapStyle.light,
      // Desactivado hasta que exista el flujo de permiso en tiempo de
      // ejecución. Declarar ACCESS_FINE_LOCATION en el manifiesto no basta:
      // Android exige pedirlo al usuario, y sin eso el SDK de Maps registra
      // "Cannot enable MyLocation layer" en cada arranque.
      //
      // Al integrar geolocator, pedir el permiso y poner esto en true.
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      // El logo de Google y los créditos quedarían bajo la barra flotante;
      // este padding los sube para no violar los términos de uso del mapa.
      padding: const EdgeInsets.only(bottom: 120),
      onMapCreated: (controller) {
        _controller = controller;
        if (trip != null) _fitToTrip(trip);
      },
      markers: {
        if (trip != null) ...{
          Marker(
            markerId: const MarkerId('origin'),
            position: trip.origin.position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
            infoWindow: InfoWindow(title: trip.origin.label),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: trip.destination.position,
            infoWindow: InfoWindow(title: trip.destination.label),
          ),
        },
      },
      polylines: {
        if (trip != null)
          Polyline(
            polylineId: const PolylineId('route'),
            points: [trip.origin.position, trip.destination.position],
            color: TaylorColors.raspberry,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
      },
    );
  }
}
