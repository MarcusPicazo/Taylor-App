import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/taylor_colors.dart';
import '../../../core/theme/taylor_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/models/ride_tier.dart';
import '../../../data/places_repository.dart';
import '../../../l10n/app_localizations.dart';
import 'ride_tier_selector.dart';

/// Panel de confirmación: destino elegido, categorías y precio.
///
/// Aparece cuando ya hay ruta dibujada en el mapa. Muestra las tres categorías
/// a la vez porque la decisión es comparativa —precio contra plazas contra
/// espera— y esconderlas obligaría a memorizar cifras.
class RideConfirmSheet extends StatelessWidget {
  const RideConfirmSheet({
    super.key,
    required this.origin,
    required this.destination,
    required this.selectedTier,
    required this.onTierSelected,
    required this.onConfirm,
    required this.onClear,
    required this.onEditPickup,
    this.pickupLabel,
  });

  /// Nombre del punto de encuentro si se marcó a mano; nulo si es el GPS.
  final String? pickupLabel;

  /// Abre el mapa para mover el punto de encuentro.
  final VoidCallback onEditPickup;

  /// Punto de partida real de la usuaria.
  ///
  /// Se recibe en lugar de asumirse: antes se calculaba la distancia desde una
  /// dirección fija, así que el precio no correspondía a la ruta dibujada en
  /// el mapa. Una tarifa que no cuadra con lo que se ve es peor que no
  /// mostrarla.
  final LatLng origin;

  final PlaceSuggestion destination;
  final RideTier selectedTier;
  final ValueChanged<RideTier> onTierSelected;
  final VoidCallback onConfirm;
  final VoidCallback onClear;

  /// Distancia aproximada origen–destino, en kilómetros.
  ///
  /// Recta entre los dos puntos con un factor de 1.35 que aproxima el rodeo
  /// de las calles. La distancia exacta viene de la Directions API cuando se
  /// integre; mientras tanto esto da estimaciones plausibles en lugar de
  /// cifras inventadas.
  double get _distanceKm {
    // Grados a kilómetros en la latitud de Ciudad de México.
    const kmPerLat = 111.0;
    const kmPerLng = 105.0;

    final dLat =
        (destination.position.latitude - origin.latitude) * kmPerLat;
    final dLng =
        (destination.position.longitude - origin.longitude) * kmPerLng;

    return math.sqrt(dLat * dLat + dLng * dLng) * 1.35;
  }

  /// Duración estimada: velocidad media urbana de ~22 km/h en CDMX.
  int get _minutes => math.max(5, (_distanceKm / 22 * 60).round());

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TaylorSpacing.md),
      child: GlassSurface(
        padding: const EdgeInsets.all(TaylorSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: TaylorColors.raspberry,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        destination.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.cancel,
                  onPressed: onClear,
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              l10n.tripEstimate(
                _distanceKm.toStringAsFixed(1),
                _minutes,
              ),
              style: theme.textTheme.labelSmall,
            ),

            // Punto de encuentro editable. Va discreto porque la posición GPS
            // acierta casi siempre; solo hace falta cuando el mapa no coincide
            // con dónde está realmente la usuaria — un estacionamiento, una
            // plaza grande, un edificio con varias entradas.
            const SizedBox(height: 6),
            InkWell(
              onTap: onEditPickup,
              borderRadius: BorderRadius.circular(TaylorRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trip_origin_rounded,
                      size: 15,
                      color: TaylorColors.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pickupLabel ?? l10n.pinCurrentLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    Text(
                      l10n.pinChange,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: TaylorColors.brandText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TaylorSpacing.md),

            RideTierSelector(
              selected: selectedTier,
              onSelected: onTierSelected,
              distanceKm: _distanceKm,
              minutes: _minutes,
              pickupMinutes: 4,
            ),

            const SizedBox(height: TaylorSpacing.sm),
            FilledButton(
              onPressed: onConfirm,
              child: Text(l10n.confirmRide(selectedTier.displayName)),
            ),
          ],
        ),
      ),
    );
  }
}
