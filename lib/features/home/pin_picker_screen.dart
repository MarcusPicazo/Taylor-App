import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/taylor_colors.dart';
import '../../core/theme/taylor_theme.dart';
import '../../data/places_repository.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/map_style.dart';

/// Selección de un punto marcándolo en el mapa.
///
/// Existe porque escribir no siempre alcanza: la entrada de un callejón, una
/// obra sin número, un punto de encuentro acordado por teléfono, o cualquier
/// sitio que Places no conoce. Todas las apps de movilidad acaban teniendo
/// esta salida.
///
/// El pin se queda **fijo en el centro** y lo que se mueve es el mapa. Es al
/// revés de lo intuitivo pero mucho más preciso: arrastrar un marcador lo
/// esconde bajo el dedo justo cuando hay que afinar.
class PinPickerScreen extends StatefulWidget {
  const PinPickerScreen({
    super.key,
    required this.initialPosition,
    required this.isPickup,
  });

  final LatLng initialPosition;

  /// Cambia el texto y el color: origen en rosa, destino en oscuro, igual que
  /// los marcadores del mapa principal.
  final bool isPickup;

  @override
  State<PinPickerScreen> createState() => _PinPickerScreenState();
}

class _PinPickerScreenState extends State<PinPickerScreen> {
  late LatLng _position = widget.initialPosition;
  bool _moving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPickup ? l10n.pinPickupTitle : l10n.pinDropoffTitle,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition,
                zoom: 17,
              ),
              style: isDark ? TaylorMapStyle.dark : TaylorMapStyle.light,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onCameraMoveStarted: () => setState(() => _moving = true),
              onCameraMove: (camera) => _position = camera.target,
              onCameraIdle: () {
                setState(() => _moving = false);
                // Un toque seco al asentarse: confirma que el punto quedó
                // fijado sin necesidad de mirar.
                HapticFeedback.selectionClick();
              },
            ),
          ),

          // Pin fijo en el centro. Se eleva mientras el mapa se mueve, como si
          // despegara del suelo, y vuelve a posarse al detenerse.
          IgnorePointer(
            child: Center(
              child: AnimatedContainer(
                duration: TaylorMotion.fast,
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                  0,
                  _moving ? -34 : -22,
                  0,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 46,
                  color: widget.isPickup
                      ? TaylorColors.raspberry
                      : theme.colorScheme.onSurface,
                  shadows: const [
                    Shadow(blurRadius: 10, color: Color(0x40000000)),
                  ],
                ),
              ),
            ),
          ),

          // Sombra del pin, que se encoge al elevarse. Refuerza la sensación
          // de altura y marca el punto exacto que se está eligiendo.
          IgnorePointer(
            child: Center(
              child: AnimatedContainer(
                duration: TaylorMotion.fast,
                width: _moving ? 6 : 10,
                height: _moving ? 3 : 5,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: _moving ? 0.16 : 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          Positioned(
            left: TaylorSpacing.md,
            right: TaylorSpacing.md,
            bottom: TaylorSpacing.lg,
            child: SafeArea(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  PlaceSuggestion(
                    name: widget.isPickup
                        ? l10n.pinPickupLabel
                        : l10n.pinDropoffLabel,
                    address: l10n.pinCoordinates(
                      _position.latitude.toStringAsFixed(5),
                      _position.longitude.toStringAsFixed(5),
                    ),
                    position: _position,
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.pinConfirm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
